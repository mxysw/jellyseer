docker run -d \
  --name=jackett \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -e AUTO_UPDATE=true `#optional` \
  -e RUN_OPTS= `#optional` \
  -p 9117:9117 \
  -v /path/to/jackett/data:/config \
  -v /path/to/blackhole:/downloads \
  --restart unless-stopped \
  lscr.io/linuxserver/jackett:latest







  docker run -d \
  --name=emby \
  -p 8096:8096 \
  -v /vol1/1000/docker/emby:/config \
  -v /vol1/1000/media/movie:/media \
  --device /dev/dri:/dev/dri \
  --restart unless-stopped \
  mxy6662/emby:latest
