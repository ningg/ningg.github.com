---
layout: post
title: 面向对象设计原则
description: 几条OOP和OOD的原则
published: true
category: object oriented
---


SOLID是面向对象设计和编程（OOD&OOP）中的重要编码原则：

|SRP|The Single Responsibility Principle|单一责任|一个类，有且只有一个更改的原因|
|OCP|The Open Closed Principle|开放封闭|不能修改类，可以扩展类|
|LSP|The Liskov Substitution Principle|里氏替换|子类，可以替换基类|
|ISP|The Interface Segregation Principle|接口分离|细粒度的接口|
|DIP|The Dependency Inversion Principle|依赖反转|依赖抽象而不是具体实现|

额外说几点：

* SOLID原则是 class 级别的，与测试工具一起，更能发挥效力；
* [Object Oriented Design Principles][Object Oriented Design Principles]和[面向对象设计原则和创建SOLID应用的5个方法][面向对象设计原则和创建SOLID应用的5个方法]中有详细的例子，说明代码的书写规范。

##代码腐坏的几个现象：

代码变质，有几个现象：

* 僵化：小的变化，导致整个系统重建；
* 脆弱：一个模块的变化，导致其他不不相关的模块异常。例如，汽车系统中，调整电台会影响到窗户的使用；
* 固定：一个模块，无法被抽取，并且在新环境中重用，例如登录模块，这是由于各个模块之间的耦合和依赖造成的额，改进策略是，从底层细节，比如特定数据库、UI实现、特殊框架等解耦核心对象；
* 粘性：代码构建、测试要花费很长时间；

一个软件项目，满足当前功能，是最基本的要求；而实际上，良好实现的软件项目，能在满足当前功能基础上，满足未来二次开发、维护的需要。软件项目的完整成本分为：开发成本、二次开发成本、维护成本。


##单一责任（Single Responsibility）

一个类只做一种类型的责任，当需要承担其他类型责任时，分解这个类。

下面的代码有多少职责？


	class Employee {
	  public Pay calculatePay() {...}
	  public void save() {...}
	  public String describeEmployee() {...}
	}  
	
正确答案是3个。

在一个类中混合了：

* 支付的计算逻辑
* 数据库逻辑
* 描述逻辑

如果你将多个职责结合在一个类中，可能很难实现修改一部分时不会破坏其他部分。混合职责也使这个类难以理解，测试，降低了内聚性。修改它的最简单方法是将这个类分割为三个不同的相互分离的类，每个类仅仅有一个职责：数据库访问，支付计算和描述。


##开放封闭（Open Closed）

对继承、扩展，是开放的；对修改，是封闭的。使用抽象类和接口。

为依赖关系使用接口的另一个作用是减少耦合和增加灵活性。


	void checkOut(Receipt receipt) {
	  Money total = Money.zero;
	  for (item : items) {
		total += item.getPrice();
		receipt.addItem(item);
	  }
	  Payment p = acceptCash(total);
	  receipt.addPayment(p);
	}

那么增加信用卡支持该怎么做？你可能像下面的增加if语句，但这违反OCP原则。

	Payment p;
	if (credit)
	  p = acceptCredit(total);
	else
	  p = acceptCash(total);
	receipt.addPayment(p);

更好的解决方案是：

	public interface PaymentMethod {void acceptPayment(Money total);}
	  
	void checkOut(Receipt receipt, PaymentMethod pm) {
	  Money total = Money.zero;
	  for (item : items) {
		total += item.getPrice();
		receipt.addItem(item);
	  }
	  Payment p = pm.acceptPayment(total);
	  receipt.addPayment(p);
	}
	
这儿有一个小秘密：OCP仅仅用于未来变化可预见的情况，当未来变化发生时，采用OCP。因此，需要准确地预见将来的变化。
这意味着等待用户做出改变，然后使用抽象应对将来的类似变化。


个人理解：通过抽象类、接口，实现，对扩展、新增开放，对修改关闭。

##里氏替换（Liskov Substitution）

子类的对象实例，应该能够替换任何其超类的实例，即，子类必须符合父类的预期行为*（隐含的行为约束）*。

下面几种情况，违反了LSP原则：

* 子类抛出父类没有抛出的异常；


一个违反LSP的典型例子是Square类派生于Rectangle类。Square类总是假定宽度与高度相等。如果一个正方形对象用于期望一个长方形的上下文中，可能会出现意外行为，因为一个正方形的宽高不能(或者说不应该)被独立修改。

解决这个问题并不容易：如果修改Square类的setter方法，使它们保持正方形不变(即保持宽高相等)，那么这些方法将弱化(违反)Rectangle类setter方法，在长方形中宽高可以单独修改。

	public class Rectangle {
	  private double height;
	  private double width;
	  
	  public double area();
	  
	  public void setHeight(double height);
	  public void setWidth(double width);
	}

以上代码违反了LSP。


	public class Square extends Rectangle {  
	  public void setHeight(double height) {
		super.setHeight(height);
		super.setWidth(height);
	  }
	  
	  public void setWidth(double width) {
		setHeight(width);
	  }
	}

违反LSP导致不明确的行为。不明确的行为意味着它在开发过程中运行良好但在产品中出现问题，或者要花费几个星期调试每天只出现一次的bug，或者不得不查阅数百兆日志找出什么地方发生错误。

个人理解：子类可以替换父类。


##接口分离（Interface Segregation）

不能强迫用户去依赖那些他们不适用的接口。换句话说，使用多个专门的接口，比使用单一的总接口要好。


想象一个ATM取款机，通过一个屏幕显示我们想要的不同信息。你会如何解决显示不同信息的问题？我们使用SRP,OCP和LSP想出一个方案，但是这个系统仍然很难维护。这是为什么？

想象ATM的所有者想要添加仅在取款功能出现的一条信息，“ATM机将在您取款时收取一些费用，您同意吗”。你会如何解决？

可能你会给Messenger接口增加一个方法并使用这个方法完成。但是这会导致重新编译这个接口的所有使用者，几乎所有的系统需要重新部署，这直接违反了OCP。让代码腐坏开始了！

这里出现了这样的情形：对于取款功能的改变导致其他全部非相关功能也变化，我们现在知道这并不是我们想要的。这是怎么回事？

其实，这里是向后依赖在作怪，使用了该Messenger接口每个功能依赖了它不需要，但是被其他功能需要的方法，这正是我们想要避免的。


	public interface Messenger {
	  askForCard();
	  tellInvalidCard();
	  askForPin();
	  tellInvalidPin();
	  tellCardWasSiezed();
	  askForAccount();
	  tellNotEnoughMoneyInAccount();
	  tellAmountDeposited();
	  tellBalance();
	}

相反，将Messenger接口分割，不同的ATM功能依赖于分离的Messenger。


	public interface LoginMessenger {
	  askForCard();
	  tellInvalidCard();
	  askForPin();
	  tellInvalidPin(); 
	}
	  
	public interface WithdrawalMessenger {
	  tellNotEnoughMoneyInAccount();
	  askForFeeConfirmation();
	}
	  
	publc class EnglishMessenger implements LoginMessenger, WithdrawalMessenger {
	  ...   
	}




个人理解：接口功能单一，多接口之间隔离；避免单一的总接口。









##依赖反转（Dependency Inversion）

* 高层模块，不应依赖于底层模块，二者都应依赖于抽象；
* 抽象不应该依赖于细节，细节应该依赖于抽象；


例子：一个程序依赖于Reader和Writer接口，Keyboard和Printer作为依赖于这些抽象的细节实现了这些接口。CharCopier是依赖于Reader和Writer实现类的低层细节，可以传入任何实现了Reader和Writer接口的设备正确地工作。

	public interface Reader { char getchar(); }
	public interface Writer { void putchar(char c)}
	  
	class CharCopier {
	  
	  void copy(Reader reader, Writer writer) {
		int c;
		while ((c = reader.getchar()) != EOF) {
		  writer.putchar();
		}
	  }
	}
	  
	public Keyboard implements Reader {...}
	public Printer implements Writer {...}




个人理解：通过接口，实现上下层之间的隔离。



##参考来源

* [the principles of OOD][the principles of OOD]
* [面向对象设计原则和创建SOLID应用的5个方法][面向对象设计原则和创建SOLID应用的5个方法]
* [Object Oriented Design Principles][Object Oriented Design Principles]






[NingG]:    										http://ningg.github.com  "NingG"
[the principles of OOD]:							http://butunclebob.com/ArticleS.UncleBob.PrinciplesOfOod
[面向对象设计原则和创建SOLID应用的5个方法]:		http://www.importnew.com/10656.html
[Object Oriented Design Principles]:				http://www.codeproject.com/Articles/567768/Object-Oriented-Design-Principles









