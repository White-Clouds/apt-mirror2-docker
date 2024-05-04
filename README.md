# apt-mirror2-docker

## 简介 About

这个仓库是[apt-mirror2](https://gitlab.com/apt-mirror2/apt-mirror2 "apt-mirror2")的其中一个docker实现[shirokumo/apt-mirror2](https://hub.docker.com/r/shirokumo/apt-mirror2)的构建部分；我所作的部分就是构建一个相对较小的docker镜像来运行apt-mirror2。

镜像采用`alpine:3.19.1`作为基础镜像，安装有`Nginx`，最后生成的镜像大小约80MB。

因为在使用过程中没有经过很长时间的测试，所以可能会有一些奇怪的bug（通常在重启容器后重新手动运行apt-mirror可以解决）。

已知可能问题是，由于上层镜像站的限制或网络问题，速度会突然很慢很慢，但是不是没有速度，然后卡好几个小时，如果卡到下一次定时运行时会在日志里输出一条“ERROR”，`HEALTHCHECK`检测到就会抛出警告；但是，即使发生上述问题，`apt update`依然会正常工作（需要第一次同步时完成同步），`apt-mirror2`在同步过程中直到最后下载完毕才会同步`dists`以及进行自动清理（自动清理需要配置）。

目前容器添加了一个每20分钟运行一次的`check.sh`来解决速度为0的问题，在检测到40行同样的输出时会重启进程。

## 使用说明 Usage

- 请在创建容器前配置好[`mirror.list`](https://gitlab.com/apt-mirror2/apt-mirror2/-/blob/master/mirror.list "mirror.list")
- 容器的默认`mirror.list`位置是`/etc/apt/mirror.list`
- `mirror.list`里默认的同步位置是`/var/spool/apt-mirror`，同时也是`Nginx`的默认根目录，请不要修改
- `Nginx`配置在`80`端口

## 环境变量 ENV

|  变量名 | 默认值  | 说明  |
| :------------: | :------------: | :------------: |
|  TZ |  Asia/Shanghai |  时区设置 |
|  CRON_SCHEDULE |  0 2,8,14,20 \* \* \* |  同步执行时间 |
