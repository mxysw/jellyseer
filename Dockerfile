# 使用基础镜像
FROM node:20-alpine AS buildimage

# 设置工作目录
WORKDIR /app

# 更新系统并安装必要的软件包
RUN apk update && apk add --no-cache \
  curl \
  cronie \
  bash \
  tzdata \
  tini \
  supervisor

# 复制脚本到容器并赋予执行权限
COPY myscript.sh /usr/local/bin/myscript.sh
RUN chmod +x /usr/local/bin/myscript.sh

# 设置 Cron 定时任务，每 30 分钟执行一次脚本
RUN echo "*/30 * * * * /usr/local/bin/myscript.sh" > /etc/crontabs/root

# 安装 pnpm 包管理器
RUN npm install -g pnpm

# 从构建上下文复制代码
COPY . .

# 安装项目依赖并构建项目
RUN pnpm install && pnpm build

# 清理临时文件和缓存
RUN rm -rf /tmp/* /var/cache/apk/*

# 设置环境变量
ENV NODE_ENV=production

# 配置 Supervisor
RUN echo "[supervisord]" > /etc/supervisord.conf \
  && echo "nodaemon=true" >> /etc/supervisord.conf \
  && echo "loglevel=info" >> /etc/supervisord.conf \
  && echo "[program:crond]" >> /etc/supervisord.conf \
  && echo "command=/usr/sbin/crond -f -s" >> /etc/supervisord.conf \
  && echo "autostart=true" >> /etc/supervisord.conf \
  && echo "autorestart=true" >> /etc/supervisord.conf \
  && echo "[program:pnpm]" >> /etc/supervisord.conf \
  && echo "command=pnpm start" >> /etc/supervisord.conf \
  && echo "autostart=true" >> /etc/supervisord.conf \
  && echo "autorestart=true" >> /etc/supervisord.conf \
  && echo "stdout_logfile=/dev/stdout" >> /etc/supervisord.conf \
  && echo "stdout_logfile_maxbytes=0" >> /etc/supervisord.conf \
  && echo "stderr_logfile=/dev/stderr" >> /etc/supervisord.conf \
  && echo "stderr_logfile_maxbytes=0" >> /etc/supervisord.conf \
  && echo "[program:initial_script]" >> /etc/supervisord.conf \
  && echo "command=/usr/local/bin/myscript.sh" >> /etc/supervisord.conf \
  && echo "autostart=true" >> /etc/supervisord.conf \
  && echo "autorestart=false" >> /etc/supervisord.conf \
  && echo "stdout_logfile=/dev/stdout" >> /etc/supervisord.conf \
  && echo "stdout_logfile_maxbytes=0" >> /etc/supervisord.conf \
  && echo "stderr_logfile=/dev/stderr" >> /etc/supervisord.conf \
  && echo "stderr_logfile_maxbytes=0" >> /etc/supervisord.conf

# 设置 tini 作为入口点
ENTRYPOINT ["/sbin/tini", "--"]

# 使用 Supervisor 作为容器的主进程
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# 暴露应用所需的端口
EXPOSE 5055

