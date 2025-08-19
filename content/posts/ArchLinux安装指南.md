---
title: ArchLinux安装指南
sticky: 0
mathjax: true
date: 2023-08-01 15:33:49
categories:
    - 操作系统
tags:
    - Linux
excerpt: ArchLinux入指南，简述了一些步骤以及其中的一些概念。
cover:
---

以下是我自己在真机上安装过多次可行的方法。

在真机安装和在虚拟机上安装还是有很大的区别，此文章简单说明了其中的一些必要的步骤。

## 准备安装介质

从镜像网站上 https://mirrors.ustc.edu.cn/ 获取映像文件。

用 `rufus` 等烧录文件将映像以 `DD` 形式烧录到U盘，`ISO` 不行，至少在我的电脑上存在这样的问题。

## 启动到Live环境

Live 环境中包含的 Archlinux 安装所需的工具。

电脑重启后按 F2 进入 BIOS（不同厂商的电脑进入 BIOS 的按键可能不一样）。

如果是双系统安装，需要在 BIOS 中将 Sevure Boot 设置为 Disable，装完后也可以重新启用。

### 联网

利用 `iwctl` 进行联网

`device list` 查看已安装网卡

`station DEVICE scan` 扫描周边的 wifi

`station DEVICE get-networks` 显示扫描到的 wifi

`station --passphrase=PASSPHRASE station DEVICE connect SSID ` 连接到所选的 wifi

### 启动方式的选择

查看启动发生BIOS or UEFI

```shell
[ -d /sys/firmware/efi ] && echo UEFI || echo BIOS
```

### 磁盘分区

创建磁盘分区：需要一个根分区和一个EFI系统分区（UEFI 启动方式需要这个分区），可以选择创建一个交换分区。

如果是双系统， EFI 分区可以直接挂载 Windows 已经创建好的 EFI 分区。

交换分区是一种虚拟内存的表现形式，系统为了应付需要用到大量内存的场景，将磁盘上的一部分空间当作内存使用。

> **swap文件创建规则**（参照oracle官方文档设定的标准）:
> - 4G以内的物理内存，SWAP 设置为内存的2倍。
> - 4-8G的物理内存，SWAP 等于内存大小。
> - 8-64G 的物理内存，SWAP 设置为8G。
> - 64-256G物理内存，SWAP 设置为16G。

利用`fdisk -l`查看当前磁盘分区状况，找到所需要安装系统的磁盘，利用`cfdisk`进行分盘（这是一个图形化的分区修改界面）。

如果是一块未分区的磁盘，会提示使用哪种分区表，按照官方文档的说法 BIOS 启动应采用 MAR 分区表，UEFI 启动应采用 GPT 分区表。

> 具体详见 [wiki-引导加载程序](https://wiki.archlinuxcn.org/wiki/Arch_%E7%9A%84%E5%90%AF%E5%8A%A8%E6%B5%81%E7%A8%8B#Boot_loader)

虚拟机分区例子（传统引导）：

![1](/images/Archlinux/imgae.png)

#### 格式化分区

> 详见 [wiki-文件系统](https://wiki.archlinuxcn.org/wiki/%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F#%E5%88%9B%E5%BB%BA%E6%96%87%E4%BB%B6%E7%B3%BB%E7%BB%9F)

```shell
mkfs.ext4 /dev/root_partition（根分区）
mkswap /dev/swap_partition（交换空间分区）
mkfs.fat -F 32 /dev/efi_system_partition（EFI 分区）
```

#### 挂载分区

> 挂载：指的就是将设备文件中的顶级目录连接到 Linux 根目录下的某一目录（最好是空目录），访问此目录就等同于访问设备文件。

```shell
mount /dev/root_partition（根分区） /mnt
mount --mkdir /dev/efi_system_partition（EFI 系统分区） /mnt/boot
swapon /dev/swap_partition（交换空间分区）
```
要注意挂载顺序，一定是先挂载根分区再挂载 EFI 分区。

### 安装

1. 选择镜像

官方所有的镜像源：https://archlinux.org/download/

```shell
# 备份
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bk
# 选择在中国的最快镜像源
reflector --verbose --country 'China' -l 200 -p https --sort rate --save /etc/pacman.d/mirrorlist
# 清华园镜像
Server = https：//mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os$arch
# 中科大镜像
Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os$arch
# 更新
pacman -Sy
```

文件 /etc/pacman.d/mirrorlist 定义了软件包会从哪个镜像下载，优先级从上向下依次递减。

2. 安装基本系统

```shell
pacstrap /mnt base base-devel linux linux-firmware linux-headers
```

其中 `pacstryp` 是一个安装脚本。

其中 base 和 base-devel 包含一系列的系统软件，必须安装。linux是内核，linux-firmware 是一些驱动，linux-headers 是内核头文件。

当然，内核也可以选择不是原版的 Linux，比如 Linux-lts，可以在 wiki 上找到其他版本的内核 [wiki-内核](https://wiki.archlinuxcn.org/wiki/%E5%86%85%E6%A0%B8)。

## 配置新系统

**创建Fstab文件**

用以下命令生成 fstab 文件 (用 -U 或 -L 选项设置 UUID 或卷标)：

```shell
genfstab -U /mnt >> /mnt/etc/fstab
```

`fastab` 该文件包含了当前分区挂载情况，生成之后建议检查里面的内容是否正确。

**chroot 到新安装的系统：**

从 Live 环境进入挂载点。

```shell
arch-chroot /mnt
```

**下载一些必要的软件**

利用 `pacman` 进行安装。

```shell
pacman -Syy # 更新软件包列表
```

---

`networkmanager` 连接互联网

`net-tools` 包含 ifconfig 等命令

`vim` 文本编辑器

`dhcpcd` 分配 ip 地址

`openssh` ssh 服务

`git`

`grub` 用来引导系统

`os-prober` 双系统可选安装，可以选择进入那个系统

`efibootmgr` UEFI引导必装

`intel-ucode/amd-ucode` CPU 微码必装

`man` 查看软件包的文档

`ntfs-3g` 访问 ntfs 格式的磁盘，双系统必装

`noto-fonts-cjk` 和 `noto-fonts-emoji` 谷歌设计的中文字体

**设置中文字符**

编辑 locale.gen 将中文（zh_CN_UTF-8）以及英文（en_US_UTF-8）前的注释去掉。

输入`locale-gen`设置字符集。

在文件 `/etc/locale.conf` 中写入 `LANG=en_US.UTF-8` 保存。

```shell
echo LANG=en_US.UTF-8 > /etc/locale.conf
```

这里需要设置成英文，在 TTY 状态下中文会乱码。

> TTY 没有安装图形界面时的状态。

**设置时区(以上海为例)**

```shell
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

生成`/etc/adjtime`

```shell
hwclock --systohc
```

**配置主机名**

```shell
echo YOURPC > /etc/hostname
```

以及配置密码

```shell
passwd
```

**自启动 NetworkManager， ssh，dhcpcd**

```shell
systemctl enable NetworkManager sshd dhcpcd
```

### 安装引导程序

GRUB 默认不支持 os-prober，需要做如下修改：

编辑`/etc/default/grub`，将最后一行`#GRUB_DISABLE_OS_PROBER=false`取消注释

对于UEFI

```shell
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

对于BIOS

```shell
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

退出重启
```shell
exit
reboot
```

双系统重启后可能还是找不到 Windows 的启动引导，可以在进入系统后再执行一次`grub-mkconfig -o /boot/grub/grub.cfg`，也可以自己手动在grub里添加引导入口。

### 配置本地用户

进入新系统后可以用 NetworkManager 联网

显示 wifi 列表

```shell
nmcli dev wifi list
```

连接指定 wifi

```shell
nmcli dev wifi connect SSID password PASSWORD
```

创建普通用户

```shell
useradd -m -G wheel YOURNAME
passwd YOURNAME
```

wheel 是 linux 本身包含的一个用户组。

配置 sudo

编辑`/etc/sudoers`，取消`#wheel ALL=(ALL:ALL) ALL`的注释。

`su YOURNAME` 进入本地用户，下文中的命令中若出现`$`则表示在本地用户执行的。

### 网络配置

将下面内容写入到 `/etc/hosts`
```
127.0.0.1   localhost
::1         localhost
127.0.1.1   yourPCname.localdomain  yourPCname
```
### 配置AUR

全称 Arch User Repository, 简称 AUR。

修改 `/etc/pacman.conf`

将 `[multilib]` 的两行取消注释，这个仓库包含 Arch 官方软件仓库的 32 位软件和链接库。

配置 Archlinuxcn

添加两行

```
[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
```

这个仓库是 Arch Linux 中文社区驱动的非官方用户仓库。包含中文用户常用软件、工具、字体\美化包等。

安装 `archlinuxcn-keyring` 导入 GPG 密钥

**安装paru 或者 yay**

```shell
$ sudo pacman -S paru
```

### 安装驱动

#### 显卡驱动

我的笔记本是 Amd 的核显和 Nvidia 的独显，装的内核是 Linux，这里举个例子。

```shell
$ sudo pacman -S xf86-video-amdgpu mesa lib32-mesa 
$ sudo pacman -S nvidia nvidia-utils lib32-nvidia-utils
```
同时把 `kms` 从 `/etc/mkinitcpio.conf` 里的 HOOKS 数组中移除，并重新生成 initramfs。 这能防止 initramfs 包含 `nouveau` 模块，以确保内核在早启动阶段不会加载它。

```shell
$ mkinitcpio -p linux
```

Nvidia 驱动的安装详见 [wiki-Nvidia](https://wiki.archlinuxcn.org/wiki/NVIDIA)

### 安装桌面环境

这里简单介绍对 Gnome 的一些配置。

> 在我的电脑上 Gnomo 账户注销再登陆就会直接卡住 QAQ，考虑找别的桌面替代。

#### 安装 Gnome 桌面

```shell
$ sudo pacman -S gnome gnome-tweaks gnome-extra gdm
```

**开机自启动**
```shell
$ sudo systemctl enable gdm
```

新安装好的Gnomo用起来有诸多不便，没有系统托盘，没有 Dock 栏，没有桌面图标等等，我们需要安装拓展插件来弥补这些功能的缺失。

**安装支持库**

```shell
$ sudo pacman -S gnome-browser-connector
```

**以下是我比较建议安装的几个插件:**

自定义主题

[User Themes](https://extensions.gnome.org/extension/19/user-themes/)

显示桌面图标

[Desktop Icons NG (DING)](https://extensions.gnome.org/extension/2087/desktop-icons-ng-ding/)

显示暂时回到桌面图标

[Show Desktop Button](https://extensions.gnome.org/extension/1194/show-desktop-button/)

Dock栏

[Dash to Dock](https://extensions.gnome.org/extension/307/dash-to-dock/)

系统托盘

[AppIndicator and KStatusNotifierItem Support](https://extensions.gnome.org/extension/615/appindicator-support/)