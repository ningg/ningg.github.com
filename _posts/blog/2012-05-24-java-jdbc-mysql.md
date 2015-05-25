---
layout: post
title: JDBC，Statement、PreparedStatement
description: Java操作数据库基本过程，Statement、PreparedStatement之间差异
published: true
categories: MySQL java
---



几点：

* JDBC是什么？
* Java操作MySQL数据库的基本过程
* Statement、PrepearedStatement之间比较

todo：

* 数据库连接池；
* Spring对JDBC的支持；

todo 参考：

* [数据库系列](http://sharryjava.iteye.com/category/55314)


##JDBC

JDBC(Java Database Connectivity)，Java 数据库连接API，本质是Sun公司定义的一套接口规范，即，通过调用哪些确定的方法即可实现对数据库的操作。JDBC产生的原因很简单：

* 不同的数据库，原理之间有差异，操作命令也有差异；
* 如果针对不同的数据库，编写的Java代码也不同，这样Java代码可移植性很差；
* Java语言设计者，希望通过相同的Java代码操作不同的数据库，增强程序通用性；
* Java语言设计者，设定了一套标准的数据库操作API，JDBC API；
* 各个数据库厂商，根据自身特点，提供JDBC Driver的具体实现；
	* MySQL，官网提供了[JDBC Driver for MySQL][JDBC Driver for MySQL]
	* SQL Server，官网提供了[JDBC Driver for SQL Server][JDBC Driver for SQL Server]

Tips：

> JDBC就是Java操作数据库的API，是Java标准类库的扩展，目的：JDBC开发的java程序能够跨平台运行，不受数据库的限制。


##JDBC实现原理

JDBC由 3 部分实现：

* JDBC API: 应用程序对JDBC Driver Manager之间的接口；
* JDBC Driver Manager：管理不同的JDBC Driver；
* JDBC Driver API: JDBC Driver Manager对JDBC Driver之间接口；

此外，不同数据库厂商，根据自身特点，提供具体JDBC Driver的实现，这一JDBC Driver满足JDBC Driver API即可。这样JDBC Driver就可以注册到JDBC Driver Manager了。

JDBC Driver Manager可确保使用正确的JDBC Driver来访问每个数据源。JDBC Driver Manager能够支持连接到多个异构数据库的多个并发的JDBC Driver。**Java应用程序中，只需要调用JDBC API就可以实现对异构数据库的访问，每次切换数据库时，只需要改变JDBC Driver Manager加载的JDBC Driver名称即可，不需要修改Java代码**。

![](/images/java-jdbc-mysql/jdbc-framework.png)


另外，ODBC是Microsoft为C语言访问数据库提供的一套编程接口。如果数据库供应商只提供了ODBC驱动器。那么可以通过JDBC-ODBC桥来进行连接。



##Java操作数据库的基本过程

Java操作MySQL数据库的基本过程：

* 连接到数据库
* 创建SQL语句
* 执行SQL语句
* 查看SQL执行结果
* 关闭连接

###添加依赖的JDBC Driver jar包

直接从[JDBC Driver for MySQL]中下载安装程序，或者从[Maven中央仓库](http://repo1.maven.org/maven2/mysql/mysql-connector-java/) 中下载mysql-connector-java-5.1.34.jar，并将此jar包添加到 Build Path 中。

如果使用Maven管理工程，则在pom.xml中添加如下依赖：

	<dependency>
		<groupId>mysql</groupId>
		<artifactId>mysql-connector-java</artifactId>
		<version>5.1.34</version>
	</dependency>

###编写示例代码

按照上述 5 个步骤，创建连接、编写SQL、执行、处理结果、释放连接，具体示例代码如下：


	package test;

	import java.sql.Connection;
	import java.sql.DriverManager;
	import java.sql.Statement;
	import java.sql.ResultSet;


	public class TestJDBC {
		
		public static void main(String[] args) {
			Connection conn = null;
			Statement st = null;
			ResultSet rs = null;
			String driverClassName = "com.mysql.jdbc.Driver";
			String url = "jdbc:mysql://168.7.2.167:3306/studentmgr";
			String username = "root";
			String password = "root";
			
			try{
				Class.forName(driverClassName);	// 加载JDBC Driver
				conn = DriverManager.getConnection(url, username, password);// 建立连接
				
				st = conn.createStatement();// 创建SQL
				String sql = "SELECT * FROM STUDENT";
				rs = st.executeQuery(sql);// 执行SQL
				
				while (rs.next()) {	// 处理结果
					System.out.println(rs.getString("name"));
				}
			} catch(Exception exp){
				exp.printStackTrace();
			} finally {
				
				try {
					if (rs != null) {
						rs.close();
					}
					
					if(st != null){
						st.close();
					}
					
					if(conn != null){
						conn.close();
					}
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
		}
	}

Tips：

> 上述操作涉及的DriverManager、Connection、Statement、ResultSet，都是`java.sql.*`。


##Statement、PreparedStatement之间差异


Statement的用法：

	Statement st = con.createStatement();
	String query = "INSERT INTO Testing(Id) VALUES(" + 2 + ")";	// 拼接SQL
	st.executeUpdate(query);


PreapredStatement的用法：

	PreparedStatement pst = con.prepareStatement("INSERT INTO Authors(Name) VALUES(?)");
	pst.setString(1, author);
	pst.executeUpdate();

总结一下两者之间的差异：

* PreparedStatement，通过set方法设置执行的SQL，代码可读性和可维护性好；
* PreparedStatement，可防止SQL注入攻击；
* 预编译，性能好；

















##参考来源



* [JDBC原理解析][JDBC原理解析] *(系列)*
* [JDBC Driver for MySQL][JDBC Driver for MySQL]
* [JDBC Driver for SQL Server][JDBC Driver for SQL Server]
* [JDBC4简介，JDBC是什么？][JDBC4简介，JDBC是什么？]
* [什么是JDBC][什么是JDBC]
* [jdbc编程基础（一）——jdbc是什么][jdbc编程基础（一）——jdbc是什么]
* [JDBC常见面试题集锦(一)][JDBC常见面试题集锦(一)]
* [An Introduction to Java Database (JDBC) Programming][An Introduction to Java Database (JDBC) Programming]
* [JDBC为什么要使用PreparedStatement而不是Statement][JDBC为什么要使用PreparedStatement而不是Statement]



[NingG]:    http://ningg.github.com  "NingG"
[JDBC Driver for MySQL]:			http://www.mysql.com/products/connector/
[JDBC Driver for SQL Server]:		https://msdn.microsoft.com/zh-cn/data/aa937724.aspx


[JDBC4简介，JDBC是什么？]:			http://www.yiibai.com/jdbc/jdbc-introduction.html
[什么是JDBC]:						http://yde986.iteye.com/blog/900373
[jdbc编程基础（一）——jdbc是什么]:	http://sharryjava.iteye.com/blog/325872
[JDBC常见面试题集锦(一)]:			http://it.deepinmind.com/jdbc/2014/03/18/JDBC%E5%B8%B8%E8%A7%81%E9%9D%A2%E8%AF%95%E9%A2%98%E9%9B%86%E9%94%A6%28%E4%B8%80%29.html


[An Introduction to Java Database (JDBC) Programming]:		http://www.ntu.edu.sg/home/ehchua/programming/java/JDBC_Basic.html#zz-3.1
[JDBC为什么要使用PreparedStatement而不是Statement]:		http://www.importnew.com/5006.html
[JDBC原理解析]:						http://blog.csdn.net/luanlouis/article/category/2158459


