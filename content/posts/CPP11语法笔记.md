---
date: '2025-09-16T16:00:55+08:00'
draft: true
title: 'CPP11语法笔记'
tags: []
categories: []
summary: "<Text>"
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false
comments: false
---

## 类型判断

1. use `typeid`

`const` 和 `&` 不会影响判断的结果。

```cpp
int a = 1;
if(typeid(a) == typeid(int)) {
    YES
} else {
    NO
}
```

2. use `decltype` 

可以保留完整的类型信息，包括 `const` 和 `&`。

```cpp
const int &i = 1;    
if (std::is_same<decltype(i), const int&>) {
    YES
} else {
    NO
}
```


## 左值、右值

> 左值：可以放到等号左边的东西叫左值。
> 右值：不可以放到等号左边的东西就叫右值。

例如 `int a = b + c`， `a` 为左值； `b + c` 为 右值。

左值可以取地址，右值则不能。

左值引用的例子：
```cpp
int a = 5;
int &b = a; // b是左值引用
b = 4;
int &c = 10; // error，10无法取地址，无法进行引用
const int &d = 10; // ok，因为是常引用，引用常量数字，这个常量数字会存储在内存中，可以取地址
```

右值引用的例子（和rust中的move很像，原对象不再被使用，可以方便地进行进程间的数据传递）：
```cpp
int a = 1;
int &&b = std::move(a);
```

## std::funcion, std::bind, lambda

`std::function` 可以很轻松地创建函数对象的（指针），可以存储自由函数或者lambda函数。

`std::bind` 将函数参数和值进行绑定，创建std::function对象。

`lambda` 可以捕获当前运行环境中的变量。

## 智能指针

`std::shared_ptr` 多个shared_ptr 可以指向同一个对象，线程安全，内涵引用计数器。

`std::weak_ptr` 

`std::unique_ptr` 管理一个对象，可以 move 但是不能 copy，在离开作用域时会自动析构。

## const

```cpp
char *const ptr; // 指针本身是常量
const char* ptr; // 指针指向的变量为常量
class A;
void func(const A& a); // 创建a的引用，同时保证其内容不会被修改
class A {
    void func() const; // 表示该函数承诺不会会类成员变量进行修改
};
```


## 多线程

`std::thread` 使用 `join()` 函数等待线程结束，使用 `detach()` 函数分离线程，分离线程后，线程将独立运行，线程结束后，线程资源会被释放。

`std::mutex` 互斥量。

`std::lock` 锁， 有 `std::lock_guard` 和 `std::unique_lock` 两种方式。

`std::atomic` 原子量。

`std::call_once` 保证某一函数在多线程中只被运行一次。

`std::future` 未来会执行一次的任务。

`std::async` 异步执行。`wait / get` 获取结果。