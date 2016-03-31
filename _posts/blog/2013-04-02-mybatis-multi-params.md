---
layout: post
title: MyBatis传多个参数
description: 几种方式
published: true
category: mybatis
---


## 直接使用索引


DAO层的函数方法：

	Public User selectUser(String name,String area);
	
对应的Mapper.xml：

	<select id="selectUser" resultMap="BaseResultMap">
		select  *  from user_user_t 
			where user_name = #{0} and user_area = #{1}
	</select>

其中，`#{0}`代表接收的是dao层中的第一个参数，`#{1}`代表dao层中第二参数，更多参数一致往后加即可。


## DAO层通过Map传参

此方法采用Map传多参数.

Dao层的函数方法：

	public User selectUser(Map paramMap);
	
对应的Mapper.xml：

	<select id=" selectUser" resultMap="BaseResultMap">
	   select  *  from user_user_t  
		where user_name = #{userName，jdbcType=VARCHAR} 
			and user_area = #{userArea, jdbcType=VARCHAR}
	</select>

Service层调用：

	Private User xxxSelectUser(){
	   Map paramMap=new hashMap();
	   paramMap.put(“userName”,”对应具体的参数值”);
	   paramMap.put(“userArea”,”对应具体的参数值”);
	   User user=xxx.selectUser(paramMap);}
	}
	
个人认为此方法不够直观，见到Dao层接口方法，不能直接的知道要传的参数是什么。*（Service层可以看出参数的含义）*


## Dao层注解方式

Dao层的函数方法：

	public User selectUser(@param(“userName”)String name,@param(“userArea”)String area);

对应的Mapper.xml：

	<select id=" selectUser" resultMap="BaseResultMap">
	   select  *  from user_user_t  
		  where user_name = #{userName, jdbcType=VARCHAR} 
		    and user_area = #{userArea, jdbcType=VARCHAR}
	</select> 

个人觉得这种方法比较好，能让开发者看到dao层方法就知道该传什么样的参数，比较直观，个人推荐用此种方案。













## 参考来源

* [Mybatis传多个参数（三种解决方案）][Mybatis传多个参数（三种解决方案）]








[NingG]:    http://ningg.github.com  "NingG"

[Mybatis传多个参数（三种解决方案）]:				http://www.2cto.com/database/201409/338155.html









