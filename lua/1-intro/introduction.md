
# 1. Introduction

Lua is an extension programming language designed to support 
general procedural programming with data description facilities. 
Lua also offers good support for object-oriented programming, functional programming, and data-driven programming. 
Lua is intended to be used as a powerful, lightweight, embeddable scripting language for any program that needs one.
Lua is implemented as a library, written in clean C, the common subset of Standard C and C++. 

Lua是一种扩展的有数据描述功能的通用过程式编程语言。不过它对面向对象编程、函数式编程、数据驱动式编程也有很好的支持。
Lua通常作为一种强大、轻量、可嵌入的脚本语言用在其他程序中。Lua是用clean C（标准C和C++的通用子集）实现的程序库。

As an extension language, Lua has no notion of a "main" program: 
it only works embedded in a host client, called the embedding program or simply the host. 
The host program can invoke functions to execute a piece of Lua code, 
can write and read Lua variables, and can register C functions to be called by Lua code. 
Through the use of C functions, Lua can be augmented to cope with a wide range of different domains, 
thus creating customized programming languages sharing a syntactical framework. 
The Lua distribution includes a sample host program called lua, which uses the Lua library to offer a complete, 
standalone Lua interpreter, for interactive or batch use.

作为一种扩展语言，Lua没有main程序概念：它仅在宿主程序中工作。
宿主程序可以调用函数执行一块Lua代码，读写Lua变量，也可以注册C函数让它可以在Lua代码中调用。
[Through ... framework. => TODO] 
Lua发布中包含了一个叫lua的宿主程序，它用Lua库实现了一个完整独立的Lua解释器，可用于交互式编程和批处理。

Lua is free software, and is provided as usual with no guarantees, as stated in its license. 
The implementation described in this manual is available at Lua's official web site, <www.lua.org>.

Like any other reference manual, this document is dry in places. 
For a discussion of the decisions behind the design of Lua, see the technical papers available at Lua's web site. 
For a detailed introduction to programming in Lua, see Roberto's book, Programming in Lua. 

Next: [2. Basic Concepts](../2-basic-concepts/2.1-values-and-types.md)
