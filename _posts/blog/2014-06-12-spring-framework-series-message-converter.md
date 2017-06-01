---
layout: post
title: Spring 源码：MessageConverter
description: Spring 框架下，数据类型转换，底层实现机制
published: true
category: spring
---

## 1. 目标

Spring MVC 中， HttpServletResponse 从 Object 转换为 JSON 字符串：

1. 具体依赖 Spring MVC 的哪个机制？
1. 代码层级实现细节？
1. HttpServletResponse 是否可以转换为 XML ？或者其他形式？

## 2. 概述

为什么需要 Spring MessageConverter 机制，解决什么问题？

### 2.1. 最原始的 Servlet 接口

HTTP 请求-响应的基本过程：HTTP 协议规定， HTTP 请求和响应本质都是一堆字符串，或者说字节流。

Servlet 规范中，为 HTTP 请求和响应提供了对应的接口：

javax.servlet.ServletRequest接口中方法：

```
// 获取的 ServletInputStream中，可以读取到一个原始请求报文的所有内容.
public ServletInputStream getInputStream() throws IOException;
```

javax.servlet.ServletResponse接口中方法：

```
// ServletOutputStream，用于输出 HTTP 的响应报文内容.
public ServletOutputStream getOutputStream() throws IOException;
```

也就是说，Servlet 中：

1. HTTP 原始请求字符串，自动封装为 ServletInputStream，供我们读取；
1. HTTP 响应，会封装为 ServletOutputStream ，供我们输出响应报文；

特别说明，我们从 InputStream 中只能读取原始的报文内容，同理，也只能想 OutputStream 中写入原始的报文内容。

在 Java 领域内，都是针对Object（对象）进行处理的，因此，一个最朴素的问题不可避免：字符串与Java 对象之间的相互转换。

如果每次都需要手动进行：字符串与 Java 对象的转换，肯定不符合工程师的理念，因为人很懒，所以 Spring 中提供 MessageConverter 机制，来解决相互转换问题。

备注：

1. Spring MVC 中，针对 HTTP 请求的 MessageConverter 机制的具体实现是 HttpMessageConverter 接口。
1. Spring MVC 中，现在只支持 HttpMessageConverter 机制，暂时不支持其他方式的消息转化。

### 2.2. HttpMessageConverter 简述

查看 HttpMessageConverter，其中包含几个主要接口：

```
public interface HttpMessageConverter<T> {
  
    // Indicates whether the given class can be read by this converter.
    boolean canRead(Class<?> clazz, MediaType mediaType); 
  
    // Indicates whether the given class can be written by this converter.
    boolean canWrite(Class<?> clazz, MediaType mediaType); 
  
    // Return the list of {@link MediaType} objects supported by this converter.
    List<MediaType> getSupportedMediaTypes(); 
  
    // Read an object of the given type form the given input message, and returns it.
    T read(Class<? extends T> clazz, HttpInputMessage inputMessage); 
  
    // Write an given object to the given output message.
    void write(T t, MediaType contentType, HttpOutputMessage outputMessage)
  
}
```

Spring MVC 中，HTTP 的请求和响应，分别被封装为 HttpInputMessage 和 HttpOutputMessage。

HttpMessageConverter接口的定义出现了成对的canRead()，read()和canWrite()，write()方法，MediaType是对请求的Media Type属性的封装。举个例子，当我们声明了下面这个处理方法。

```
@RequestMapping(value="/string", method=RequestMethod.POST)
public @ResponseBody String readString(@RequestBody String string) {
    return "Read string '" + string + "'";
}
```

具体执行过程：

1. 在SpringMVC进入readString方法前，会根据@RequestBody注解选择适当的HttpMessageConverter实现类来将请求参数解析到string变量中，具体来说是使用了StringHttpMessageConverter类，它的canRead()方法返回true，然后它的read()方法会从请求中读出请求参数，绑定到readString()方法的string变量中。
1. 当SpringMVC执行readString方法后，由于返回值标识了@ResponseBody，SpringMVC将使用StringHttpMessageConverter的write()方法，将结果作为String值写入响应报文，当然，此时canWrite()方法返回true。

图示如下：

![](/images/spring-framework/http-message-converter.png)
 
HttpMessageConverter 接口，具体进行报文和 java 对象转换的时候，依赖 org.springframework.web.servlet.mvc.method.annotation.RequestResponseBodyMethodProcessor，具体 UML 图如下：

![](/images/spring-framework/request-response-body-method-processor.png)

即，RequestResponseBodyMethodProcessor 实现了 HandlerMethodArgumentResolver 和 HandlerMethodReturnValueHandler 两个接口。其代码中，关键的接口：
 
```
/**
 * Resolves method arguments annotated with {@code @RequestBody} and handles
 * return values from methods annotated with {@code @ResponseBody} by reading
 * and writing to the body of the request or response with an
 * {@link HttpMessageConverter}.
 *
 * <p>An {@code @RequestBody} method argument is also validated if it is
 * annotated with {@code @javax.validation.Valid}. In case of validation
 * failure, {@link MethodArgumentNotValidException} is raised and results
 * in a 400 response status code if {@link DefaultHandlerExceptionResolver}
 * is configured.
 *
 * @since 3.1
 */
public class RequestResponseBodyMethodProcessor extends AbstractMessageConverterMethodProcessor {
  
    @Override
    public boolean supportsParameter(MethodParameter parameter) {
       return parameter.hasParameterAnnotation(RequestBody.class);
    }
 
    @Override
    public boolean supportsReturnType(MethodParameter returnType) {
        return (AnnotationUtils.findAnnotation(returnType.getContainingClass(), ResponseBody.class) != null ||
            returnType.getMethodAnnotation(ResponseBody.class) != null);
    }
  
    ...
     
    @Override
    public void handleReturnValue(Object returnValue, MethodParameter returnType,
        ModelAndViewContainer mavContainer, NativeWebRequest webRequest)
        throws IOException, HttpMediaTypeNotAcceptableException {
 
        mavContainer.setRequestHandled(true);
        if (returnValue != null) {
            // 使用了「模板模式」，真是的处理细节在下面方法内
            writeWithMessageConverters(returnValue, returnType, webRequest);
        }
    }
  
    ...
  
}
```

## 3. Response 转换为 JSON 机制分析

先说一点结论，然后，逐步去看代码：

1. Spring 配置文件中，开启 mvc 配置，具体，添加语句： `<mvc:annotation-driven />`
1. Controller 中通过在 Method/Class 层级添加注解 @ResponseBody 来标识 response 需要转换为 JSON
1. Response 转换为 XML 过程跟转换为 JSON 过程基本类似

### 3.1. Spring MVC 的启动设置

通过添加语句： `<mvc:annotation-driven />`，即可开启 MVC 配置，其背后的基本处理逻辑参考：Spring Namespace XML

下面是 mvc:annotation-driven 的典型配置： 

```
<mvc:annotation-driven conversion-service="conversionService">
    <mvc:message-converters register-defaults="false">
        <bean class="com.alibaba.fastjson.support.spring.FastJsonHttpMessageConverter">
            <property name="features">
                <list>
                    <value>DisableCircularReferenceDetect</value>
                    <value>WriteNullListAsEmpty</value>
                    <value>WriteNullStringAsEmpty</value>
                    <value>QuoteFieldNames</value>
                </list>
            </property>
        </bean>
    </mvc:message-converters>
</mvc:annotation-driven>
```

针对上面配置，简要分析一下处理过程：

1. AnnotationDrivenBeanDefinitionParser：解析 annotation-driven 元素
1. RequestMappingHandlerAdapter：具体处理 request / response 请求
1. RequestMappingHandlerAdapter 中 messageConverters，request / response 对象转换。

特别说明： 

1. RequestMappingHandlerAdapter 中 messageConverters 是一个列表（List），会从前向后遍历，如果 response 中 Accept 信息跟 messageConverter 匹配，将不再遍历后面的 messageConverter；
1. message-converters子节点不存在或它的属性register-defaults为true的话，会在  messageConverters 列表末尾，加入其他的转换器：ByteArrayHttpMessageConverter、StringHttpMessageConverter、ResourceHttpMessageConverter等
1. register-defaults="false" 配置，表示只使用配置的 messageConverter，不添加系统自带的 messageConverter；


## 4. 参考资料

1. [消息转换器HttpMessageConverter](http://my.oschina.net/lichhao/blog/172562)
1. [SpringMVC关于json、xml自动转换的原理研究](http://www.cnblogs.com/fangjian0423/p/springMVC-xml-json-convert.html)


## 5. 附录

疑问：

1. RequestResponseBodyMethodProcessor 是如何生效的？
1. Enum 进行序列化的时候，怎么定制？默认返回 ordinal ？

Enum 进行序列化，当使用如下配置时，默认返回 ordinal：

```
<mvc:annotation-driven conversion-service="conversionService">
    <mvc:message-converters register-defaults="false">
        <bean class="com.alibaba.fastjson.support.spring.FastJsonHttpMessageConverter">
            <property name="features">
                <list>
                    <value>DisableCircularReferenceDetect</value>
                    <value>WriteNullListAsEmpty</value>
                    <value>WriteNullStringAsEmpty</value>
                    <value>QuoteFieldNames</value>
                </list>
            </property>
        </bean>
    </mvc:message-converters>
</mvc:annotation-driven>
```

其中，FastJsonHttpMessageConverter 对应的具体 write 方法调用了 SerializeWriter ，针对 Enum 的序列化方法：

```
protected void computeFeatures() {
    quoteFieldNames = (this.features & SerializerFeature.QuoteFieldNames.mask) != 0;
    useSingleQuotes = (this.features & SerializerFeature.UseSingleQuotes.mask) != 0;
    sortField = (this.features & SerializerFeature.SortField.mask) != 0;
    disableCircularReferenceDetect = (this.features & SerializerFeature.DisableCircularReferenceDetect.mask) != 0;
    beanToArray = (this.features & SerializerFeature.BeanToArray.mask) != 0;
    writeNonStringValueAsString = (this.features & SerializerFeature.WriteNonStringValueAsString.mask) != 0;
    notWriteDefaultValue = (this.features & SerializerFeature.NotWriteDefaultValue.mask) != 0;
    writeEnumUsingName = (this.features & SerializerFeature.WriteEnumUsingName.mask) != 0;
    writeEnumUsingToString = (this.features & SerializerFeature.WriteEnumUsingToString.mask) != 0;
 
    writeDirect = quoteFieldNames //
                  && (this.features & nonDirectFeautres) == 0 //
                  && (beanToArray || writeEnumUsingName)
                  ;
 
    keySeperator = useSingleQuotes ? '\'' : '"';
}
```

可以手动配置参数：

* WriteEnumUsingName
* WriteEnumUsingToString

具体序列化的处理过程：

```
public void writeEnum(Enum<?> value) {
    if (value == null) {
        writeNull();
        return;
    }
     
    String strVal = null;
    if (writeEnumUsingName && !writeEnumUsingToString) {
        strVal = value.name();
    } else if (writeEnumUsingToString) {
        strVal = value.toString();;
    }
 
    if (strVal != null) {
        char quote = isEnabled(SerializerFeature.UseSingleQuotes) ? '\'' : '"';
        write(quote);
        write(strVal);
        write(quote);
    } else {
        writeInt(value.ordinal());
    }
}
```

因此，当所有 Enum 序列化的参数都不配置的时候，默认，返回 `Enum.ordinal()`。









[NingG]:    http://ningg.github.com  "NingG"










