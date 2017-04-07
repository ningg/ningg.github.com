---
layout: post
title: Nginx 系列：Nginx 实践，location 路径匹配
description: Location 路径匹配，优先级怎么确定？
category: nginx
---

## 1. 目标

nginx 反向代理，路径映射的过程是什么？如何配置路径映射规则？

## 2. location 路径匹配

### 2.1. 匹配规则

location 路径正则匹配：

|符号|说明|
|---|---|
|`~`|正则匹配，区分大小写|
|`~*`|正则匹配，不区分大小写|
|`^~`|普通字符匹配，如果该选项匹配，则，只匹配改选项，不再向下匹配其他选项|
|`=`|普通字符匹配，精确匹配|
|`@`|定义一个命名的 location，用于内部定向，例如 error_page，try_files|

### 2.2. 匹配优先级

路径匹配，优先级：（跟 location 的书写顺序关系不大）

1. **精确匹配**：`=`前缀的指令严格匹配这个查询。如果找到，停止搜索。
1. **普通字符匹配**：所有剩下的常规字符串，最长的匹配。如果这个匹配使用`^〜`前缀，搜索停止。
1. **正则匹配**：正则表达式，在配置文件中定义的顺序，匹配到一个结果，搜索停止；
1. **默认匹配**：如果第3条规则产生匹配的话，结果被使用。否则，如同从第2条规则被使用。
 
### 2.3. 举例

通过一个实例，简单说明一下匹配优先级：

```
location  = / {
  # 精确匹配 / ，主机名后面不能带任何字符串
  [ configuration A ]
}
 
location  / {
  # 因为所有的地址都以 / 开头，所以这条规则将匹配到所有请求
  # 但是正则和最长字符串会优先匹配
  [ configuration B ]
}
 
location /documents/ {
  # 匹配任何以 /documents/ 开头的地址，匹配符合以后，还要继续往下搜索
  # 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
  [ configuration C ]
}
 
location ~ /documents/Abc {
  # 匹配任何以 /documents/ 开头的地址，匹配符合以后，还要继续往下搜索
  # 只有后面的正则表达式没有匹配到时，这一条才会采用这一条
  [ configuration CC ]
}
 
location ^~ /images/ {
  # 匹配任何以 /images/ 开头的地址，匹配符合以后，停止往下搜索正则，采用这一条。
  [ configuration D ]
}
 
location ~* \.(gif|jpg|jpeg)$ {
  # 匹配所有以 gif,jpg或jpeg 结尾的请求
  # 然而，所有请求 /images/ 下的图片会被 config D 处理，因为 ^~ 到达不了这一条正则
  [ configuration E ]
}
 
location /images/ {
  # 字符匹配到 /images/，继续往下，会发现 ^~ 存在
  [ configuration F ]
}
 
location /images/abc {
  # 最长字符匹配到 /images/abc，继续往下，会发现 ^~ 存在
  # F与G的放置顺序是没有关系的
  [ configuration G ]
}
 
location ~ /images/abc/ {
  # 只有去掉 config D 才有效：先最长匹配 config G 开头的地址，继续往下搜索，匹配到这一条正则，采用
    [ configuration H ]
}
 
location ~* /js/.*/\.js
```

按照上面的location写法，以下的匹配示例成立：

1. `/` -> config A：精确完全匹配，即使/index.html也匹配不了
1. `/downloads/download.html` -> config B：匹配B以后，往下没有任何匹配，采用B
1. `/images/1.gif` -> configuration D：匹配到F，往下匹配到D，停止往下
1. `/images/abc/def` -> config D：最长匹配到G，往下匹配D，停止往下你可以看到 任何以/images/开头的都会匹配到D并停止，FG写在这里是没有任何意义的，H是永远轮不到的，这里只是为了说明匹配顺序
1. `/documents/document.html` -> config C：匹配到C，往下没有任何匹配，采用C
1. `/documents/1.jpg` -> configuration E：匹配到C，往下正则匹配到E
1. `/documents/Abc.jpg` -> config CC：最长匹配到C，往下正则顺序匹配到CC，不会往下到E


## 3. 参考资料

* [nginx location](http://nginx.org/en/docs/http/ngx_http_core_module.html#location)
* [http://seanlook.com/2015/05/17/nginx-location-rewrite/](http://seanlook.com/2015/05/17/nginx-location-rewrite/)







[NingG]:    http://ningg.github.com  "NingG"
[Nginx开发从入门到精通]:		http://tengine.taobao.org/book/
[nginx doc]:		https://nginx.org/en/docs/
[nginx source code]:		https://github.com/nginx/nginx







