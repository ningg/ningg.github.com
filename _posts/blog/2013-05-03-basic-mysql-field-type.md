---
layout: post
title: MySQL 基础：字段类型与适用场景
description: tinyint？smallint？int？bigint？
published: true
category: mysql
---

## 1. 杂谈

几点：

* 一个`页`(`page`)存放的`行数`越多，数据库性能越好

## 2. 类型属性

2 个类型属性：

* UNSIGNED：无符号
* ZEROFILL：

### 2.1. UNSIGNED，无符号

几点：

* INT 类型，范围：-21亿~+21亿
* INT UNSINGED 类型，范围：0~ +42亿
* 自增类型的主键，可以使用 UNSIGNED
* 数据库中两个INT UNSIGNED类型字段相减，会出现意料之外的结果：
	* 负数，会显示为很大的整数，例如：-1，0xFFFF FFFF（4 个字节）
	* MySQL数据库中，对于UNSIGNED字段的操作，其返回值都是UNSIGNED的
	* 通过 SET sql_mode='NO_UNSIGNED_SUBTRACTION'; 可以获得有符号的记过
* 针对 UNSIGNED：尽量不使用UNSIGNED，因为会出现意料之外的结果
* 对于INT 类型存储不了的数据，INT UNSIGNED 可能也存储不了，因此，建议直接使用 BIGINT 类型

### 2.2. ZEROFILL，0填充

几点：

* 数值类型（tinyint、int、bigint）后面的显示长度：tinyint(4)，int(11)，int（4）
* 举例：int 是 4 字节，如果没有 ZEROFILL 属性， int(11) 其中的 11 就毫无意义；
* 如果一个字段的属性是：INT(10) UNSIGNED ZEROFILL，则，其中数字输出形式：00000 00001，即，自动填充长度为10
* 通过 HEX(field)，即可查看字段实际存储的值，发现ZEROFILL 修饰的字段，只是格式化输出

## 3. SQL_MODE 设置

通常为空，可以查看 global、session两种环境中 sql_mode 的设置：

* `SELECT @@global.sql_mode \G;`
* `SELECT @@session.sql_mode \G;`

通过如下命令，进行sql_mode的设置：

* `SET global sql_mode='strict_trans_tables';`

非严格模式是，会允许一些非法操作，例如：NULL插入到NOT NULL字段，因此通常建议使用严格模式，严格模式：sql_mode 为 strict_trans_tables 或者 strict_all_tables;

sql_mode可以设置的选项：

* STRICT_TRANS_TABLES：在该模式下，如果一个值不能插入到一个事务表（例如表的存储引擎为InnoDB）中，则中断当前的操作不影响非事务表（例如表的存储引擎为MyISAM）
* ALLOW_INVALID_DATES：不完全对日期的合法性进行检查，只检查月份是否在1～12之间，日期是否在1～31之间。该模式仅对DATE和DATETIME类型有效，而对TIMESTAMP无效，因为TIMESTAMP总是要求一个合法的输入。
* ANSI_QUOTES：启用ANSI_QUOTES后，不能用双引号来引用字符串，因为它将被解释为识别符
* NO_ENGINE_SUBSTITUTION：如果需要的存储引擎被禁用或未编译，那么抛出错误。默认用默认的存储引擎替代，并抛出一个异常。
* ERROR_FOR_DIVISION_BY_ZERO：除 0 时抛出异常，默认返回 NULL
* NO_AUTO_CREATE_USER：禁止GRANT创建密码为空的用户
* NO_AUTO_VALUE_ON_ZERO：该选项影响列为自增长的插入。在默认设置下，插入0或NULL代表生成下一个自增长值。如果用户希望插入的值为0，而该列又是自增长的，那么这个选项就有用了。
* NO_BACKSLASH_ESCAPES：反斜杠“\”作为普通字符而非转义符
* NO_DIR_IN_CREATE：在创建表时忽视所有INDEX DIRECTORY和DATA DIRECTORY的选项。
* NO_ENGINE_SUBSTITUTION：如果需要的存储引擎被禁用或未编译，那么抛出错误。默认用默认的存储引擎替代，并抛出一个异常。
* STRICT_ALL_TABLES：对所有引擎的表都启用严格模式。（STRICT_TRANS_TABLES只对支持事务的表启用严格模式）。在严格模式下，一旦任何操作的数据产生问题，都会终止当前的操作。对于启用STRICT_ALL_TABLES选项的非事务引擎来说，这时数据可能停留在一个未知的状态。这可能不是所有非事务引擎愿意看到的一种情况，因此需要非常小心这个选项可能带来的潜在影响。
* ...

sql_mode有简写形式：

* ANSI：等同于REAL_AS_FLOAT、PIPES_AS_CONCAT和ANSI_QUOTES、IGNORE_SPACE的组合。
* ORACLE：等同于PIPES_AS_CONCAT、 ANSI_QUOTES、IGNORE_SPACE、 NO_KEY_OPTIONS、 NO_TABLE_OPTIONS、 NO_FIELD_OPTIONS和NO_AUTO_CREATE_USER的组合。
* TRADITIONAL：等同于STRICT_TRANS_TABLES、 STRICT_ALL_TABLES、NO_ZERO_IN_DATE、NO_ZERO_DATE、 ERROR_FOR_DIVISION_BY_ZERO、NO_AUTO_CREATE_USER和 NO_ENGINE_SUBSTITUTION的组合。
* MSSQL：等同于PIPES_AS_CONCAT、 ANSI_QUOTES、 IGNORE_SPACE、NO_KEY_OPTIONS、NO_TABLE_OPTIONS和 NO_FIELD_OPTIONS的组合。
* DB2：等同于PIPES_AS_CONCAT、ANSI_QUOTES、 IGNORE_SPACE、NO_KEY_OPTIONS、 NO_TABLE_OPTIONS和NO_FIELD_OPTIONS的组合。
* MYSQL323：等同于NO_FIELD_OPTIONS和HIGH_NOT_PRECEDENCE的组合。
* MYSQL40：等同于NO_FIELD_OPTIONS和HIGH_NOT_PRECEDENCE的组合。
* MAXDB：等同于PIPES_AS_CONCAT、ANSI_QUOTES、IGNORE_SPACE、NO_KEY_OPTIONS、 NO_TABLE_OPTIONS、 NO_FIELD_OPTIONS和 NO_AUTO_CREATE_USER的组合。
 
疑问：

> 如何为sql_mode中添加多个选项？Re：在 SET GLOBAL sql_mode时，设置的值为多个选项的逗号(,)拼接

## 4. 日期和时间类型

MySQL中有 5 种与日期和时间相关的类型：

* datetime：8字节
	* 包含：日期、时间
	* 范围为“1000-01-01 00:00:00”到“9999-12-31 23:59:59”
* timestamp：4字节
	* 包含：日期、时间
	* 与 datetime样式相同，都为：“YYYY-MM-DD HH:MM:SS”
	* 建表时，可设置默认值
* year：1字节
	* 范围：1901~2155 （1个字节，256个数）
	* 设置显示宽度YEAR(4)：1901~2155 ；YEAR(2)：1970~2069
* date：3字节
* time：3字节

### 4.1. DATETIME & DATE

关于对秒后小数的支持情况：

* 精确到秒：MySQL 5.5版本之前（包括5.5版本），数据库的日期类型不能精确到微秒级别，任何的微秒数值都会被数据库截断，
* 精确到微秒：MySQL 5.6.4版本开始，MySQL增加了对秒的小数部分（fractional second）的支持
	* 语法：time(6)，timestamp(6), datatime(6)，其中，6表示秒之后的小数位数，6表示到微秒
	* 其中，秒之后的小数，默认为0，最大为6
	* 时间函数，如CURTIME（）、SYSDATE（）和UTC_TIMESTAMP（）也增加了对小数的支持
* MariaDB 5.3+ 就已经支持秒的小数部分

### 4.2. TIMESTAMP

timestamp & datetime 不同之处：

* 显示范围不同，timestamp范围小
* 存储占用字节不同：datetime，8字节，timestamp，3字节
* 建表时，timestamp 可以设置默认值：
	* TIMESTAMP DEAFULT CURRENT_TIMESTAMP
	* TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
* 如果设置字段 field TIMESTAMP ON UPDATE CURRENT_TIMESTAMP，则，仅当当前记录更新时，才会更改此字段时间
* 通常设置：field TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP

### 4.3. YEAR & TIME

TIME类型占用3字节，显示的范围为“-838：59：59”～“838：59：59”。有人会奇怪为什么TIME类型的时间可以大于23。因为TIME类型不仅可以用来保存一天中的时间，也可以用来保存时间间隔，同时这也解释了为什么TIME类型也可以存在负值。和DATETIME类型一样，TIME类型同样可以显示微秒时间，但是在插入时，数据库同样会进行截断操作。

### 4.4. 日期、时间相关的函数

`NOW`、`CURRENT_TIMESTAMP`和`SYSDATE` 差异：

* CURRENT_TIMESTAMP是NOW的同义词，也就是说两者是相同的。
* SYSDATE函数返回的是执行到当前函数时的时间，而NOW返回的是执行SQL语句时的时间。

## 5. 数值类型

### 5.1. 整型

常用的几种整型字段类型：

* TINYINT：1 字节
	* 范围：-128 ~ 127，0~255
* SMALLINT：2 字节
	* 范围：-32768 ~ 32767，0~65535
* MEDIUMINT：3 字节
	* 范围：800万
* INT：4 字节
	* 范围：21亿
* BIGINT：8 字节
	* 范围：太大了
* 特别说明：为字段添加 `ZEROFILL`（0填充）属性时，MySQL为字段自动添加属性 `UNSIGNED`。

### 5.2. 浮点型（非精确类型）

MySQL数据库支持两种浮点类型：单精度的FLOAT类型及双精度的DOUBLE PRECISION类型。这两种类型都是非精确的类型，经过一些操作后并不能保证运算的正确性，例如M*G/G不一定等于M，虽然数据库内部算法已经使其尽可能的正确，但是结果还会有偏差。

注：

> FLOAT、DOUBLE PRECISION，浮点类型，非精确。

### 5.3. 高精度类型

DECIMAL和NUMERIC类型在MySQL中被视为相同的类型，用于保存必须为确切精度的值，举例：

> salary DECIMAL(5,2)

在上述例子中，5是精度，2是标度。精度表示保存值的主要位数，标度表示小数点后面可以保存的位数。在标准SQL中，语法DECIMAL（M）等价于DECIMAL（M,0）。在MySQL 5.5中M的默认值是10.

### 5.4. 位类型

位类型，即BIT数据类型可用来保存位字段的值。BIT（M）类型表示允许存储M位数值，M范围为1到64，占用的空间为（M+7）/8字节。如果为BIT（M）列分配的值的长度小于M位，在值的左边用0填充。例如，为BIT（6）列分配一个值b'101'，其效果与分配b'000101'相同。要指定位值，可以使用b'value'符，例如：

```
mysql> CREATE TABLE t ( a BIT(4));
mysql> INSERT INTO t SELECT b'1000';
```

但是直接用SELECT进行查看会出现如下情况：

```
mysql> SELECT * FROM t;
```

这个值似乎是空的，其实不然，因为采用位的存储方式，所以不能直接查看，可能需要做类似如下的转化：

```
mysql> SELECT HEX(a) FROM t;
```

## 6. 字符类型（todo）

### 6.1. 字符集

建议使用utf8，方便进行国际化。

Unicode vs. utf8



## 实践

### int相关


在MySQL中 int 的 最大值可以看成 2 个：

* 无符号的：2147483647，
	* 4byte，2的32次方，
	* 无符号的设定是：`unsigned`
* 有符号的：4294967295




|类型 |字节 |最小值 |最大值|
|---|---|---|---|
| 	  |     |(带符号的/无符号的) |(带符号的/无符号的)|
|TINYINT |1 |-128 |127 |
| 	  | 	  |0 |255|
|SMALLINT |2 |-32768 |32767|
| 	  | 	  |0 |65535|
|MEDIUMINT |3 |-8388608 |8388607|
| 	  | 	  |0 |16777215|
|INT |4 |-2147483648 |2147483647|
|	   | 	  |0 |4294967295|
|BIGINT |8 |-9223372036854775808 |9223372036854775807|
| 	  |	   |0 |18446744073709551615|


补充：

* bigint已经有长度了，在mysql建表中的length，只是用于显示的位数；
* 创建id的时候会给主键 、unsigned 、auto_increment  然后其他表与该表的id字段进行连接，注意最大值为 4294967295（42亿）


int类型为4字节，那`int(5)`的含义是什么？实际上`int(5)`与字段值的范围无关，仅表示显示效果。参考：[详解mysql int类型的长度值问题]。

### date、datetime、timestamp

几点：

* 几个时间相关字段类型的差异；
* Java中对应的类型；*（Hibernate、MyBatis等对应的VO）*

todo：

* [MySQL数据库和Java的时间类型详细解析][MySQL数据库和Java的时间类型详细解析]
* char\varchar\text, [http://www.cnblogs.com/billyxp/p/3548540.html](http://www.cnblogs.com/billyxp/p/3548540.html)








## 参考来源

* [MySQL reference Manual - Chapter 11 Data Types][MySQL reference Manual - Chapter 11 Data Types]
* [http://www.cnblogs.com/billyxp/p/3548540.html](http://www.cnblogs.com/billyxp/p/3548540.html)





[NingG]:    												http://ningg.github.com  "NingG"
[MySQL reference Manual - Chapter 11 Data Types]:			http://dev.mysql.com/doc/refman/5.6/en/data-types.html
[MySQL数据库和Java的时间类型详细解析]:						http://database.51cto.com/art/201005/202730.htm



[详解mysql int类型的长度值问题]:				http://www.2cto.com/database/201208/150865.html





