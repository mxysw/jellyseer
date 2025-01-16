#!/bin/bash

# 检查是否是第一次运行
if [ ! -f "/etc/hosts.original" ]; then
    # 备份原始的 hosts 文件
    cp /etc/hosts /etc/hosts.original
    echo "$(date): Original hosts file has been backed up." >> /var/log/update-hosts.log
fi

# 下载新的 hosts 内容
TEMP_HOSTS_FILE="/tmp/new_hosts.txt"
curl -s "https://tmdbhosts.online/" -o "$TEMP_HOSTS_FILE"

# 检查下载是否成功
if [ $? -ne 0 ]; then
    echo "$(date): Failed to download the hosts file." >> /var/log/update-hosts.log
    exit 1
fi

# 合并新的 hosts 文件
{
    cat /etc/hosts.original
    echo ""
    echo "# START OF CUSTOM HOSTS"
    cat "$TEMP_HOSTS_FILE"
    echo "# END OF CUSTOM HOSTS"
} > /tmp/final_hosts.txt

# 替换 /etc/hosts 内容
cat /tmp/final_hosts.txt > /etc/hosts

# 检查是否成功更新
if [ $? -eq 0 ]; then
    echo "$(date): Hosts file has been updated successfully." >> /var/log/update-hosts.log
else
    echo "$(date): Failed to update the hosts file." >> /var/log/update-hosts.log
fi

# 清理临时文件
rm -f "$TEMP_HOSTS_FILE" /tmp/final_hosts.txt
