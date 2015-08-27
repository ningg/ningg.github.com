---
layout: post
title: 浅谈 Enum
description: Enum 能解决什么问题？怎么用？
published: true
category: blog
---


## 典型应用

枚举类是 java.lang.Enum 类的子类，下述示例代码中：

* RED、GREEN、YELLOW都是Light预定义好的Light的实例（public static final）
* 在运行期间，我们无法再创建新的Enum的实例（构造方法私有）

示例代码如下：

	public enum Light {
       // 利用构造函数传参
       RED(1, "红色"),
       GREEN(2, "绿色"),
       YELLOW(4, "黄色");
       
       // 定义私有变量
       private int value;
       private String desc;
       
       // 构造函数，枚举类型只能为私有，默认为私有
       Light( int value, String desc) {
           this.value = value;
           this.desc = desc;
       }
       
       // Getter and Setter 
       ... ...       
       
       
    }

不怕再啰嗦一次：

* enum 类的实例，默认是：public static final，例如上述的 RED、GREEN、YELLOW
* enum 类的默认构造方法是 private，也只能是private，保证外界无法创建 enum实例

## 为什么要用 enum

实际上，枚举类的实例是静态常量，那为什么不直接使用静态常量呢？在没有 enum之前，静态常量的写法如下：

	// 方法 1：静态常量
	public class WeekDay {
        public static final int MONDAY = 1;
        public static final int TUESDAY = 2;
        public static final int WENSDAY = 3;
        public static final int THURSDAY = 4;
        public static final int FRIDAY = 5;
	}
	
使用枚举类时：

	// 方法 2：枚举类
	// enum 类的等价实现方式，后文会单独写一个 enum
	public class WeekDay {
         public static final WeekDay MONDAY = new WeekDay(1);
         public static final WeekDay TUESDAY = new WeekDay(2);
         public static final WeekDay WENSDAY = new WeekDay(3);
         public static final WeekDay THURSDAY = new WeekDay(4);
         public static final WeekDay FRIDAY = new WeekDay(5);
         
         private int value;
         
         private WeekDay(int i){
                   this.value = i;
         }
         
         public int getValue(){
                   return value;
         }
         
	}

方法 1，使用静态常量，存在几个问题：

* 类型不安全：由于常量的对应值是整数形，所以程序执行过程中很有可能给星期变量传入一个任意的整数值，导致出现错误。
* 没有命名空间：由于常量只是类的属性，必须通过类来访问 如： Weekday.SUNDAY。
* 一致性差：因为整形枚举属于编译期常量，所以编译过程完成后，所有客户端和服务器端引用的地方，会直接将整数值写入，修改需要重新编译。
* 类型无指意性：由于枚举值仅仅是一些无任何含义的整数值，如果在运行期调试时候，你就会发现日志中有很多魔术数字（0-6），其他人很难明白具体含义。

相比来说，方法 2 ，使用静态常量类（枚举类），好处：

* 语意性强：字面即可理解功能
* 不直接接受 int 类型数据，只接受 WeekDay 预定义好的static final的实例
* 所有对象都是 public static final，是单例的，因此可以直接使用 equals 或者 ==

下面写一个标准的枚举类

	public enum WeekDayEnum {
		MONDAY(1),
		TUSDAY(2),
		WENSDAY(3),
		THURSDAY(4),
		FRIDAY(5);
		
		private int value;
		
		WeekDayEnum(int value){
			this.value = value;
		}
		
		public int getValue(){
			return this.value;
		}
		
	}

NOTE：实际上，枚举类继承自java.lang.Enum抽象类。

## 应用场景

枚举的7中常用方式，主要有：

* 表示常量
* 用于switch
* 添加更多方法
* 覆盖Object方法
* 实现接口
* 枚举集合EnumSet和EnumMap，EnumSet保证集合中的元素不重复；EnumMap中的key是enum类型，而value则可以是任意类型。


## 特别写法

枚举类，每个静态常量实例，都有一个序号（从 0 开始），常见的写法：

	public enum WeekDayEnum {
		MONDAY("周一"),
		TUSDAY("周二"),
		WENSDAY("周三"),
		THURSDAY("周四"),
		FRIDAY("周五");
		
		private int ordinal;
		
		WeekDayEnum(){
			this.ordinal = this.ordinal();
		}
		
		public int getOrdinal(){
			return this.ordinal;
		}
		
	}


## 避免错误使用 Enum

不过在使用 Enum 时候有几个地方需要注意：

* enum 类型不支持 public 和 protected 修饰符的构造方法，因此构造函数一定要是 private 或 friendly 的。也正因为如此，所以枚举对象是无法在程序中通过直接调用其构造方法来初始化的。
* 定义 enum 类型时候，如果是简单类型，那么最后一个枚举值后不用跟任何一个符号；但如果有定制方法，那么最后一个枚举值与后面代码要用分号';'隔开，不能用逗号或空格。
* 由于 enum 类型的值实际上是通过运行期构造出对象来表示的，所以在 cluster 环境下，每个虚拟机都会构造出一个同义的枚举对象。因而在做比较操作时候就需要注意，如果直接通过使用等号 ( ‘ == ’ ) 操作符，这些看似一样的枚举值一定不相等，因为这不是同一个对象实例。













## 参考来源

* [Is there a way to bitwise-OR enums in Java?]
* [Effective Java Item 32: Use EnumSet instead of bit fields]












[NingG]:    http://ningg.github.com  "NingG"

[Is there a way to bitwise-OR enums in Java?]:	  http://stackoverflow.com/q/6282619
[Effective Java Item 32: Use EnumSet instead of bit fields]:	http://dhruba.name/2008/12/31/effective-java-item-32-use-enumset-instead-of-bit-fields/







