# apt-mirror2-docker

[![license](https://img.shields.io/github/license/White-Clouds/apt-mirror2-docker)](https://github.com/White-Clouds/apt-mirror2-docker/blob/main/LICENSE)
[![commits](https://img.shields.io/github/commit-activity/t/White-Clouds/apt-mirror2-docker)](https://github.com/White-Clouds/apt-mirror2-docker/commits/main/)
![last commit](https://badgen.net/github/last-commit/White-Clouds/apt-mirror2-docker)
[![actions](https://img.shields.io/github/actions/workflow/status/White-Clouds/apt-mirror2-docker/docker-image.yml)](https://github.com/White-Clouds/apt-mirror2-docker/actions)
![docker size](https://img.shields.io/docker/image-size/shirokumo/apt-mirror2/latest)
![docker pulls](https://img.shields.io/docker/pulls/shirokumo/apt-mirror2)

## 简介 About

**[v7](https://gitlab.com/apt-mirror2/apt-mirror2/-/releases/v7)的发布带来了作者提供的官方缩小版镜像，`alpine`标签镜像实际大小约20MB左右，可喜可贺**

这个仓库是[apt-mirror2](https://gitlab.com/apt-mirror2/apt-mirror2 "apt-mirror2")的其中一个docker实现[shirokumo/apt-mirror2](https://hub.docker.com/r/shirokumo/apt-mirror2)的构建部分；现在构建只添加`Nginx`和`Cron`定时部分，如果没有在一个容器内管理整个进程的需求，**推荐使用官方提供的镜像**在外部定义`Cron`定时使用。

在结合作者的构建方法后，镜像采用`python:alpine`作为第一阶段构建，`alpine:3`作为基础镜像，安装有`Nginx`，镜像大小约为`30MB`。

作者在v8更新中修复了网络问题，详见[Version 8](https://gitlab.com/apt-mirror2/apt-mirror2/-/releases/v8#bug-fixes)

`latest-pure`分支去除了`Nginx`只保留内部定时，如果你想自定义一个好看的镜像站的话，再创建一个`Nginx`容器或者别的容器会更好。

## 使用说明 Usage

- 请在创建容器前配置好[`mirror.list`](https://gitlab.com/apt-mirror2/apt-mirror2/-/blob/master/mirror.list "mirror.list")，也可以看[这里](https://github.com/White-Clouds/apt-mirror2-docker/blob/main/mirror.list)的中文翻译。
- 容器的默认`mirror.list`位置是`/etc/apt/mirror.list`
- `mirror.list`里默认的同步位置是`/var/spool/apt-mirror`，同时也是`Nginx`的默认根目录，请不要修改
- `Nginx`配置在`80`端口

### 直接使用

```bash
docker run -d \
    --name=apt-mirror2 --network=bridge --restart unless-stopped \
    -p 81:80 \
    -e "CRON_SCHEDULE=0 2,8,14,20 * * *" \
    -e "TZ=Asia/Shanghai" \
    -v /path/apt-mirror:/var/spool/apt-mirror \
    -v /path/mirror.list:/etc/apt/mirror.list \
    shirokumo/apt-mirror2:latest
```

### Docker Compose

```yaml
version: '3'

services:
  apt-mirror2:
    image: shirokumo/apt-mirror2:latest
    network_mode: "bridge"
    container_name: apt-mirror2
    restart: unless-stopped
    ports:
      - 81:80
    environment:
      - CRON_SCHEDULE=0 2,8,14,20 * * *
      - TZ=Asia/Shanghai
    volumes:
      - /path/apt-mirror:/var/spool/apt-mirror
      - /path/mirror.list:/etc/apt/mirror.list
```

## 环境变量 ENV

|      变量名      |         默认值          |   说明   |
|:-------------:|:--------------------:|:------:|
|      TZ       |    Asia/Shanghai     |  时区设置  |
| CRON_SCHEDULE | 0 2,8,14,20 \* \* \* | 同步执行时间 |

## 致谢 Acknowledgement

- [apt-mirror2](https://gitlab.com/apt-mirror2/apt-mirror2 "apt-mirror2")

## 许可证 License

与原项目一致。

GNU General Public License v3.0 or later
