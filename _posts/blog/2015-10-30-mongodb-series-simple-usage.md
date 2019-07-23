---
layout: post
title: MongoDB 系列：MongoDB 的简单用法
description: 常用的几个操作
published: true
category: mongodb
---

## 1. 基本操作


### 1.1. 选择 db 和 collection

选择 db 和 collection：

```
// 连接到 mongo
mongo 10.1.200.229:27017/ningg -u *** -p *** -authenticationDatabase admin
 
// 帮助命令
mongos> help
 
// 选择 db 和 collection
mongos> use [db]
```

### 1.2. 查询数据

查询数据：

* [https://docs.mongodb.com/manual/mongo/](https://docs.mongodb.com/manual/mongo/)

 

```
// 查找
mongos> db.mBKBikeInfo.find({"bikeid" : "6021001378"})
 
// 查找一条数据，并结构化输出
mongos> db.mBKBikeInfo.findOne({"bikeid" : "6021001378"})
 
// 查找，并排序
mongos> db.ridingTrackInfo.find({"orderid":"MBK02760302651496740074768"}).sort({"createdate": -1}).limit(2)
 
// 统计
mongos> db.ridingTrackInfo.find({"distance": {$gte: 1000000}}).count();
 
// 复杂查询：前缀匹配、字段缺失
mongos> db.mBKBikeInfo.find({"bikeid" : /^A01/, "locationAccuracy" : {$exists: true}}).count();
```


### 1.3. 更新数据

更新数据：

```
mongos> db.ridingTrackInfo.update({"_id" : NumberLong()},{"$set" : {"trackTime" :""}} )
```

### 1.4. 索引

查看索引：

```
mongos> db.ridingTrackInfo.getIndexes();
[
  {
    "v" : 1,
    "key" : {
      "_id" : 1
    },
    "name" : "_id_",
    "ns" : "ningg.ridingTrackInfo"
  },
  {
    "v" : 1,
    "key" : {
      "orderid" : 1
    },
    "name" : "orderid_1",
    "ns" : "ningg.ridingTrackInfo",
    "background" : true
  },
  {
    "v" : 1,
    "key" : {
      "userid" : 1
    },
    "name" : "userid_1",
    "ns" : "ningg.ridingTrackInfo"
  },
  {
    "v" : 1,
    "key" : {
      "createdate" : 1
    },
    "name" : "createdate_1",
    "ns" : "ningg.ridingTrackInfo"
  }
]
```

几个疑问：

* Java 中 model 字段，跟 MongoDB 的 collection 中字段，如何一一对应？

现有代码：

```
mongos> db.getCollection('ridingTrackInfo').findOne({"orderid": "MBKA0160008961505167559482"})
{
  "_id" : NumberLong(1839391879),
  "_class" : "com.ningg.dao.model.RidingTrackInfo",
  "userid" : "2653293576433289314304886130",
  "track" : "",
  "orderid" : "MBKA0160008961505167559482",
  "createdate" : ISODate("2017-09-12T21:12:39.385Z"),
  "distance" : 64,
  "carbon" : "0.01",
  "times" : NumberLong("1505250759385"),
  "balance" : 0,
  "palat" : 0,
  "trackTime" : "#-77.006392,38.876893;1505250737413#-77.006392,38.876893;1505250737419#-77.006352,38.877142;1505250749357#-77.006238,38.877166;1505250749363#-77.006330,38.877194;1505250750874#-77.006425,38.877201;1505250750930#-77.006517,38.877218;1505250751679",
  "trackImg" : "",
  "bikeid" : "A016000896"
}
``` 

 

## 2. 参考资料

* [https://www.mongodb.com/cn](https://www.mongodb.com/cn)
* [mongo shell](https://docs.mongodb.com/manual/mongo/)
* [http://www.runoob.com/mongodb/mongodb-tutorial.html](http://www.runoob.com/mongodb/mongodb-tutorial.html)










[NingG]:    http://ningg.github.com  "NingG"










