---
layout: post
title: Redis 汇总梳理（转）
description: 所有信息汇总
published: true
category: redis
---

> NOTE: 这个是我们 Redis 讨论小组中，一个很牛的同事（xkniu）梳理的，特别细致、有价值，在我这儿也转一份，留着纪念。

## 数据结构

### SDS 字符串类型

#### Preview

```c
typedef char *sds;

struct __attribute__ ((__packed__)) sdshdr64 {
    uint64_t len; /* used */
    uint64_t alloc; /* excluding the header and null terminator */
    unsigned char flags; /* 3 lsb of type, 5 unused bits */
    char buf[];
};
```

Redis 操作的时候，根据 char 的指针，定位到 `sdshdr` 结构体的地址，从而获取其他信息来操作 SDS。所以 redis 中定义 char 指针的别名为 SDS。

#### Summary

- Redis 通常只用 C 字符串作字符串常量。大部分情况下，使用 SDS (Simple Dynamic String) 来表示字符串值
- SDS 在数组扩容时使用容量预分配（额外多申请些空间），并冗余了长度与未使用字节数信息
- SDS 的优点如下：
	- 冗余了长度信息，`strlen` 的时间复杂度从 **O(N)** 变为 **O(1)**
	- 提供的 API 负责了对空间申请的操作，杜绝了缓冲区溢出
	- 预分配内存，减少了内存重分配的次数
	- 二进制安全，可以用来保存二进制字符串（含有 `\0` 字符）
- 空间预分配策略：长度小于 1M 则分配 len 大小的空间；大于等于 1M，分配 1M 的未使用空间
- 惰性空间释放：缩短后，不释放空间，只是用 free 记录下来。提供了专门函数用于释放

### 链表

#### Preview

```c
typedef struct listNode {
    struct listNode *prev;
    struct listNode *next;
    void *value;
} listNode;

typedef struct listIter {
    listNode *next;
    int direction;
} listIter;

typedef struct list {
    listNode *head;
    listNode *tail;
    void *(*dup)(void *ptr);
    void (*free)(void *ptr);
    int (*match)(void *ptr, void *key);
    unsigned long len;
} list;
```

#### Summary

- 链表为双向链表，并且有特殊头结点（记录了首位节点的指针和链表长度）
- 链表的首尾节点的前置/后置节点为 null，是无环链表
- 可以给链表设置不同类型的函数（接口概念，列表结构上存操作函数的指针），来保存不同类型的值。不仅仅是链表，大部分 redis 中的数据结构都采取这样的设计

### 字典

#### Preview

```c
typedef struct dictEntry {
    void *key;
    union {
        void *val;
        uint64_t u64;
        int64_t s64;
        double d;
    } v;
    struct dictEntry *next;
} dictEntry;

/* This is our hash table structure. Every dictionary has two of this as we
 * implement incremental rehashing, for the old to the new table. */
typedef struct dictht {
    dictEntry **table;
    unsigned long size;
    unsigned long sizemask;
    unsigned long used;
} dictht;

typedef struct dict {
    dictType *type;
    void *privdata;
    dictht ht[2];
    long rehashidx; /* rehashing not in progress if rehashidx == -1 */
    int iterators; /* number of iterators currently running */
} dict;
```

#### Summary

- 字典中有两个哈希表，一个用来平时使用，一个用来 rehash 时使用
- 哈希算法为 MurmurHash2 算法或 DJB hash 算法，然后保留后若干位（通过掩码与操作来快速计算）
- 用链地址法来解决 hash 冲突
- 哈希表的大小为 2^n，每次扩容（rehash）时，新的哈希表大小为第一个大于已有元素个数的2的整数次幂
- 哈希表的 rehash 是一个渐进式的操作（redis 为单进程单线程，减少单个操作的处理时间）；在 rehash 的过程中删除/查找/更新时需要同时操作两个 hash 表，而新增只需要操作新哈希表（保证旧哈希表的数据会越来越少，从而 rehash 完成）
- 由于操作系统的 **copy-on-write** 特性，为了避免 fork 的子进程占用内存过大，redis 哈希表的负载因子在没有 BGSAVE/BGAOFREWRITE 进行时为 1，在有 BGSAVE/BGAOFREWRITE 正在进行时为 5（有子进程的时候，只在哈希表真的冲突很严重的情况下 rehash）。哈希表负载因子为 0.1 的时候进行收缩
- Rehash 执行的时间：
	- 每次对哈希表进行操作的时候（满足负载因子：无子进程 1，有子进程 5），进行扩容操作，不会进行收缩
	- serverCron，当有子进程时不进行 rehash；无子进程时，每次对于设定数量个 db 进行缩容或扩容操作（这里是 rehash 一定的时间，而不是一个 hash 值）

### 跳跃表 skiplist

#### Preview

```c
/* ZSETs use a specialized version of Skiplists */
typedef struct zskiplistNode {
    robj *obj;
    double score;
    struct zskiplistNode *backward;
    struct zskiplistLevel {
        struct zskiplistNode *forward;
        unsigned int span;
    } level[];
} zskiplistNode;

typedef struct zskiplist {
    struct zskiplistNode *header, *tail;
    unsigned long length;
    int level;
} zskiplist;

typedef struct zset {
    dict *dict;
    zskiplist *zsl;
} zset;
```

#### Summary

- 跳表提供了有序链表的存储于查询操作，功能类似于 RB-Tree
- 跳表用作有序集合的实现和在集群节点中用作内部数据结构
- 跳表简述：每个节点随机一个层数，其中根据幂次定律，越高层的概率越少（初始层数为1，通过 roll 有一半概率增加一层，不停的 roll 直到出现不增加层的结果。从概率上来说，高层的数量应该为低一层节点数量的一半）。将每个节点的各层在对应层上用指针形成链表，每次查询时，通过首节点（虚拟节点，拥有数据节点中最高层数层）的最高层开始遍历，查找过程与二叉查找树类似
- Redis 的跳表的一些特性：
	- Redis 中链表为双向链表
	- Redis 中记了它到下一个节点的跨度（距离）
	- Redis 跳表中用来排序的是 score，还存了实际的对象 obj

### 整数集合 intset

#### Preview

```c
// 总共有三种 encoding
/* Note that these encodings are ordered, so:
 * INTSET_ENC_INT16 < INTSET_ENC_INT32 < INTSET_ENC_INT64. */
#define INTSET_ENC_INT16 (sizeof(int16_t))
#define INTSET_ENC_INT32 (sizeof(int32_t))
#define INTSET_ENC_INT64 (sizeof(int64_t))

typedef struct intset {
    uint32_t encoding;
    uint32_t length;
    int8_t contents[];
} intset;
```

#### Summary

- 整数集合通过一个编码类型（标明数组存储类型）和一个有序数组来实现
- 数据类型在使用过程中如果需要会自动升级，但是不会自动降级
- 集合数据结构的实现之一，当一个结合只包含整数类型并且数量不多的时候，redis 用整数集合来存储

### 压缩列表 ziplist

#### Preview

```text
zlbytes | zltail | zllen | entry1 | entry2 | ... | entryN | zlend
```

#### Summary

- 压缩列表是列表键和哈希键的底层实现之一，当列表只含小整数或较短字符串的时候，才会使用
- 压缩列表本质就是「不定长元素」的数组，用数组来模拟链表
- 不定长元素根据需要用能刚好存储的元素，充分节约内存
- 每个节点存储自己的编码类型、内容，和上个节点的长度（方便反序遍历）
- 存储各个数据的长度会根据需要动态改变（和变长字符编码设计类似）
- 添加删除节点可能会导致连锁更新（上个节点长度字段连锁扩容），但是概率不大，一般不会影响性能

### 对象

#### Preview

```c
typedef struct redisObject {
    unsigned type:4;
    unsigned encoding:4;
    unsigned lru:LRU_BITS; /* lru time (relative to server.lruclock) */
    int refcount;
    void *ptr;
} robj;
```

#### Summary

- Redis 有字符串、列表、哈希、集合、有序集合5种数据类型
	- REDIS_STRING，编码是整数数值或 SDS 类型（和 embstr 字符串，将 SDS 与 redisObject 紧挨着申请内存空间，一种优化，缓存友好，当字符串长度小于等于32时用）
	- REDIS_LIST，编码是 ziplist 或 linkedlist。所有字符串长度小于 *list-max-ziplist-value (64)*，元素数量少于 *list-max-ziplist-entries (512)* 时使用 ziplist
	- REDIS_HASH，编码可以是 ziplist 或者 hashtable。所有字符串长度小于 *hash-max-ziplist-value (64)*，元素数量少于 *hash-max-ziplist-entries (512)* 时使用 ziplist
	- REDIS_SET，编码是 intset 或 hashtable。所有元素都是整数并且长度小于 *set-max-intset-entries (512)* 时使用 inset
	- REDIS_ZSET，编码是 ziplist 或者 skiplist。所有字符串长度小于 *zset-max-ziplist-value (64)*，元素数量少于 *zset-max-ziplist-entries (128)* 时使用 ziplist（这里的 ziplist 是按照 score 排序的）
- Redis 命令多态，根据 key 的类型来判断是不是能执行命令和如何执行命令
- 对象通过引用计数来实现内存回收
- Redis 初始化服务器时创建了 0~9999 的整数的字符串对象用来共享
- lru 记录了最近对象使用时间，用来计算对象的空转时长
- `object encoding/idletime/refcount` 用来查看对象的编码/空转时间/引用数量

## 单机数据库

### 数据库

#### Preview

```c
struct redisServer {
    redisDb *db;				/* Array of dbs */
    int dbnum;                      /* Total number of configured DBs */
}

typedef struct redisDb {
    dict *dict;                 /* The keyspace for this DB */
    dict *expires;              /* Timeout of keys with a timeout set */
    dict *blocking_keys;        /* Keys with clients waiting for data (BLPOP) */
    dict *ready_keys;           /* Blocked keys that received a PUSH */
    dict *watched_keys;         /* WATCHED keys for MULTI/EXEC CAS */
    struct evictionPoolEntry *eviction_pool;    /* Eviction pool of keys */
    int id;                     /* Database ID */
    long long avg_ttl;          /* Average TTL, just for stats */
} redisDb;
```

#### Summary

- Redis 有多个数据库，每个数据库相互隔离
- 数据库的键值都存在 dict 字典中；带过期时间的 key，过期信息存在 expires 字典中
- 对 key 设置过期时间，相对与绝对时间都会转为绝对时间保存（PEXPIREAT 实现）
- Redis 过期 key 删除策略
	- 惰性删除：获取 key 的时候，如果过期了删除。内存不友好，CPU 友好（读写之前会执行 expireIfNeeded）
	- 定期删除：serverCron，随机从 expires 字典中取一个 key，如果过期了就删除它。检查一定的数量或者到达指定的超时时间
- 执行生成 RDB 的时候不保存过期的 key；载入 RDB 的时候，master 不载入已经过期的 key，slave 不论是否过期都载入，当与 master 进行数据同步的时候会删除这些 key
- 当过期 key 被删除的时候，会向 AOF 文件中追加一个 DEL 命令；AOF 重写后不包含过期 key
- 主服务器 key 过期后，会向所有从服务器发送一条 DEL 命令；从服务器不会主动删除过期 key，而是等待主服务器的 DEL 命令（从服务器没有惰性删除，导致有可能会获取到已经过期的 key，在 3.2 版本中[修复了这个问题](https://github.com/antirez/redis/issues/1768)，虽然不惰性删除，但是假如 key 过期了，不返回该 key）

### 持久化

#### Preview

```c
struct redisServer {
    long long dirty;                /* Changes to DB from the last save */
    time_t lastsave;                /* Unix time of last successful save */
	
	sds aof_buf;      /* AOF buffer, written before entering the event loop */
}
```

#### Summary

- Redis 有两种持久化方式 RDB (Redis Dump Binary?) 和 AOF (Append Only File)
- RDB 数据跟紧致，但及时性不如 AOF
- Redis 启动时恢复状态，优先载入 AOF 文件，只有没有开 AOF 持久化时，才通过 RDB 恢复（因为 AOF 及时性更好）。加载过程中服务阻塞
- RDB
	- SAVE，主进程处理，服务阻塞
	- BGSAVE，fork 一个子进程生成 RDB，不会阻塞服务
	- SAVE 的条件任意一项满足（通过 dirty、lastsave 判断条件是否达成）时，serverCron 会生成 RDB
	- 每次写操作 dirty 计数器加 1，用作 save 判断标准
- AOF
	- 每次执行完写命令，将写命令追加到 AOF 缓冲区中。然后在 redis 主事件循环中判断是否需要将 AOF 缓冲区写到 AOF 文件中
	- 写入到 AOF 文件后不一定同步到磁盘，根据配置 *appendfsync* 是 always/everysec/no 来“每次事件循环/每秒/从不”来调用系统同步刷新到磁盘函数
	- 载入 AOF 是通过一个伪客户端执行 AOF 文件中的命令实现的
	- AOF 文件重写并不分析以前的文件，而是通过当前内存数据库状态生成
	- AOF 重写期间可能会有新的命令，主进程将命令保存在 AOF 重写缓冲区中，当子进程完成工作后，主进程将缓冲区中的内容写入，并原子重命名新 AOF 文件替换原 AOF 文件
- SAVE/BGSAVE 可以生成 RDB，BGSAVE fork 出一个子进程来生成 RDB 文件
- BGSAVE 执行期间，拒绝新的 SAVE/BGSAVE 命令，并将 BGREWRITEAOF 命令排队
- BRREWRITEAOF 执行期间，其他 BGSAVE 命令和 BGREWRITEAOF 命令会被拒绝

### 事件循环（aeEvent 框架）

#### Preview

```c
void aeMain(aeEventLoop *eventLoop) {
    eventLoop->stop = 0;
    while (!eventLoop->stop) {
        if (eventLoop->beforesleep != NULL)
            eventLoop->beforesleep(eventLoop);
        aeProcessEvents(eventLoop, AE_ALL_EVENTS);
    }
}
```

#### Summary

- Redis 基于 reactor 模式，使用 IO 多路复用来处理事件
- Redis 有两种类型时间：文件事件、时间事件
- Redis 基于 select/poll/kqueue 封装了自己的 aeEvent 处理框架，使得上层 API 一致
- Redis 时间事件存在一个无序链表中，有周期性和定时（一次性）事件
- 一般情况下只有 serverCron 一个时间事件，性能测试 benchmark 模式下也不超过 2 个，所以无序链表实际上几乎退化成了一个指针
- Redis 的主事件循环中轮流处理文件事件和时间事件，不会出现互相抢占。所以时间事件的实际执行时间也会比设定晚一些

关于 IO 多路复用，更多细节，参考：

* [IO 模型](/io-model/)
* [Nginx 系列：Nginx 原理](/nginx-series-principle/)

### 客户端/服务器

#### Summary

- 客户端在服务器中使用一个 clients 的链表结构存储多个客户端状态，新增客户端将增加到链表的末尾
- 客户端输入缓冲区记录了客户端命令，该缓冲区大小不能超过 1 GB
- 客户端输出缓冲区，分为固定大小和可变大小。并且有硬限制和软限制两类，超过硬限制或者超过软限制一定时间，客户端会被关闭
- 伪客户端，处理 lua 脚本的伪客户端在服务器初始化时创建，之后一直存在。加载 AOF 的伪客户端在载入工作开始时创建，载入完成后关闭。
- 服务器主要职责在于：服务启动和初始化，和客户端建立连接并处理命令请求，执行时间事件位置服务器运转
- 服务器启动需要执行以下步骤：初始化服务器状态，载入服务器配置，初始化服务器数据结构，还原数据库状态，启动事件处理循环
- 服务器相应命令请求主要有以下步骤：接受客户端命令，读取命令分析参数，执行命令，返回结果
- 服务器时间事件主要是指 serverCron 函数，主要完成的工作有：更新缓存，更新时钟，更新各类统计记录，管理各类资源，例行检查，持久化启动

## 多机数据库

### 复制

#### Summary

- Redis 的复制分为同步（sync）和命令传播（command propagate）
- 旧版本中，每次同步（断线后）都使用完全同步；新版中首次使用完全同步，之后使用部分同步，如果部分同步失败，则退化为完全同步
- 复制过程（完全同步 SYNC）
	- 从服务器向主服务器发送 SYNC 命令
	- 主服务器收到后执行 BGSAVE，生成一个 RDB，并且用一个缓冲区记录之后的写命令
	- 主服务器将 RDB 文件发送给从服务器，从服务器载入 RDB 文件
	- 主服务器将缓冲区中的命令发给从服务器
- 复制过程（部分重同步 PSYNC），从服务器断线重连后使用部分同步
	- 主服务器维持一个复制积压缓冲区，为 FIFO 队列，默认大小为 *repl-backlog-size (1M)*
	- 主从服务器都维持一个复制偏移量
	- 从服务器初次同步时，主服务器返回自身 id
	- 从服务器发送自己当前偏移量和主服务器 id 发送过去，如果偏移量还在队列中，则将偏移量后的数据同步给从服务器
- 复制的过程是 slave 成为 master 的客户端，发起同步命令；之后 master 也会成为 salve 的客户端，将命令发送给 slave，slave 是通过执行 master 的写命令实现的同步
- 新版本中初次完全同步也使用 PSYNC 实现（`PSYNC ? -1`）
- 同步完成后，通过命令传播来保持主从一致性，所以主从不是强一致的
- Redis 从服务器向主服务器发送 PING 告知 master 自己状态，作用主要有
	- 检测网络连接丢失
	- 检测命令丢失
	- 辅助实现 min-slave

### Sentinel

Sentinel 只是一个 HA 方案，是非集群下，单机 Redis 来实现高可用的。在 Redis cluster 中，已经自带了 master 选举等流程，不需要 sentinel 参与。

#### Summary

- Sentinel 是运行在特殊模式下的 Redis 服务器，是高可用的一种解决方案
- Sentinel 监控一个 Redis 主从结构，需要在 sentinel 配置文件中指定监控的 master
- Sentinal 的主要工作在于监控节点的下线状态，以及做故障转移。为了高可用性，sentinal 可以以集群的形式出现
- Sentinel 与主服务器建立命令连接和订阅连接，命令连接用于向主服务器发送命令，订阅连接用于发现其他的 sentinel；Sentinel 根据给主服务器发送 INFO 后获取从服务器信息，并且与从服务器建立命令与订阅连接
- Sentinel 发现其他 sentinel 后与它们建立命令连接
- Sentinel 每 10s 向被监视的主从服务器发送 INFO 命令，当主服务器下线，或从服务器进行故障转移时，INFO 频率改为每秒一次
- Sentinel 每秒一次发送 PING 判断实例是否下线，当回复错误或超时无回复的时候，标记实例为主观下线
- 当满足配置要求（每个 sentinel 设置的 quorum 值），sentinel 将主服务器判断为客观下线后。Sentinel 将选举 leader 并由 leader 对主服务器进行故障转移
- Sentinel 的 leader 选举是基于 RAFT 协议的，不同点有：
	- Sentinel 中除了超过半数，还需要超过配置的 quorum
	- Sentinel 选举出 leader 后不会发送 AppendEntries，而且提升某个 slave 为 master，这样新的 master 产生后，其他的 sentinel 检测到 master 恢复就会退出选举状态
- 选举为 master 的 sentinel 根据下面顺序将 slave 提升为 master
	- 去除下线状态从服务器
	- 去除五秒内没有回复 sentinel INFO 的从服务器
	- 去除与主服务器断开时间较长的从
	- 对剩下的从，按照优先级、复制偏移量、ID 排序，取其中第一个

### 集群

#### Summary

- Redis 节点以集群模式启动（*cluster-enabled yes*）后，通过 `meet` 命令将其他节点拉到集群中
- 一个 Redis 集群包含 16384 个槽，每个槽可以指派给一个节点，所有槽都指派完毕后，集群上线；反之如果有槽没有指派，则集群处于下线状态。集群配置槽后，将消息发送到其他节点
- 节点收到命令请求时，会查看这个命令的槽是否由自己负责，如果不是，则返回一条 MOVED 错误，其中包含了处理该槽的节点信息
- 当节点 A 正在迁移 i 槽到 B 时，当 A 在自己数据库中没找到该键时，返回客户端一个 ASK 错误，引导客户端到 B 节点获取数据
- 集群节点间通过发送接收消息来进行通信，常见消息有 MEET/PING/PONG/PUBLIST/FAIL，有的消息通过 gossip 协议缓慢传播，有的通过广播让节点尽快获知
- 集群间的互相发现，更新配置信息用到的命令 `MEET/PING/PONG` 是通过 gossip 协议实现的
	- 每隔一秒钟随机抽取5个节点，对其中最长时间没发送过的节点发送 PING 消息（自己所知的随机两个节点信息）
	- 时间过长（*cluster-node-timeout* 的一半）没有 PING 过的节点，也会发送 PING 消息
	- 收到者回复一条 PONG 消息
	- 一个节点也可以通过向集群广播自己的 PONG 消息，让集群立即刷新对节点的认识
- Master 选举方案（RAFT 协议实现）：集群中 PING 来获取其他节点状态，当半数以上将某个主节点标为下线后，该被标为节点下线，向集群中广播 FAIL 消息。当从服务器发现自己的主节点下线后，开始竞选 master，发出申请，只有 master 节点具有投票权，master 返回是否同意投票（每个纪元只能返回一次），收到半数以上 master 选票的从节点成为新的主节点

#### 节点心跳和gossip消息

每一秒，通常一个节点将ping 几个随机节点，这样ping的数据包的总数量（和接收的pong包）是一个恒定的量，无论集群中节点的数量。

但是每个节点可确保ping通，ping或pong不超过一半`NODE_TIMEOUT`。前`NODE_TIMEOUT`已过，节点也尝试重新与另一个节点的TCP链接，节点不相信因为当前TCP链接，是不可达的。

信息的交换量大于O（N），`NODE_TIMEOUT`设置为一个小的数字，但节点的数量（N）是非常大的，因为每个节点将尝试 ping，如果配置信息在NODE_TIMEOUT一半的时间没有更新。

例如，`NODE_TIMEOUT`设置为60秒的100个节点集群，每个节点会尝试发送99 ping每30秒，那么每秒3.3个ping，即乘以100个节点是每秒330个ping。

有一些方法可以使用已经通过交换的Redis集群的gossip信息，以减少交换的消息的数量。例如，我们可以ping那些一半`NODE_TIMEOUT`内“可能的失败”状态的节点，然后每秒ping几个包到那些工作的节点。然而，在现实世界中，设置非常小的`NODE_TIMEOUT`的大型集群可靠地工作，将在未来作为大型集群实际部署测试。

结论：

> 每 `NODE_TIMEOUT`/2 的时间内，每个节点会发出 `n-1` 个 PING 命令，收到 `n-1` 个 PONG 响应；
> 
> 1. `NODE_TIMEOUT`/2 时间内，PING 和 PONG 心跳命令的数量：`n x (n-1) x 2`= 2`n^2`
> 2. Redis 集群中，节点数量大时，耗费较多的网络带宽；
> 3. Redis 集群，因为使用 gossip 协议，进行心跳检测，所以，谨慎设计集群规模；
> 4. Redis 集群规模过大时，可以采用分级策略，划分为多个隔离的 Redis 集群；

## 独立功能

### 发布订阅

#### Preview

```c
    dict *pubsub_channels;  /* Map channels to list of subscribed clients */
    list *pubsub_patterns;  /* A list of pubsub_patterns */
```

#### Summary

- pubsub_channels 保存了频道的订阅关系，pubsub_patterns 保存了所有模式订阅关系
- pubsub_channels 中 key 为频道名称，value 为订阅的客户端列表
- pubsub_patterns 列表元素中包含一个模式和客户端
- `PUBLISH` 命令获取 pubsub_channels 匹配频道的 value，向列表客户端发送消息；遍历 pubsub_patterns 列表，向匹配 pattern 的客户端发消息
### 事务

#### Preview

```c
typedef struct client {

    multiState mstate;      /* MULTI/EXEC state */
} client;

typedef struct multiState {
    multiCmd *commands;     /* Array of MULTI commands */
    int count;              /* Total number of MULTI commands */
    int minreplicas;        /* MINREPLICAS for synchronous replication */
    time_t minreplicas_timeout; /* MINREPLICAS timeout as unixtime. */
} multiState;

/* Redis database representation. There are multiple databases identified
* by integers from 0 (the default database) up to the max configured
* database. The database number is the 'id' field in the structure. */
typedef struct redisDb {
    dict *dict;                 /* The keyspace for this DB */
    dict *expires;              /* Timeout of keys with a timeout set */
    dict *blocking_keys;        /* Keys with clients waiting for data (BLPOP) */
    dict *ready_keys;           /* Blocked keys that received a PUSH */
    dict *watched_keys;         /* WATCHED keys for MULTI/EXEC CAS */
    struct evictionPoolEntry *eviction_pool;    /* Eviction pool of keys */
    int id;                     /* Database ID */
    long long avg_ttl;          /* Average TTL, just for stats */
} redisDb;

```

#### Summary

- 执行 `multi` 后，除 multi/discard/exec/watch 之外的命令都会被加入到 commonds 数组中（FIFO）。执行 `exec` 时，批量执行命令，构造结果，清除客户端缓存状态。
- `watch` 命令就像一个乐观锁，当键被修改时，客户端的 *REDIS\_DIRTY\_CAS* 标记被打开，执行 `exec` 时，事务失败
- Redis 事务满足原子性，即事务之中不会插入其他命令
- Redis 是单进程单线程，一个时刻只有一个事务在执行，满足隔离性
- Redis 事务耐久性取决于 redis 持久化方式
- Redis 事务不满足一致性，即错误出现后，不会回退
	- Redis 入队前有基本的命令检查，入队错误会抛弃整个事务
	- 事务之间失败，redis 会忽略该错误，继续执行
	- 服务器停机时，可能事务只执行一部分，导致事务出现不一致

### 二进制数组

二进制位统计算法：variable-precision SWAR 算法（就是 MIT HAKMEM 中看到的归并思想）

### 监视器 monitor

#### Preview

```c
typedef struct redisServer {

    list *slaves, *monitors;    /* List of slaves and MONITORs */
} redisServer;
```	

#### Summary

- `monitor` 命令让自己变成一个监视器（添加到 monitor 列表中），打开 client 端的 *REDIS_MONITOR* flag。
- 服务器在每次处理命令请求「之前」，会调用 replicationFeedMonitors 遍历 monitors 并发送消息。

### 慢查询 slowlog

记录执行时长超过指定时间的命令请求。

#### Preview

```c
typedef struct redisServer {

    list *slowlog;                  /* SLOWLOG list of commands */
    long long slowlog_entry_id;     /* SLOWLOG current entry ID */
    long long slowlog_log_slower_than; /* SLOWLOG time limit (to get logged) */
    unsigned long slowlog_max_len;     /* SLOWLOG max number of items logged */
} redisServer;

typedef struct slowlogEntry {
    robj **argv;
    int argc;
    long long id;       /* Unique entry identifier. */
    long long duration; /* Time spent by the query, in nanoseconds. */
    time_t time;        /* Unix time at which the query was executed. */
} slowlogEntry;
```

#### Summary

- 时间超过的加入到 slowlog 列表中，超过数量时，删除最后一个。列表为 FIFO 队列，新数据插在表头

### Lua 脚本

#### Summary

- Redis 2.6 以后的版本都支持 lua 脚本。在启动时会对内嵌的 lua 环境执行一系列修改，以保证内嵌 lua 环境能够满足 Redis 功能
- Redis 使用 EVAL 命令执行 lua 脚本。该命令本质上是为客户端输入的脚本在 lua 中定义一个函数，并执行这个函数
- lua 脚本命令是原子性的，有执行超时时间
- lua 脚本需要满足「纯函数脚本」要求。即同样的输入要求输出相同。简单的说，在 Redis 服务器中执行的 lua 脚本不能随意使用随机函数

## 参考链接

- RAFT 协议：<http://thesecretlivesofdata.com/raft/>





[NingG]:    http://ningg.github.com  "NingG"










