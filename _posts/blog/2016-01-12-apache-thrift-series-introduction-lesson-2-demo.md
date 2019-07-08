---
layout: post
title: Apache Thrift：入门实例
description: 尝试编写一个 Thrift 的入门实例，走一遍流程
published: true
category: thrift
---



## 1. 入门实例

下面所有步骤都参考于 [http://thrift.apache.org/](http://thrift.apache.org/)

### 1.1. 下载 & 安装 Apache Thrift

下载 Apache Thrift ：[http://thrift.apache.org/download](http://thrift.apache.org/download)

Mac 下，使用如下方式安装 Apache Thrift：

```
$ brew install thrift
```
 
### 1.2. 创建 IDL 文件

根据 Thrift 的 IDL 文件规范 [http://diwakergupta.github.io/thrift-missing-guide/thrift.pdf](http://diwakergupta.github.io/thrift-missing-guide/thrift.pdf)，编写 IDL 文件 `Hello.thrift`：

```
namespace java com.meituan.guoning.learn
 
service Hello{
 string helloString(1:string param)
 i32 helloInt(1:i32 param)
 bool helloBoolean(1:bool param)
 void helloVoid()
 string helloNull()
}
```

其中定义了 5 个方法，每个方法都包含：

1. 返回值类型
1. 方法名
1. 参数列表：每个参数都包含参数序号、参数类型以及参数名称

### 1.3. 编译生成模板文件

使用 thrift 编译 `Hello.thrift` 文件：

```
thrift -r --gen java Hello.thrift
```

编译之后生成 `Hello.java` 文件，其中包含：

1. `Hello.Iface`：Hello 服务，同步调用接口
1. `Hello.AsyncIface`：Hello 服务，异步调用接口
1. `Hello.Client`：客户端，同步调用逻辑，实现 Iface 接口
1. `Hello.AsyncClient`：客户端，异步调用逻辑，实现 AsyncIface 接口
1. `Hello.Processor`：服务器端，同步处理逻辑
1. `Hello.AsyncProcessor`：服务器端，异步处理逻辑

部分代码如下：

```
public class Hello {
​
​
// Iface 同步调用接口
​
  public interface Iface {
​
    public String helloString(String param) throws org.apache.thrift.TException;
​
    public int helloInt(int param) throws org.apache.thrift.TException;
​
    public boolean helloBoolean(boolean param) throws org.apache.thrift.TException;
​
    public void helloVoid() throws org.apache.thrift.TException;
​
    public String helloNull() throws org.apache.thrift.TException;
​
  }
​
​
// AsyncIface 异步调用接口
​
  public interface AsyncIface {
​
    public void helloString(String param, org.apache.thrift.async.AsyncMethodCallback resultHandler) throws org.apache.thrift.TException;
​
    public void helloInt(int param, org.apache.thrift.async.AsyncMethodCallback resultHandler) throws org.apache.thrift.TException;
​
    public void helloBoolean(boolean param, org.apache.thrift.async.AsyncMethodCallback resultHandler) throws org.apache.thrift.TException;
​
    public void helloVoid(org.apache.thrift.async.AsyncMethodCallback resultHandler) throws org.apache.thrift.TException;
​
    public void helloNull(org.apache.thrift.async.AsyncMethodCallback resultHandler) throws org.apache.thrift.TException;
​
  }
​
​
// Client，客户端同步调用，实现 Iface 接口
​
  public static class Client extends org.apache.thrift.TServiceClient implements Iface {
    public static class Factory implements org.apache.thrift.TServiceClientFactory<Client> {
      public Factory() {}
      public Client getClient(org.apache.thrift.protocol.TProtocol prot) {
        return new Client(prot);
      }
      public Client getClient(org.apache.thrift.protocol.TProtocol iprot, org.apache.thrift.protocol.TProtocol oprot) {
        return new Client(iprot, oprot);
      }
    }
​
    public Client(org.apache.thrift.protocol.TProtocol prot)
    {
      super(prot, prot);
    }
​
    public Client(org.apache.thrift.protocol.TProtocol iprot, org.apache.thrift.protocol.TProtocol oprot) {
      super(iprot, oprot);
    }
​
    public String helloString(String param) throws org.apache.thrift.TException
    {
      send_helloString(param);
      return recv_helloString();
    }
 
...
 
  }
 
// AsyncClient，客户端异步调用，实现 AsyncIface 接口
 
public static class AsyncClient extends org.apache.thrift.async.TAsyncClient implements AsyncIface {
  public static class Factory implements org.apache.thrift.async.TAsyncClientFactory<AsyncClient> {
    private org.apache.thrift.async.TAsyncClientManager clientManager;
    private org.apache.thrift.protocol.TProtocolFactory protocolFactory;
    public Factory(org.apache.thrift.async.TAsyncClientManager clientManager, org.apache.thrift.protocol.TProtocolFactory protocolFactory) {
      this.clientManager = clientManager;
      this.protocolFactory = protocolFactory;
    }
    public AsyncClient getAsyncClient(org.apache.thrift.transport.TNonblockingTransport transport) {
      return new AsyncClient(protocolFactory, clientManager, transport);
    }
  }
​
  public AsyncClient(org.apache.thrift.protocol.TProtocolFactory protocolFactory, org.apache.thrift.async.TAsyncClientManager clientManager, org.apache.thrift.transport.TNonblockingTransport transport) {
    super(protocolFactory, clientManager, transport);
  }
​
  public void helloString(String param, org.apache.thrift.async.AsyncMethodCallback resultHandler) throws org.apache.thrift.TException {
    checkReady();
    helloString_call method_call = new helloString_call(param, resultHandler, this, ___protocolFactory, ___transport);
    this.___currentMethod = method_call;
    ___manager.call(method_call);
  }
 
...
 
 }
 
// Processor，服务器端同步处理，需传入接口 Iface 的实现
 
public static class Processor<I extends Iface> extends org.apache.thrift.TBaseProcessor<I> implements org.apache.thrift.TProcessor {
  private static final Logger LOGGER = LoggerFactory.getLogger(Processor.class.getName());
  public Processor(I iface) {
    super(iface, getProcessMap(new HashMap<String, org.apache.thrift.ProcessFunction<I, ? extends org.apache.thrift.TBase>>()));
  }
​
  protected Processor(I iface, Map<String,  org.apache.thrift.ProcessFunction<I, ? extends  org.apache.thrift.TBase>> processMap) {
    super(iface, getProcessMap(processMap));
  }
​
  private static <I extends Iface> Map<String,  org.apache.thrift.ProcessFunction<I, ? extends  org.apache.thrift.TBase>> getProcessMap(Map<String,  org.apache.thrift.ProcessFunction<I, ? extends  org.apache.thrift.TBase>> processMap) {
    processMap.put("helloString", new helloString());
    processMap.put("helloInt", new helloInt());
    processMap.put("helloBoolean", new helloBoolean());
    processMap.put("helloVoid", new helloVoid());
    processMap.put("helloNull", new helloNull());
    return processMap;
  }
​
  public static class helloString<I extends Iface> extends org.apache.thrift.ProcessFunction<I, helloString_args> {
    public helloString() {
      super("helloString");
    }
​
    public helloString_args getEmptyArgsInstance() {
      return new helloString_args();
    }
​
    protected boolean isOneway() {
      return false;
    }
​
    public helloString_result getResult(I iface, helloString_args args) throws org.apache.thrift.TException {
      helloString_result result = new helloString_result();
      result.success = iface.helloString(args.param);
      return result;
    }
  }
​
  ...
​
}
​
​
// AsyncProcessor，服务器端异步处理，需传入 AsyncIface 接口的实现
​
public static class AsyncProcessor<I extends AsyncIface> extends org.apache.thrift.TBaseAsyncProcessor<I> {
  private static final Logger LOGGER = LoggerFactory.getLogger(AsyncProcessor.class.getName());
  public AsyncProcessor(I iface) {
    super(iface, getProcessMap(new HashMap<String, org.apache.thrift.AsyncProcessFunction<I, ? extends org.apache.thrift.TBase, ?>>()));
  }
​
  protected AsyncProcessor(I iface, Map<String,  org.apache.thrift.AsyncProcessFunction<I, ? extends  org.apache.thrift.TBase, ?>> processMap) {
    super(iface, getProcessMap(processMap));
  }
​
  private static <I extends AsyncIface> Map<String,  org.apache.thrift.AsyncProcessFunction<I, ? extends  org.apache.thrift.TBase,?>> getProcessMap(Map<String,  org.apache.thrift.AsyncProcessFunction<I, ? extends  org.apache.thrift.TBase, ?>> processMap) {
    processMap.put("helloString", new helloString());
    processMap.put("helloInt", new helloInt());
    processMap.put("helloBoolean", new helloBoolean());
    processMap.put("helloVoid", new helloVoid());
    processMap.put("helloNull", new helloNull());
    return processMap;
  }
​
  public static class helloString<I extends AsyncIface> extends org.apache.thrift.AsyncProcessFunction<I, helloString_args, String> {
    public helloString() {
      super("helloString");
    }
​
    public helloString_args getEmptyArgsInstance() {
      return new helloString_args();
    }
​
    public AsyncMethodCallback<String> getResultHandler(final AsyncFrameBuffer fb, final int seqid) {
      final org.apache.thrift.AsyncProcessFunction fcall = this;
      return new AsyncMethodCallback<String>() { 
        public void onComplete(String o) {
          helloString_result result = new helloString_result();
          result.success = o;
          try {
            fcall.sendResponse(fb,result, org.apache.thrift.protocol.TMessageType.REPLY,seqid);
            return;
          } catch (Exception e) {
            LOGGER.error("Exception writing to internal frame buffer", e);
          }
          fb.close();
        }
        public void onError(Exception e) {
          byte msgType = org.apache.thrift.protocol.TMessageType.REPLY;
          org.apache.thrift.TBase msg;
          helloString_result result = new helloString_result();
          {
            msgType = org.apache.thrift.protocol.TMessageType.EXCEPTION;
            msg = (org.apache.thrift.TBase)new org.apache.thrift.TApplicationException(org.apache.thrift.TApplicationException.INTERNAL_ERROR, e.getMessage());
          }
          try {
            fcall.sendResponse(fb,msg,msgType,seqid);
            return;
          } catch (Exception ex) {
            LOGGER.error("Exception writing to internal frame buffer", ex);
          }
          fb.close();
        }
      };
    }
​
    protected boolean isOneway() {
      return false;
    }
​
    public void start(I iface, helloString_args args, org.apache.thrift.async.AsyncMethodCallback<String> resultHandler) throws TException {
      iface.helloString(args.param,resultHandler);
    }
  }
​
  ...
​
  }
​
}
```

**补充**：可以在 `Hello.thrift` 文件所在目录创建 `pom.xml` 文件，方便查看生成的 Java 文件，`pom.xml` 文件内容如下：

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.meituan.guoning.learn</groupId>
    <artifactId>thrift</artifactId>
    <version>0.0.1-SNAPSHOT</version>
​
    <dependencies>
        <dependency>
            <groupId>org.apache.thrift</groupId>
            <artifactId>libthrift</artifactId>
            <version>0.9.3</version>
        </dependency>
    </dependencies>
​
</project>
```

### 1.4. 编写服务器端处理逻辑

上面生成的 `Hello.java` 代码只是一个模板，还需要编写具体的服务器端处理逻辑。

编写文件 `HelloServiceImpl.java` 文件，并实现 `Hello.java` 文件中的 `Hello.Iface` 接口，代码如下：

```
public class HelloServiceImpl implements Hello.Iface {
    @Override
    public String helloString(String param) throws TException {
        System.out.println("Input String is: " + param);
        return param;
    }
​
    @Override
    public int helloInt(int param) throws TException {
        return param;
    }
​
    @Override
    public boolean helloBoolean(boolean param) throws TException {
        return param;
    }
​
    @Override
    public void helloVoid() throws TException {
        System.out.println("Hello Void!");
    }
​
    @Override
    public String helloNull() throws TException {
        return null;
    }
}
```
​
创建服务器端代码，将 `HelloServiceImpl.java` 作为具体的处理器传递给 Thrift 服务器，代码如下：

```
public class HelloServiceServer {
    /**
     * 启动 Thrift 服务器
     * 
     * @param args
     */
    public static void main(String[] args) {
​
        int port = 7911;
​
        try {
​
            // 服务器地址为本地,端口号为 port.
            TServerTransport serverTransport = new TServerSocket(port);
            // 关联处理器与 Hello 服务的实现
            TProcessor processor = new Hello.Processor<>(new HelloServiceImpl());
            // 实例化服务器
            TServer server = new TSimpleServer(new TServer.Args(serverTransport).processor(processor));
​
            // Use this for a multithreaded server
            // TServer server = new TThreadPoolServer(new TThreadPoolServer.Args(serverTransport).processor(processor));
​
            System.out.println("Start Server on port " + port + "....");
            server.serve();
        } catch (TTransportException e) {
            e.printStackTrace();
        }
​
    }
}
```

创建客户端代码，调用 `Hello.Client` 访问服务器的服务，代码如下：

```
public class HelloServiceClient {
​
    private static String EXIT_INPUT = "exit";
​
    /**
     * 调用 Hello 服务
     */
    public static void main(String[] args) {
        String serverIp = "localhost";
        int serverPort = 7911;
​
        try {
            // 设置调用服务的地址
            TTransport transport = new TSocket(serverIp, serverPort);
            transport.open();
​
            TProtocol protocol = new TBinaryProtocol(transport);
            Hello.Client client = new Hello.Client(protocol);
​
            // 调用 helloVoid 方法
            client.helloVoid();
​
            String input = "";
            Scanner scanner = new Scanner(System.in);
​
            while (!EXIT_INPUT.equalsIgnoreCase(input)) {
                input = scanner.nextLine();
                System.out.println(client.helloString(input));
            }
            transport.close();
​
        } catch (TTransportException e) {
            e.printStackTrace();
        } catch (TException e) {
            e.printStackTrace();
        }
​
    }
}
```


## 2. 参考资料

* [http://thrift.apache.org/](http://thrift.apache.org/)
* [https://www.ibm.com/developerworks/cn/java/j-lo-apachethrift/](https://www.ibm.com/developerworks/cn/java/j-lo-apachethrift/)：部分内容已经过时


























[NingG]:    http://ningg.github.com  "NingG"










