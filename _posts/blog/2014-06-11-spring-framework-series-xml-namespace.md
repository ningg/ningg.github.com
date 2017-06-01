---
layout: post
title: Spring 源码：Namespace XML
description: Spring 框架下，namespace xml 的作用和底层实现
published: true
category: spring
---

## 1. 目标

着重几个基本问题：

1. Spring 配置文件中，不同namespace 背后的处理逻辑？
1. 使用不同 namespace 的好处？
1. 什么场景下，使用 namespace ？
1. 如何自定义 namespace ?

描述的问题，形象一点就是：

![](/images/spring-framework/xml-namespace-result.png)

## 2. 背景

Spring 中，定义和配置 Bean， 最直接的方式，使用下面的代码片段：

```
<beans xmlns="http://www.springframework.org/schema/beans"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-4.1.xsd">
 
    <!--传统定义 bean 的方式-->
    <bean id="medis" class="com.meituan.cache.redisCluster.client.MedisBean">
        <property name="authDao" ref="zkAuthDao" />
        <property name="poolId" value="${cache_medis_pool}" />
        <property name="authKey" value="${cache_medis_authKey}" />
    </bean>
  
</beans>
```

针对一些 Bean，配置很复杂，这就需要调用方进行复杂的配置，很不方便，因此，Spring 2.0+ 后，支持用户自定义 schema 文件，来进行复杂 Bean 的自动配置。

使用自定义 schema 文件向 Spring IoC 中注入 Bean，需要涉及几个方面：

1. 自定义 schema 文件
1. 编写 Spring bean definition 解析器
1. 将 Spring bean definition 解析器，集成到 Spring IoC 容器中

## 3. 自定义 schema 文件

自定义 schema 文件，实现复杂 bean 的自动配置，基本步骤：

1. 编写 schema 文件
1. 自定义 NamespaceHandler 的实现类
1. 自定义 BeanDefinitionParser 的实现类
1. 将上述 2 个自定义类，注册到 Spring 框架，使其生效

### 3.1. 极简实例

目标：定义一个 java.text.SimpleDateFormat 的 Bean。

预期结果：在 spring bean 配置文件中，使用如下配置，即可创建 java.text.SimpleDateFormat 的 Bean。

```
<myns:dateformat id="defaultDateFormat" pattern="yyyy-MM-dd HH:mm" lenient="true"/>
```


#### 3.1.1. 整体目录结构

![](/images/spring-framework/xml-namespace-sketch.png)

#### 3.1.2. 编写 schema 文件

编写 schema 文件：`myns.xsd`

```
<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema xmlns="http://www.mycompany.com/schema/myns"
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            xmlns:beans="http://www.springframework.org/schema/beans"
            targetNamespace="http://www.mycompany.com/schema/myns"
            elementFormDefault="qualified"
            attributeFormDefault="unqualified">
 
    <xsd:import namespace="http://www.springframework.org/schema/beans"/>
 
    <xsd:element name="dateformat">
        <xsd:complexType>
            <xsd:complexContent>
                <xsd:extension base="beans:identifiedType">
                    <xsd:attribute name="lenient" type="xsd:boolean"/>
                    <xsd:attribute name="pattern" type="xsd:string" use="required"/>
                </xsd:extension>
            </xsd:complexContent>
        </xsd:complexType>
    </xsd:element>
</xsd:schema>
```

#### 3.1.3. 编写 NamespaceHandler

NamespaceHandler 作用：解析 schema 文件中定义的元素，例如 解析`<myns:dateformat />` 元素。

```
package top.ningg.spring.schema.handler;
 
import org.springframework.beans.factory.xml.NamespaceHandlerSupport;
 
import top.ningg.spring.schema.parser.SimpleDateFormatBeanDefinitionParser;
 
public class MyNamespaceHandler extends NamespaceHandlerSupport {
 
    @Override
    public void init() {
        registerBeanDefinitionParser("dateformat", new SimpleDateFormatBeanDefinitionParser());
    }
 
}
```

#### 3.1.4. 编写 BeanDefinitionParser

BeanDefinitionParser 作用：解析指定的元素，例如，解析`<myns:dateformat />` 元素的 BeanDefinitionParser 代码如下：

```
package top.ningg.spring.schema.parser;
 
import java.text.SimpleDateFormat;
 
import org.springframework.beans.factory.support.BeanDefinitionBuilder;
import org.springframework.beans.factory.xml.AbstractSingleBeanDefinitionParser;
import org.springframework.util.StringUtils;
import org.w3c.dom.Element;
 
public class SimpleDateFormatBeanDefinitionParser extends AbstractSingleBeanDefinitionParser {
 
    @Override
    protected Class getBeanClass(Element element) {
        return SimpleDateFormat.class;
    }
 
    @Override
    protected void doParse(Element element, BeanDefinitionBuilder bean) {
        // this will never be null since the schema explicitly requires that a
        // value be supplied
        String pattern = element.getAttribute("pattern");
        bean.addConstructorArgValue(pattern);
 
        // this however is an optional property
        String lenient = element.getAttribute("lenient");
        if (StringUtils.hasText(lenient)) {
            bean.addPropertyValue("lenient", Boolean.valueOf(lenient));
        }
    }
 
}
```

**备注**：补充说明，上述 SimpleDateFormatBeanDefinitionParser 实现了 2 个方法：getBeanClass 和 doParse，这是因为 Spring 中使用了大量的模板模式的缘故，而实际上 BeanDefinitionParser 只需要提供 parse() 方法即可。
 
![](/images/spring-framework/bean-definition-parser-class-view.png)

#### 3.1.5. 为 schema 文件绑定 NamespaceHandler

已经准备好了 schema 文件和 NamespaceHandler 处理类，如何让 Spring 识别呢？

Spring 规定：在 META-INF 文件夹下，新建 2 个特殊的配置文件，来注册 schema 文件和 NamespaceHandler 处理类。

1. `META-INF`/`spring.schemas`：namespace 的 xsd 文件，设置本地文件，避免 Spring 从网络获取 xsd 文件。
1. `META-INF`/`spring.handlers`：为 namespace 绑定 NamespaceHandler

当前实例中，spring.shcemas 文件内容如下：

```
http\://www.mycompany.com/schema/myns/myns-1.0.xsd=top/ningg/spring/schema/xsd/myns.xsd
```

spring.handlers 文件内容如下：

```
http\://www.mycompany.com/schema/myns=top.ningg.spring.schema.handler.MyNamespaceHandler
```

其中：

1. http://www.mycompany.com/schema/myns 为 xsd 文件中设定的 namespace
1. http://www.mycompany.com/schema/myns/myns-1.0.xsd 为 spring 配置文件中，为上述 namespace 绑定的校验文件

#### 3.1.6. 使用

上面完成的 namespace 的定义，如何实际使用呢？

1. 发布自定义 namespace 的工程：在上述工程中，执行 mvn deploy，部署 jar 包
1. 在 Spring 工程中：
	1. pom.xml 中，引入依赖的 jar 包
	1. 在 Spring 配置文件中，引入 namespace

本例中，在 Spring 配置文件中，引入 namespace 如下：

```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:myns="http://www.mycompany.com/schema/myns"
       xsi:schemaLocation="
        http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.mycompany.com/schema/myns http://www.mycompany.com/schema/myns/myns-1.0.xsd">
 
    <!-- as a top-level bean -->
    <myns:dateformat id="defaultDateFormat" pattern="yyyy-MM-dd HH:mm" lenient="true"/>
 
</beans>
```

**特别说明**：此处 namespace 和 xsd 文件 url 路径，已经要跟 spring.schemas 和 spring.handlers 文件中的配置保持一致，完全一致。
 
## 4. 特别说明

上面是针对 Spring 中完整 bean 的定义，实际上，也可以针对先有 bean 的属性进行定义。

## 5. 参考来源

1. [Extensible XML authoring](http://docs.spring.io/spring/docs/current/spring-framework-reference/htmlsingle/#xml-custom)
1. [http://stackoverflow.com/q/11174286](http://stackoverflow.com/q/11174286)
1. [http://stackoverflow.com/q/10768873](http://stackoverflow.com/q/10768873)


## 6. 附录

思考：

1. 上述 schema 文件执行的时间？在 bean 生命周期中的位置？context 初始化的时候？
1. Bean 生命周期的切入点，实践分析时，参考调度框架 Crane 的实现




[NingG]:    http://ningg.github.com  "NingG"










