#!/bin/bash

# 初次运行更新 hosts 文件
/usr/local/bin/update_hosts.sh

# 设置定时任务每 30 分钟运行一次
while true; do
    sleep 1800
    /usr/local/bin/update_hosts.sh
done &
  
# 启动主进程
exec "$@"
