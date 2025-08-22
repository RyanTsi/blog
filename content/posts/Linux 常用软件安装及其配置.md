---
title: Linux 常用软件安装及其配置
sticky: 0
mathjax: true
date: 2024-01-28 10:05:18
categories: [操作系统]
tags: [Linux]
summary: 介绍一些我在使用 linux 过程中使用的软件，做一个资料的整合，避免日后需要的时候重复去网上搜索。
cover:
    image: "images/avatar.jpg" # image path/url
    caption: "" # display caption under cover
    alt: "" # alt text
    relative: true # when using page bundles set this to true
    responsiveImages: false # generation of responsive cover images
    hidden: false # only hide on current single page
---

介绍一些我在使用 Linux  过程中使用的软件，基本仅涉及安装、配置部分，不涉及软件的原理。

### dwm

基于 X11 的一个 WM ，简单好用。

官方仓库: https://git.suckless.org/dwm/

我修改后的: https://github.com/RyanTsi/dwm/

主要基于自己习惯的快捷键进行了调整，安装了一些补丁。之后也决定自己修改部分代码上去。

可以通过 `xrandr` 来进行多显示器的配置。

可以安装 `xdg-user-dirs` 来生成 Desktop、Music、Pictures 等文件夹，运行 `xdg-user-dirs-update`。

### alacritty

一个利用 GPU 进行渲染 Terminal 。当时记得用 suckless 的 st 有一些显示问题就换称了 alacritty。

官方wiki: https://alacritty.org/config-alacritty.html

### ranger

文件管理器。

### fcitx5

输入法。

**安装:**

`fcitx5` 本体

`fcirx5-chinese-addon` 包含中文输入法

`fcitx5-pinyin-zhwiki` 中文词库

`fcitx5-configtool` 用于设置的 GUI

**配置：**

在 `/etc/environment` 写入如下变量使得 fcitx 在不同界面上能正常运行

```
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
INPUT_METHOD=fcitx
GLFW_IM_MODULE=ibus
```

随桌面环境自动启动：在 `.xinitrc` 中添加一行 `fcitx5 -d &`。

在某些软件可能会遇到输入法不工作的情况，这大概率是跟那个软件的界面有关。

### zsh

一个 shell 解释器，Tab 相对于 bash 好用太多，同时插件丰富。

安装 oh-my-zsh 以及 autosuggestions、syntax-highlighting 这两个插件。

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

在 `~/.zshrc` 的 Plugins 处添加上这两个插件。

### ALSA

全称 Advanced Linux Sound Architecture。需要安装一些程序来控制音频设置。

`alsa-utils` 包含alsamixer（GUI）、amixer（Shell）。

设置默认声卡：

在 `~/.asoundrc` 中写入

```
defaults.pcm.card 1
defaults.ctl.card 1
```

可以通过amixer编写一些脚本同时绑定快捷键来方面地控制音量。

```shell
amixer sset Master 5%-      # 音量减少 5%
amixer sset Master 5%+      # 音量增加 5%
amixer sset Master toggle   # 静音解除/解除静音
```

### rofi

可以用来当作应用启动器、窗口选择器等。

### picom 

X11 合成器。

随桌面环境自动启动：在 `.xinitrc` 中添加一行 `picom -b`。

### 字体

ttf-hack-nerd

ttf-dejavu

noto-fonts-cjk

noto-fonts-emoji

ttf-wps-fonts

wps-office-mui-zh-cn

wyq-microhei

### dunst

X11 的 notification daemon。

随桌面环境自动启动：在 `.xinitrc` 中添加一行 `dunst`。

可以用 `notify-send (String)` 发送一条通知。

### feh、imv

图片查看工具。

feh 还能对图像进行简单的编辑，一般用来当作显示桌面壁纸的工具。

### mpv

视频播放器。

可以在参数上添加 `--gpu-api=vulkan` 来选择用图形 API，`--hwdec=nvdec` 来选择硬件解码器。

配置文件通常在 `~/.config/mpv/mpv.config`。

### btop、nvtop

btop 资源管理窗口。

nvtop GPU 资源管理窗口。


### cpupower

一组辅助 CPU 频率调节的工具，配置文件在 `/etc/default/cpupower` 下，可以用 `systemd` 启动


### Clash

内容参考 https://a76yyyy.github.io/clash/

**创建 daemon**

用 systemd 创建一个 daemon，在 `/etc/systemd/system/clash.service` 中写入如下内容

```
[Unit]
Description=Clash daemon, A rule-based proxy in Go.
After=network.target

[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/clash -d /etc/clash # /usr/bin/clash 为绝对路径，请根据你实际情况修改

[Install]
WantedBy=multi-user.target
```

**网络代理**

`~/.zshrc` 或 `~/.bashrc` 写入环境变量

```
export http_proxy=127.0.0.1:7890
export https_proxy=127.0.0.1:7890
export socks_proxy=127.0.0.1:7891
```

单独配置 `ssh`，在 `~/.ssh/config` 中写入

```
Host github.com
    HostName github.com
    ProxyCommand socat - PROXY:127.0.0.1:%h:%p,proxyport=7890
```

**配置 web 管理**

web 管理面板代码: https://go.runba.cyou/ssr-download/clash-dashboard.tar.gz

在 `config.yaml` 中添加如下代码

```
external-controller: 127.0.0.1:9090 # ip + port
external-ui: /etc/clash/clash-dashboard # clash-dashboard的路径；
secret: 'PaaRwW3B1Kj9' # PaaRwW3B1Kj9 是登录web管理界面的密码。
```

### 一些常用软件

```
obs-studio
wps-office
virtualbox
yesplaymusic
google-chrome
visual-studio-code
```

### dotfiles

https://github.com/RyanTsi/dotfiles.git