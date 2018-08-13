---
layout: post
title: Spring Boot 系列：Spring Boot Starter
description: Spring Boot Starter，有什么用？如何编写？基本工作原理？
published: true
category: spring boot
---


## 概要

Spring Boot Starter 几个常见疑问：

* 有什么用？
* 如何编写？
* 基本工作原理？


## 有什么用

Maven 管理的 Java 项目，通过将 `层` 以及 `通用组件` 拆分为 `模块`， 实现代码的组织管理和依赖复用。

Spring Boot 体系下，使用 **Spring Boot Starter** 进行`依赖复用`。

## 如何编写

几个方面：

1. `pom.xml` 配置：`命名` & `依赖`
1. **Service 服务**：要生效的`服务`
1. **Properties 属性**：服务依赖的`属性`
1. **Configuration 配置**：Service 生效的`条件`校验

当前部分，将讲解编写一个实例：

> 实现一个 WrapService：
> 
> 1. 对输入的 `字符串`， 增加 `前缀`和`后缀`
> 2. `前缀`和`后缀` 在不同环境中，可以进行差异化配置
> 3. 有些环境初始化 WrapService，有些环境不初始化

下文，完整的代码，看这里：

* [github.com/ningg/spring-boot-starter-learn](github.com/ningg/spring-boot-starter-learn)

### pom 配置

创建一个 `pom.xml` ：

```
<?xml version="1.0" encoding="UTF-8"?>

<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>top.ningg.spring</groupId>
    <artifactId>learn-spring-boot-starter</artifactId>
    <version>1.0-SNAPSHOT</version>

    <name>learn-spring-boot-starter</name>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>

    <dependencies>
        <!--Spring Boot Starter: START-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
            <scope>test</scope>
        </dependency>
        <!--Spring Boot Starter: END-->

        <!--Spring Boot auto config: START-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-autoconfigure</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-configuration-processor</artifactId>
            <optional>true</optional>
        </dependency>
        <!--Spring Boot auto config: END-->

        <!--Spring Boot starter test: START-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <!--Spring Boot starter test: END-->
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <!-- Import dependency management from Spring Boot -->
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>1.5.2.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

</project>
```

说一下上面 `artifactId` 的命名，官方建议：

* **官方 starter** 命名：`spring`-`boot`-`starter`-`{name}`，例如 spring-boot-starter-web
* **非官方 starter** 命名：`{name}`-`spring`-`boot`-`starter` 格式

更多细节： 

* [Spring Boot Reference Guide] 中 `Creating Your Own Starter` 部分

### 创建 Service

创建 Service 的接口类：

```
/**
 * 为字符串,增加前缀和后缀.
 */
public interface IWrapService {


    /**
     * 为字符串增加前缀和后缀.
     *
     * @param word 输入的字符串.
     * @return 增加了前缀和后缀的字符串.
     */
    String wrap(String word);

}
```

Service 的实现类：

```
public class WrapServiceImpl implements IWrapService {

    private String prefix;
    private String suffix;

    public WrapServiceImpl(String prefix, String suffix) {
        this.prefix = prefix;
        this.suffix = suffix;
    }

    @Override
    public String wrap(String word) {
        return prefix + word + suffix;
    }
}
```

### 编写 Properties 属性

Serivce 中，可能需要读取外部属性配置，编写 properties 属性：

```
/**
 * WrapService 配置的属性.
 */
@ConfigurationProperties("wrap.service")
public class WrapServiceProperties {

    // 前缀
    private String prefix;
    // 后缀
    private String suffix;

    public String getPrefix() {
        return prefix;
    }

    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    public String getSuffix() {
        return suffix;
    }

    public void setSuffix(String suffix) {
        this.suffix = suffix;
    }
}
```

Note: `@ConfigurationProperties` 会从 `application-*.yml` or `application-*.properties` 中读取属性.

### configutation 配置

只在某些条件下，才会进行 Serivce 的实例化，因此，需要 Configuration 配置参数。

```
/**
 * WrapService 的配置对象
 */
@Configuration
@ConditionalOnClass(WrapServiceImpl.class)
@EnableConfigurationProperties(WrapServiceProperties.class)
public class WrapServiceConfiguration {

    @Autowired
    private WrapServiceProperties properties;

    @Bean
    @ConditionalOnMissingBean
    @ConditionalOnProperty(prefix = "wrap.service", value = "enabled", havingValue = "true")
    IWrapService wrapService() {
        return new WrapServiceImpl(properties.getPrefix(), properties.getSuffix());
    }

}
```

关于上述 Configuration 配置的条件：

* `@ConditionalOnClass`，当 classpath 下发现该类的情况下，进行自动配置。
* `@ConditionalOnMissingBean`，当Spring Context中，不存在该 Bean 时。
* `@ConditionalOnProperty`(prefix = "wrap.service",value = "enabled",havingValue = "true")，当配置文件中 `wrap.service.enabled=true` 时。

更多细节，参考：

* [Spring Boot Reference Guide] 中 `Condition Annotations` 部分


### 配置入口类

最后一步，在`resources/META-INF/` 下创建 `spring.factories` 文件，内容参考：

```
org.springframework.boot.autoconfigure.EnableAutoConfiguration=top.ningg.spring.config.WrapServiceConfiguration
```

上述配置，用于指定 Spring Boot 工程启动过程中，需要扫描的配置类。

更多细节，参考：

* [Spring Boot Reference Guide] 中 `Creating Your Own Auto-configuration` 部分.

### 发布依赖

直接 `mvn:install` or `mvn:deploy` 发布依赖包。

## 总结

总结下 Starter 的工作原理：

1. Spring Boot 在启动时，扫描项目所依赖的JAR包，寻找包含 `spring.factories` 文件的JAR包
1. 根据 `spring.factories` 配置，加载 `AutoConfigure` 类
1. 在 `AutoConfigure` 类中，根据 `@Conditional` 注解的条件，进行自动配置并将Bean注入Spring Context



## 参考资料

* [快速开发一个自定义Spring Boot Starter](https://www.jianshu.com/p/45538b44e04e)
* [官网：Creating Your Own Auto-configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-developing-auto-configuration.html)
* [Spring Boot Reference Guide]


[NingG]:    http://ningg.github.com  "NingG"
[Spring Boot Reference Guide]:		https://docs.spring.io/spring-boot/docs/current/reference/html/










