---
date: '2025-09-16T15:57:11+08:00'
draft: true
title: 'Effective C++笔记'
tags: []
categories: []
summary: "<Text>"
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false
comments: false
---

1. use `explicit`. It is used to modify the class constructor, and its primary purpose is to prevent the compiler from performing implicit tpye conversions.
2. default constructor, copy constructor and copy assignment operator. `A(); A a(A &b); A &operator=(A &b);`
3. naming convertions. use `px` for pointer, `rx` for reference. `lhs` and `rhs` for binary operators.
4. use `const`, `enum` replace `#define`
5. use `static` in class exclusive constant.
6. use `template, inline` replace `define function`
7. `const *` : data,  `* const`: pointer
8. A `const` witch in the ending of a function means that the function does not modify the object. But the pointer or reference can be modified witch return from the function. So as usually, `const * const` or `const & const` is better.
9. use `mutable`
10. const 和 non-const 成员函数中避免重复
```cpp
class TextBlock {
    public:
    const char& operator [] (std::size_t position) const // 一如既往
    {
        ...
        ...
        ...
        return text [position];
    }
    char& operator [] (std:: size_t position)           // 现在只调用 const op []
    {
        return 
            const_cast<char&>(                          // 将op[]返回值的const 转除
                static cast<const TextBlock&>(*this)    // 为*this 加上const
                    [position]                          // 调用 const op []
            );
    }
};
```