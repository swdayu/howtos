
# Reference
- [Lua 5.3 Reference Manual](http://www.lua.org/manual/5.3/manual.html)

# 1. Introduction

Lua is an extension programming language designed to support 
general procedural programming with data description facilities. 
Lua also offers good support for object-oriented programming, functional programming, and data-driven programming. 
Lua is intended to be used as a powerful, lightweight, embeddable scripting language for any program that needs one.
Lua is implemented as a library, written in clean C, the common subset of Standard C and C++. 

Lua是一种扩展性的拥有数据描述功能的通用过程式编程语言。
它对面向对象编程、函数式编程、数据驱动式编程也有很好的支持。
Lua通常作为强大、轻量、可嵌入的脚本语言用在其他程序中。
Lua是用clean C（标准C和C++的通用子集）实现的程序库。

As an extension language, Lua has no notion of a "main" program: 
it only works embedded in a host client, called the embedding program or simply the host. 
The host program can invoke functions to execute a piece of Lua code, 
can write and read Lua variables, and can register C functions to be called by Lua code. 
Through the use of C functions, Lua can be augmented to cope with a wide range of different domains, 
thus creating customized programming languages sharing a syntactical framework. 
The Lua distribution includes a sample host program called lua, which uses the Lua library to offer a complete, 
standalone Lua interpreter, for interactive or batch use.

作为一种扩展语言，Lua没有main程序概念：它仅在宿主程序中工作。
宿主程序可以调用函数执行Lua代码、读写Lua变量、也可以注册C函数让其在Lua中调用。
通过使用C函数，Lua可以共享相同的语法框架来定制编程语言，使其扩展应用到不同领域中。
Lua发布版中包含了一个叫lua的宿主程序，它用Lua库实现了一个完整独立的Lua解释器，可用于交互式应用或批处理。

Lua is free software, and is provided as usual with no guarantees, as stated in its license. 
The implementation described in this manual is available at Lua's official web site, [www.lua.org](www.lua.org).

Lua是免费软件，如使用许可陈述，其使用过程不提供任何担保。
这份手册中描述的实现也可以在Lua官方网站（[www.lua.org](www.lua.org)）上找到。

Like any other reference manual, this document is dry in places. 
For a discussion of the decisions behind the design of Lua, see the technical papers available at Lua's web site. 
For a detailed introduction to programming in Lua, see Roberto's book, Programming in Lua. 

像其他参考手册一样，这份文档是枯燥的。关于Lua背后为什么这样设计的讨论，可以查看Lua官方网站上的技术论文。
关于Lua编程的详细介绍，可以参考Reberto的书《Programming in Lua》。

[2. Basic Concepts](../2-basic-concepts/2.1-values-and-types.md)
