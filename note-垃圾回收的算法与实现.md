# 笔记: 垃圾回收的算法与实现

- [笔记: 垃圾回收的算法与实现](#%E7%AC%94%E8%AE%B0-%E5%9E%83%E5%9C%BE%E5%9B%9E%E6%94%B6%E7%9A%84%E7%AE%97%E6%B3%95%E4%B8%8E%E5%AE%9E%E7%8E%B0)
  - [前言](#%E5%89%8D%E8%A8%80)
  - [序章](#%E5%BA%8F%E7%AB%A0)
  - [算法篇](#%E7%AE%97%E6%B3%95%E7%AF%87)
    - [准备](#%E5%87%86%E5%A4%87)
    - [GC标记-清除算法](#gc%E6%A0%87%E8%AE%B0-%E6%B8%85%E9%99%A4%E7%AE%97%E6%B3%95)


## 前言

垃圾回收, Garbage Collection(GC), 一种让已经无法利用的内存实现自动再利用的技术(内存资源回收).


Lisp 支持 GC .

Java 支持 GC .

GC 的实现, 需要将硬件环境和语言功能相协调.

了解 GC, 可以加深对 语言处理程序 的认识.


## 序章

GC 把 程序不用的内存空间 视为垃圾.

GC 的工作:
- 找到内存空间里的垃圾
- 回收垃圾, 让程序员能再次利用这部分空间

没有 GC, 程序员需要手动管理内存.

内存泄露: 内存空间在使用完毕后没有被释放.

悬垂指针, dangling pointer, 指针没有指向有效的内存空间.

最初的 GC 算法是 John McCarthy 在 1960 年发布的. 名字是 GC 标记-清除算法.

其他算法: 引用计数法, GC 复制算法.

新发布的语言处理程序一般会带有 GC 算法. GC 的性能会影响语言的性能.

## 算法篇

### 准备

对象 在 GC 中的含义: 通过应用程序利用的数据的集合.

对象的组成
- 头(header)
  - 对象的大小
  - 对象的种类
  - 其他
- 域(field)
  - 指针数据
  - 非指针数据

GC 根据对象的大小和种类, 判断内存中存储的对象的边界.

域: 对象使用者 在对象中可访问的部分.

字: 计算机进行数据处理和运算的单位. 字由若干字节构成.

字长: 字的位数. 8位机的字长是8位, 16位机的字长是16位.

通过 GC 销毁或保留 对象. GC 根据对象的指针去搜寻其他对象. GC 对非指针不进行任何操作.

指针默认指向对象的首地址.

mutator: 改变 GC 对象间的引用关系. mutator 的实体是 应用程序 .

mutator 进行的操作:
- 生成对象
- 更新指针

堆: 用于动态(在执行程序时)存放对象的内存空间.

当 mutator 申请存放对象时, GC 就会把所需的内存空间从堆中分配给 mutator .

GC 是管理堆中已分配对象的机制.

活动对象: 分配到堆中的, 能通过 mutator 引用的对象. GC 保留活动对象.

非活动对象: 分配到堆中的, 不能通过 mutator 引用的对象. GC 会销毁非活动对象, 回收该对象原本占用的空间.

分配(allocation): 在内存空间中分配对象.

分配器(allocator): 当 mutator 需要新对象时, 分配器会在堆中寻找满足需求的空间, 返回给 mutator.

分块(trunk): 为利用对象而事先准备出来的空间. 垃圾回收后变成分块. 内存里的各个区块都重复着 分块, 活动对象, 垃圾, 分块......这样的过程.

根: 指向对象的指针的 "起点"部分. 全局变量, 调用栈(call stack), 寄存器.

GC 算法的性能评价标准:
- 吞吐量
- 最大暂停时间
- 堆使用效率
- 访问的局部性

### GC标记-清除算法

Mark Sweep GC

由标记阶段和清除阶段构成. 标记阶段: 把所有活动对象都做上标记的阶段. 清除阶段: 把没有标记的对象回收的阶段.

分配: First-fit 策略.

合并: 在清除阶段, 将连续的分块合并成大分块

