# sslocal-tool

shadowsocks命令行管理工具（基于sslocal封装的脚本）

## 背景
有多个搭建ss服务的VPS，需要测试VPS延迟和丢包率，命令行切换合适的服务器

## 功能
```
list                 列出可用服务器（配置）
status               查看sslocal运行状态
run                  运行想要的服务器（配置）
test                 测试服务器延迟和丢包率
stop                 停止sslocal
help                 查看帮助
```

## 使用说明
> 注：只在Ubuntu测试过，如用其他发行版本有问题，请自行修改脚本
1. 假设你有2个搭建ss的服务器，一个在旧金山（sfo, ip: 1.1.1.1），一个在纽约（nyc, ip: 2.2.2.2）
1. 修改`/etc/hosts`，添加`1.1.1.1 sfoserver`和`2.2.2.2 nycserver`
1. 新建目录`/usr/local/ssl`（也可以是其他目录，例如：`/opt/ssl`）
1. 下载[ssl.sh](/ssl.sh)到`/usr/local/ssl/ssl.sh`
1. 新建ss配置文件`/usr/local/ssl/sfo.json`和`/usr/local/ssl/nyc.json`，并写入配置
1. 编辑`~/.bash_aliases` （Ubuntu，其他发行版本自己Google）,添加`alias ssl='/usr/local/ssl/ssl.sh'`
1. 启动新的终端，执行命令`ssl`, `ssl list`， `ssl test`, `ssl run sfo`, `ssl status`, `ssl stop`等命令

## TODO
[ ] ssl test: 详细信息
[ ] ssl test: 指定server

## 许可证
[Apache-2.0](http://www.apache.org/licenses/LICENSE-2.0)