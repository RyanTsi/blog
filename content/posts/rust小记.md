---
title: rust 小记
date: 2022-11-22 10:01:03
categories: [编程技能]
tags: [rust]
excerpt: rust是一种比较新的语言，对标cpp，拥有优越的性能和安全的内存，非常适合高并发的软件，相较于其他语言来说比较难入门，这里给出了部分简单语法。
sticky: 0
mathjax: true
---

## 入门
### 环境配置
#### 安装
- Linux
```shell
$ curl --proto '=https' --tlsv1.3 https://sh.rustup.rs -sSf | sh
```
- windows
前往 https://www.rust-lang.org/install.html 并按照说明安装 Rust

#### 检查

```shell
$ rustc --version
```

#### 更新

```shell
$ rustup update
```

#### 卸载

```shell
$ rustup self uninstall
```

#### 本地文档

```shell
rustup doc
```

### 编译命令与Cargo

#### rustc

和gcc差不多的用法
```shell
$ rust [-g] {filename.rs} [-o]
```
#### Cargo
- 创建一个项目
```shell
$ cargo new {dirname} 
```
- 构建
```shell
$ cargo build [--release]
```
只确保通过编译
```shell
cargo check
```
- 运行
```shell
$ cargo run
```

### 变量

rust中变量默认设置为不可变, 只能被覆盖, 需要加`mut`前缀设置为可变. 
`const`修饰常量, 常量可以是个算式

#### 整型

|长度   | 有符号   |无符号 |
|------ |------   |-------|
|8-bit  |`	i8  ` |`	u8 `|
|16-bit |`	i16 ` |`	u16`|
|32-bit |`	i32	` |`u32 ` |
|64-bit	|`i64  `  |`	u64`|
|128-bit|`i128	` |`u128` |
|arch	  |`isize`  |`usize`|

向$0$取整

#### 浮点型

`f32`, `f64`

#### 布尔型

`bool`: `enum { true, false }`

#### 字符类型

UTF-8编码(2-bit)
`char`

#### 元组
`(i32, i32, i32)`
`.`访问

#### 数组
`[i32; 10]` $10$个`i32`变量

#### 枚举类型
```rust
enum IpAddr{
    V4: (u8, u8, u8, u8),
    V6: String,
}
```
枚举类型中的值是可选项，用`::`来构造一个实例
```rust
let home = IpAddr::V4(192, 0, 0, 10);
```
- 特殊的枚举类型`Option`
这是一个定义在标准库内的类型
```rust
enum Option<T> {
    None,
    Some(T),
}
```

### 函数
无返回值 (void) 的函数
```rust
fn function() {
    // -- skip -- 
}
```

带返回值的函数
```rust
fn function() -> i32 {
    // 两中返回值的方式都是可以的
    5
    //return 5;
}
```

### 控制流 

#### if
兼容 C 风格, 可以带`()`
```rust
if x < 5 {
    x += 1;
} else if x < 10 {
    x += 2;
} else {
    x += 3;
}
```

#### loop
无限循环体
```rust
loop {
    x += 1;
    if x >= 100 {
        break;
    }
}
```

#### while
兼容 C 风格, 可以带`()`
```rust
while x < 5 {
    x += 1;
}
```

#### for
遍历集合
```rust
let a = [0, 1, 2, 3, 4, 5];
for i in a {
    print!("{}", i);
}
```
逆序遍历索引
```rust
for i in (0..5).rev() {
    // --skip--
}
```

#### match
类似 C 语言中的switch
```rust
enum IpAddr {
    V4(String),
    V6(String),
}
let home = IpAddr::V4(String::from("192, 0, 0, 1"));
let ip = match home {
    IpAddr::V4(s) => {
        s
    },
    IpAddr::V6(s) => s
    // => 表示产生的效果

    other => String::from("0, 0, 0, 0"),
    //match 是穷尽的 
};
```

#### if let
弱化版的match
```rust
if let IpAddr::V4(s) = home{
    println!("{}", s);
} else {
    cnt += 1;
}
println!("{}", cnt);
```

### 结构体定义与实例

贴个自己写的 BIT 基本就会用了

```rust
fn main () {
    let mut bit = BIT::new(100);
    for i in (1..bit.N) {
        bit.add(i, 1);
    }
    for i in (1..bit.N) {
        println!("{}", bit.get(i));
    }
}
struct BIT {
    N: usize,
    p: Vec<i32>,
}

impl BIT {
    fn new(n: usize) -> Self {
        BIT {
            N: n,
            p: vec![0; n + 1],
        }
    }
    fn add(&mut self, mut x: usize, y: i32) {
        while x < self.N {
            self.p[x] += y;
            x += x & (!x + 1);
        }
    }
    fn get(&self, mut x: usize) -> i32 {
        let mut res = 0;
        while x > 0 {
            res += self.p[x];
            x -= x & (!x + 1);
        }
        res
    }
}
```

### 几种常见的封装集合
#### Vector
定义
```rust
let v1 = vec![1, 2, 3, 4];
let v2 = vec![0; 5];
let  mut v3: Vec<i32> = Vec::new();
```
几个常用的函数
- push
- pop
- append
```rust
// 将 v2 中的元素移动到 v1
v1.append(&mut v2);
```
- sort | sort_by
```rust
// 逆序排序
v1.sort_by(|a, b| b.cmp(a));
```
- is_empty
- len
- resize

#### String
定义
```rust
let s1 = String::from("hello, ");
let s2 = "world!".to_string();
let s3 = s1 + &s2;
```
采用 UTF-8 编码，利用索引引用的时候两个连续的索引表示一位`char`。
#### Hash Map
定义
```rust
let mut map = HashMap::new();
map.insert("red".to_string(), 1);
map.insert("blue".to_string(), 2);
map.insert("red".to_string(), 10);  // 覆盖
map.entry("red".to_string()).or_insert(10); // 不存在则插入一个值
let conut = map.entry("bule".to_string()).or_insert(0);
*conut += 1; // 更新map中的数据
let x = map.get(&"red".to_string()).copied().unwrap_or(0); // 得到一个不可变的值
```

