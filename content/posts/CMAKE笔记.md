---
date: '2025-09-16T16:01:09+08:00'
draft: true
title: 'CMAKE笔记'
tags: []
categories: []
summary: "<Text>"
canonicalURL: "https://canonical.url/to/page"
disableHLJS: true # to disable highlightjs
disableShare: false
comments: false
---

### cmake 预定义的路径

1. `CMAKE_SOURCE_DIR` ：指向顶级CMakeLists.txt 文件的所在目录。
2. `CMAKE_BINARY_DIR` : 指向运行cmake命令生成的构建目录， build目录。
3. `PROJECT_SOURCE_DIR` :
4. `PROJECT_BINARY_DIR` :
5. `CMAKE_CURRENT_SOURCE_DIR` : 当前CMakLists.txt 文件所在的目录。
6. `CMAKE_CURRENT_BINARY_DIR` : 当前CMakeLists.txt 文件生成的目录。
7. `CMAKE_INSTALL_PREFIX` : 指定安装目录。
8. `CMAKE_BUILD_TYPE` : 指定编译模式Debug/Release。


### 编译库：

```cmake
add_library(<name> [STATIC | SHARED | MODULE] [EXCLUDE_FROM_ALL] [<source>...])
```

- STATIC：静态库，生成 .a 或 .lib 文件。
- SHARED：动态库，生成 .so 或 .dll 文件。

- <source>..库的源文件列表

### 文件操作

```cmake
file(<MODE> [<option>...] <file>... [<file>...])
```

#### Examples

##### 文件内容IO类 

- 读取文件值到CONTENT变量中
```cmake
file(READ "README.txt" CONTENT)
```

- 写文件内容
```cmake
file(WRITE "output.txt" "Hello, World!")
```

- 追加文件内容
```cmake
file(APPEND <filename> <content>)
```

##### 文件查找类

- （递归）匹配文件列表
```cmake
file(<MODE [GLOB | GLOB_RECURSE]> <variable> [LIST_DIRECTORIES true|false] [RELATIVE path] filePattern1 [filePattern2 [...]])
```

##### 下载传输类

```cmake
file(DOWNLOAD "https://example.com/file.zip" "downloaded.zip")
```

##### 文件/路径操作类


### 链接lib库的一种可行的方式

1. 设置公共头文件目录
```cmake
set(COMMON_INCLUDES
    ${CMAKE_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/extern/eigen
    ${CMAKE_SOURCE_DIR}/test
    ${CMAKE_SOURCE_DIR}/tools
    ...
)
```
2. 设置公共库列表
```cmake
set(COMMON_LIBS
    TiGER_Tools
    TRANS2_Geo
    tiger_geom
    DT_Tri
    DT_Tetra
    DT_Remesh
    Mesh_Repair
    REMesh_Triangle
    Quality_Data
    SizingFunc
    AFT_Tri
    ALM_Hybrid
    imprintlib
    dt2D
    REMesh_Triangle2
)
```
3. 链接库
```cmake
add_executable(moldflow moldflow.cpp ${SOURCES})
target_include_directories(moldflow PUBLIC ${COMMON_INCLUDES})
target_link_directories(moldflow PUBLIC ${LIB_DIR})
target_link_libraries(moldflow PUBLIC ${COMMON_LIBS})
```