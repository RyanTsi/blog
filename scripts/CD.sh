#!/bin/bash

# 配置参数
LOCAL_DIR="/mnt/c/Users/sola/Documents/blog/public/"
REMOTE_DIR="/var/www/solarain"
REMOTE_USER="root"  # 替换为远程服务器用户名
REMOTE_HOST="${REMOTE_HOST:-127.0.0.1}"  # 替换为远程服务器IP/域名，默认从环境变量中读取到这个数据。
SSH_PORT=22  # 默认SSH端口，按需修改

echo "${REMOTE_HOST}"

# 检查本地目录是否存在
if [ ! -d "$LOCAL_DIR" ]; then
  echo "错误：本地目录不存在 $LOCAL_DIR"
  exit 1
fi

# 执行同步操作
echo "开始同步: $LOCAL_DIR -> $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"
rsync -avz --delete -e "ssh -p $SSH_PORT" \
  "$LOCAL_DIR" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR"

# 检查执行结果
if [ $? -eq 0 ]; then
  echo "√ 同步成功！"
  echo "已更新内容:"
  ssh -p $SSH_PORT $REMOTE_USER@$REMOTE_HOST "ls -l $REMOTE_DIR"
else
  echo "x 同步失败！"
  exit 1
fi