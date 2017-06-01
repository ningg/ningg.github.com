---
layout: post
title: Spring 源码：Validation, Data binding, Type Conversion
description: Spring 框架下，数据校验、数据绑定的实现机制
published: true
category: spring
---

## 1. Data binding（数据绑定）

### 1.1. 目标

解决几个问题：

1. HTTP 请求，携带的参数都是字符串，如何转换为 Date、Enum 等对象？
1. HTTP 请求，携带的参数之间并没有层级关系，如何在数据绑定时，将参数绑定到一个 Object 内？

### 1.2. 简介

todo：整体流程、使用的主要组件/类。

分析：进行数据绑定、类型转换，有几个问题

1. 输入参数名称：http 请求中 request param
1. 输入参数类型：字符串
1. 目标对象名称：java object 的名称
1. 目标对象类型：java object 对应的 Class
 
JDK 自带：

1. java.beans.PropertyEditor：属性编辑器接口
1. java.beans.PropertyEditorSupport：属性编辑器基础实现类

Spring 中扩展：

1. org.springframework.beans.PropertyEditorRegistry：为不同 java 对象，绑定对应的属性编辑器
 
简单描述一下：

![](/images/spring-framework/data-binding-demo.png)

### 1.3. JDK 中基础机制

#### 1.3.1. PropertyEditor（接口）

java.beans.PropertyEditor：属性编辑器，将 String → 相应的 java 对象

1. setAsText(String)：字符串，转换为 java 对象。
 
![](/images/spring-framework/PropertyEditor.png)
 
#### 1.3.2. PropertyEditorSupport（类）

java.beans.PropertyEditorSupport：属性编辑器基础实现类，实现 String → String 对象之间的转换。

其中 2 个属性：

1. value：Object，对象的取值
1. source：Object，监听对象属性变更的对象？细节还需要再确定

![](/images/spring-framework/PropertyEditorSupport.png)

Spring 中实现了很多属性编辑器，都在 org.springframework.beans.propertyeditors 包中：

![](/images/spring-framework/propertyeditors.png)


以上述 CustomDateEditor 属性编辑器为例，具体字符串→ 对象转换的代码为：

![](/images/spring-framework/CustomDateEditor.png)


#### 1.3.3. 典型示例

com.sun.beans.editors.LongEditor 类，实现 String → Long 类型之间的转换。

示例代码：

```
package com.sun.beans.editors;
 
import com.sun.beans.editors.NumberEditor;
 
public class LongEditor extends NumberEditor {
    public LongEditor() {
    }
 
    public String getJavaInitializationString() {
        Object var1 = this.getValue();
        return var1 != null?var1 + "L":"null";
    }
 
    public void setAsText(String var1) throws IllegalArgumentException {
        this.setValue(var1 == null?null:Long.decode(var1));
    }
}
```
 
### 1.4. Spring 中扩展机制

#### 1.4.1. PropertyEditorRegistry （接口）

org.springframework.beans.PropertyEditorRegistry：为不同 java 对象，绑定对应的属性编辑器

![](/images/spring-framework/PropertyEditorRegistry.png)

#### 1.4.2. PropertyEditorRegistrySupport（类）

PropertyEditorRegistry 接口的基础实现类，其中会为 Class 绑定默认的属性编辑器：

![](/images/spring-framework/PropertyEditorRegistry-second.png)

#### 1.4.3. TypeConverter接口

类型转换接口。 通过该接口，可以将value转换为requiredType类型的对象。

![](/images/spring-framework/TypeConverter.png)
　　
#### 1.4.4. TypeConverterSupport：

TypeConverter基础实现类，并继承了PropertyEditorRegistrySupport　　
　　有个属性typeConverterDelegate，类型为TypeConverterDelegate，TypeConverterSupport将类型转换委托给typeConverterDelegate操作。

#### 1.4.5. TypeConverterDelegate

类型转换委托类。具体的类型转换操作由此类完成。

#### 1.4.6. SimpleTypeConverter

TypeConverterSupport的子类，使用了PropertyEditorRegistrySupport(父类TypeConverterSupport的父类PropertyEditorRegistrySupport)中定义的默认属性编辑器。

#### 1.4.7. PropertyAccessor接口

对类中属性操作的接口。

#### 1.4.8. BeanWrapper接口

　　继承ConfigurablePropertyAccessor(继承PropertyAccessor、PropertyEditorRegistry、TypeConverter接口)接口的操作Spring中JavaBean的核心接口。

#### 1.4.9. BeanWrapperImpl类

　　BeanWrapper接口的默认实现类，TypeConverterSupport是它的父类，可以进行类型转换，可以进行属性设置。

#### 1.4.10. DataBinder类

实现PropertyEditorRegistry、TypeConverter的类。支持类型转换，参数验证，数据绑定等功能。

有个属性SimpleTypeConverter，用来进行类型转换操作。

#### 1.4.11. WebDataBinder

DataBinder的子类，主要是针对Web请求的数据绑定。

![](/images/spring-framework/DataBinder.png)

### 1.5. 数据绑定的过程

Spring MVC 运行过程中：

1. 程序入口在 DispatcherServlet
1. DispatcherServlet 依赖 HandlerMapping 定位到具体的 Controller 和 其内部的 Method
1. 然后，利用 HandlerAdaptor，在 Method 执行之前，会进行数据绑定
 
![](/images/spring-framework/spring-mvc-arch.png)

其中，DispatcherServlet 默认的 HandlerAdaptor 如下（DispatcherServlet.properties 文件）：

```
...
  
   org.springframework.web.servlet.HandlerAdapter=org.springframework.web.servlet.mvc.HttpRequestHandlerAdapter,\
   org.springframework.web.servlet.mvc.SimpleControllerHandlerAdapter,\
   org.springframework.web.servlet.mvc.annotation.AnnotationMethodHandlerAdapter
...
```

![](/images/spring-framework/AnnotationMethodHandlerAdapter.png)
 

直接查看 RequestMappingHandlerAdapter 中针对数据绑定的处理：

![](/images/spring-framework/RequestMappingHandlerAdapter.png)

### 1.6. 自定义 PropertyEditor

针对 Enum 类型的属性编辑器：

1. com.sun.beans.editors.EnumEditor：JDK 自带
1. 默认情况下，Spring MVC 并没有为 Enum 类型指定 PropertyEditor

疑问：

> 如何查看 Spring MVC 默认绑定的 PropertyEditor？

com.sun.beans.editors.EnumEditor 代码如下：

```
// 使用 Enum 中 name 属性匹配 Enum，没有使用 ordinal 属性。
public void setAsText(String var1) {
    this.setValue(var1 != null?Enum.valueOf(this.type, var1):null);
}
```

备注：Enum 中自带属性 String:name，int:ordinal。

上面 EnumEditor 只能针对 name 来匹配具体的 Enum，而现实场景中，更多的是希望，能够同时兼容 name 和 ordinal 来匹配 Enum，因此，需要自定义一个 EnumProperty：

```
package com.meituan.movie.pro;
 
import java.beans.PropertyEditorSupport;
import org.apache.commons.lang3.StringUtils;
 
public class CaseInsensitiveConverter<T extends Enum<T>> extends PropertyEditorSupport {
 
    private final Class<T> typeParameterClass;
 
    public CaseInsensitiveConverter(Class<T> typeParameterClass) {
        super();
        this.typeParameterClass = typeParameterClass;
    }
 
    @Override
    public void setAsText(final String text) throws IllegalArgumentException {
        // 优先使用 ordinal 匹配
        if (StringUtils.isNumeric(text)) {
            setValue(typeParameterClass.getEnumConstants()[Integer.valueOf(text)]);
        } else {
            // 其次使用 name 匹配
            String upper = text.toUpperCase();
            T value = T.valueOf(typeParameterClass, upper);
            setValue(value);
        }
    }
}
```
 
SpringMVC中使用自定义的属性编辑器有3种方法：

方法一：Controller方法中添加@InitBinder注解的方法

```
@InitBinder
public void initBinder(WebDataBinder binder) {
    binder.registerCustomEditor(CheckStatusEnum.class, new CaseInsensitiveConverter<>(CheckStatusEnum.class));
}
```

方法二：实现WebBindingInitializer接口

```
public class MyWebBindingInitializer implements WebBindingInitializer {
   
  @Override
  public void initBinder(WebDataBinder binder, WebRequest request) {
    binder.registerCustomEditor(CheckStatusEnum.class, new CaseInsensitiveConverter<>(CheckStatusEnum.class));
  }
   
}
```

之前分析源码的时候，HandlerAdapter构造WebDataBinderFactory的时候，会传递HandlerAdapter的属性webBindingInitializer。

因此，我们在配置文件中构造RequestMappingHandlerAdapter的时候传入参数webBindingInitializer。

 
方法三：@ControllerAdvice注解

```
@ControllerAdvice
public class CustomDataBinder {
 
    @InitBinder
    public void initBinder(WebDataBinder binder) {
        binder.registerCustomEditor(CheckStatusEnum.class, new CaseInsensitiveConverter<>(CheckStatusEnum.class));
    }

}
```

加上ControllerAdvice别忘记配置文件component-scan需要扫描到这个类。

Note：必须指定到具体的类，使用泛型或者父类无效，例如下面的配置无效：

```
binder.registerCustomEditor(Enum.class, new CaseInsensitiveConverter<>(Enum.class));
```

## 2. Type Conversion（类型转换）

Type Conversion 是 PropertyEditor 进行数据绑定的一种补充，本质都是：String → Java Object

Type Conversion 有 3 个接口，都可以进行 Type Conversion：

1. Converter：针对具体 Class 进行类型转换；
1. ConverterFactory：可以针对 base class，对一类 Class 进行转换；
1. GenericFactory：可扩展性更强，比如，可以根据 Field 上的 Annotation 来动态选择类型转换的方法；

但是 Type Conversion 的可扩展性非常好，比如支持，针对一个基类的统一转换，例如，使用 ConverterFactory 进行 String → Enum ：

```
public class CustomEnumConverterFactory implements ConverterFactory<String, Enum<?>> {
 
    @Override
    public <T extends Enum<?>> Converter<String, T> getConverter(final Class<T> targetType) {
        return new StringToEnumConverter<>(targetType);
    }
 
    private final class StringToEnumConverter<T extends Enum> implements Converter<String, T> {
        private Class<T> enumType;
 
        public StringToEnumConverter(Class<T> enumType) {
            this.enumType = enumType;
        }
 
        public T convert(String source) {
            if (StringUtils.isNumeric(source)) {
                return enumType.getEnumConstants()[Integer.valueOf(source)];
            }
            return (T) Enum.valueOf(this.enumType, source.trim());
        }
    }
}
```

上面自定义了 Converter，需要 spring-mvc.xml 进行如下配置，才会生效：(3 类接口都可以配置)

```
<bean id="conversionService" class="org.springframework.format.support.FormattingConversionServiceFactoryBean">
    <property name="converters">
        <set>
            <bean class="com.meituan.movie.pro.web.converter.CustomEnumConverterFactory" />
        </set>
    </property>
</bean>
  
<mvc:annotation-driven conversion-service="conversionService">
    ...
</mvc:annotation-driven>
```

 
## 3. Formatter（类型转换，本地化定制）

背景：

1. 同一个 String → Java Object，因为所处 Client 不同，所以 String 的格式不同，因此，需要个性化的配置。
1. 举例：String → Date，有的地方 String 为 20161010 格式，有的为 2016-10-10，而我们要求这些格式，都能转换为正确的 Date。

Spring 提供 Formatter 机制，来解决这类问题，默认提供了 2 个注解：

1. DateTimeFormat
1. NumberFormat

## 4. Validation（数据校验）


一般在数据绑定之后，一般会对输入数据进行校验，检查用户的输入是否正确。

### 4.1. 数据校验过程

整体分为 2 个步骤：

1. 数据校验：校验数据是否满足约束条件，如果不满足约束，则将具体信息收集到 Errors/BindingResult 对象中；
1. 消息转换：将 Errors/BindingResult 对象中包含的绑定异常信息，转换为定制的可读信息；

![](/images/spring-framework/validation-total-process.png)

### 4.2. 最佳实践

#### 4.2.1. 开启数据校验

Spring MVC 工程中，默认开启数据校验，直接在 Controller 中使用如下设置：

```
@RestController("demandController")
@RequestMapping("/api")
public class DemandController {
  
   ...
  
    @RequestMapping(value = "/demand/create.json", method = RequestMethod.POST)
    Map<String, Object> createDemand(@Validated DemandParam param, BindingResult result, @ModelAttribute("User") User user) {
        ...
    }
  
   ...
}
```

其中， DemandParam 源码如下：

```
public class DemandParam {
 
    private long demandId;
    @Min(value = 1)
    @Max(value = Integer.MAX_VALUE)
    @NotNull
    private long projectId;
    @NotBlank(message = "参数错误")
    private String position;// 职位
    @NotBlank(message = "参数错误")
    private String language;// 语言
    @Min(value = 0)
    @Max(value = Integer.MAX_VALUE)
    @NotNull
    private Integer cityId;// 城市
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    @NotNull(message = "参数错误")
    private Date startDate;// 工作周期
  
    ... // getter and setter
  
}
```
 
上述方法的输入参数：

```
@Validated DemandParam param, BindingResult result
```

就表示对 DemandParam 中参数进行校验，并且把校验结果绑定到 BindingResult 中，BindingResult 必须紧跟在 Validated Object 之后，因为可能会有多个 Validated Object 相互之间的 BindingResult 是隔离的，具体参考：[mvc-ann-methods](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/mvc.html#mvc-ann-methods)


> The Errors or BindingResult parameters have to follow the model object that is being bound immediately as the method signature might have more than one model object and Spring will create a separate BindingResult instance for each of them.

Note：

1. @Validated DemandParam 后面，显式捕获 BindingResult， 则：
	1. DemandParam 中数据校验，有异常，则，进入 method，可以通过 BindingResult 获取异常
	1. DemandParam 中数据校验，没有异常，则，进入 method，正常执行；
1. @Validated DemandParam 后面，非显式捕获 BindingResult， 则：
	1. DemandParam 中数据校验，有异常，则，抛出 BindExecption，但会被 DispatcherServlet.properties 中，配置的 HandlerExceptionResolver 转换为：向 Client 返回 400，并且 Log 输出数据校验异常信息
	1. DemandParam 中数据校验，没有异常，则，进入 method，正常执行；

考虑：

1. 是否可以通过 ControllerAdvice 提前针对 BindingResult 处理？
1. @Validated 的处理逻辑，发生在哪个时刻？

todo：补充处理 BindingResult 的ControllerAdvice

### 4.3. 进行异常转换

上面的处理中，我们已经能够进行数据校验，并且获取了校验结果，如何将校验结果对象，转换为更易于理解的内容？

整体上，有 3 条，可用路径：

1. 显式捕获 BindingResult：在业务逻辑中，处理数据绑定的异常；
1. 非显式捕获 BindingResult：利用 Spring MVC 提供的 HandlerExceptionResolver 处理 BindingResult 对应的 BindException；
1. 非显示捕获 BindingResult + 定制（推荐*）：利用 ControllerAdvice + ExceptionHandler 方式，单独处理 BindException；

具体效果如下：

![](/images/spring-framework/data-binding-result.png)



### 4.4. 使用示例

在 spring-mvc.xml 中添加如下配置：

```
<!-- 校验错误提示消息 -->
<bean id="messageSource" class="org.springframework.context.support.ReloadableResourceBundleMessageSource">
    <property name="basenames">
        <list>
            <value>classpath:messages</value>
        </list>
    </property>
    <property name="useCodeAsDefaultMessage" value="false"/>
    <property name="defaultEncoding" value="UTF-8"/>
    <property name="cacheSeconds" value="60"/>
</bean>
  
<!--校验 Bean-->
<bean id="validator" class="org.springframework.validation.beanvalidation.LocalValidatorFactoryBean">
    <property name="providerClass" value="org.hibernate.validator.HibernateValidator"/>
    <property name="validationMessageSource" ref="messageSource"/>
</bean>
 
<!-- 指定 Validator -->
<mvc:annotation-driven validator="validator" >
    ...
</mvc:annotation-driven>
```

定制 ExceptionHandler：

```
import java.util.Map;
 
import org.springframework.validation.BindException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
 
@ControllerAdvice("com.meituan.movie.pro")
public class ExceptionHandlerDeltaAdvice {
    @ExceptionHandler(BindException.class)
    @ResponseBody
    public Map<String, Object> makeExceptionResponse(BindException e) {
        // todo: 对 BindException 进行转换.
        return null;
    }
}
```

Controller 的 method 入口非显式捕获 BindingResult：

```
@RequestMapping(value = "/demand/create.json", method = RequestMethod.POST)
public Map<String, Object> createDemand(@Validated DemandParam param, @ModelAttribute("User") User user) {
    // todo: do something.
}
```

Note：

1. @Validated 、@NotBlank 等注解中，都可以设置 group 属性，则，只针对匹配到相应 group 的成员变量进行校验。

## 5. 小结

本质：String → Java Object

![](/images/spring-framework/data-binging-high-level-demo.png)
 
具体，有 3 中方法：

![](/images/spring-framework/three-impl-demo.png)

## 6. 参考资料

* [Spring Reference](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/validation.html)
* [Spring MVC annotation](http://docs.spring.io/spring/docs/current/spring-framework-reference/html/mvc.html#mvc-ann-methods)
* [BindingResult](http://stackoverflow.com/q/29432717)
* [Spring data binding and type convert](http://www.cnblogs.com/fangjian0423/p/springMVC-databind-typeconvert.html#introduction)
* [http://jinnianshilongnian.iteye.com/blog/1723270](http://jinnianshilongnian.iteye.com/blog/1723270)












[NingG]:    http://ningg.github.com  "NingG"










