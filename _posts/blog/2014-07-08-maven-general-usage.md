---
layout: post
title: Maven 的常见问题和用法
description: 常见问题和用法汇总
published: true
category: maven
---

### 设置 JDK 版本

pom.xml 中添加如下配置：


```
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.5.1</version>
            <configuration>
                <!-- or whatever version you use -->
                <source>${jdk.version}</source>
                <target>${jdk.version}</target>
            </configuration>
        </plugin>
    </plugins>
</build>

```


### 把整个工程编译为一个 jar 包

pom.xml 中添加如下配置：

```
<build>  
    <plugins>  
  
        <plugin>  
            <groupId>org.apache.maven.plugins</groupId>  
            <artifactId>maven-assembly-plugin</artifactId>  
            <version>2.5.5</version>  
            <configuration>
                <!-- Main 函数入口，可以删除：START -->
                <archive>  
                    <manifest>  
                        <mainClass>com.xxg.Main</mainClass>  
                    </manifest>  
                </archive>
                <!-- Main 函数入口，可以删除：END -->
                <descriptorRefs>  
                    <descriptorRef>jar-with-dependencies</descriptorRef>  
                </descriptorRefs>  
            </configuration>  
        </plugin>  
  
    </plugins>  
</build>  

```

然后执行命令： 

```
mvn package assembly:single  
```

打包后会在`target`目录下生成一个`xxx-jar-with-dependencies.jar`文件，这个文件不但包含了自己项目中的代码和资源，还包含了所有依赖包的内容。所以可以直接通过`java -jar`来运行。


更多信息，参考：

* [Maven 进阶--- 打成包含依赖的jar包](https://blog.csdn.net/u014430366/article/details/76060366)




































[NingG]:    http://ningg.github.com  "NingG"










