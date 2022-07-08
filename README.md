# DDoS Deflate
此 DDoS Deflate 分支来自已经不存在的 http://deflate.medialayer.com/
(见[MediaLayer倒闭](http://www.webhostingtalk.com/showthread.php?t=1494121&highlight=medialayer))

此分支在原来的基础上进行了修复、改进和新功能。

**原作者：** Zaf < zaf@vsnl.com > (版权所有 (C) 2005)

**维护者：** Jefferson González < jgmdev@gmail.com >

**贡献者（BSD 支持）：** Marc S. Brooks < devel@mbrooks.info >

**翻译者：** Shiro < shiro@332.email>

## 关于

(D)DoS Deflate 是一个轻量级的 bash shell 脚本，旨在帮助阻止DDOS拒绝服务攻击。它利用下面的命令创建连接到服务器的 IP 地址列表，以及他们的连接总数。它是最简单的一种并且最容易在软件级别安装解决方案。

ss -Hntu | awk '{print $6}' | sort | uniq -c | sort -nr

超过预配置连接数的 IP 地址会在服务器的防火墙中被自动阻止，该防火墙可以是 ipfw、iptables 或 高级策略防火墙 (APF)。

### 程序特点

* IPv6 支持。
* 可以通过 /etc/ddos/ignore.ip.list 将IP地址列入白名单。
* 可以通过 /etc/ddos/ignore.host.list 将主机名列入白名单。
* /etc/ddos/ignore.ip.list 支持IP范围和CIDR语法
* 简单的配置文件： /etc/ddos/ddos.conf _
* IP 地址在预先配置的时间限制后自动解锁（默认：600 秒）
* 该脚本可以通过配置文件以选定的频率作为cron作业运行（默认：1 分钟）
* 脚本可以通过配置文件以选定的频率作为守护进程运行（默认：5 秒）
* 当 IP 地址被阻止时，您可以收到电子邮件警报。
* 通过连接状态控制阻塞（参见 man ss 或 man nestat ）。
* 自动检测防火墙。
* 支持 APF、CSF、 ipfw 和 iptables。
* 将事件记录到 /var/log/ddos.log。
* 只能禁止传入连接或按特定端口规则。
* 使用 iftop 和 tc 降低达到特定限制的 IP 地址的传输速度的选项。
* 使用 tcpkill 减少攻击者打开的进程数量。
* Cloudflare 支持通过使用 tcpdump 获取真实用户ip并使用 iptables 字符串匹配来断开连接。

## 依赖项

安装脚本支持自动安装所需的依赖项，但可能无法安装部分或全部。您可能希望在继续安装之前手动安装所需的依赖项，如下面列出的。

## Ubuntu/Debian安装依赖
```shell
sudo apt install dnsutils
sudo apt-get install net-tools
sudo apt-get install tcpdump
sudo apt-get install dsniff -y
sudo apt install grepcidr
```
## 安装

以 root 用户身份执行以下命令：

境外使用：
```shell
wget https://github.com/ShiroSekai/DDoS-Deflate-Zh/archive/refs/heads/master.zip -O ddos.zip && unzip ddos.zip && cd DDoS-Deflate-Zh-master && ./install.sh
```

境内使用：
```shell
wget https://jihulab.com/ShiroSekai/DDoS-Deflate-Zh/-/archive/master/DDoS-Deflate-Zh-master.zip -O ddos.zip && unzip ddos.zip && cd DDoS-Deflate-Zh-master && ./install.sh
```

## 卸载

以 root 用户身份执行以下命令：

```shell
cd DDoS-Deflate-Zh-master && ./uninstall.sh
```

## 使用方法

安装程序将自动检测您的系统是否支持 init.d 脚本、systemd 服务或 cron 作业。 如果找到其中之一，它将安装 apropiate 文件并启动 ddos 脚本。 在 init.d 和 systemd 的情况下，ddos 脚本作为守护进程启动，默认情况下监控间隔设置为 5 秒。 守护进程检测攻击的速度比 cron 作业快得多，因为 cron 的间隔为 1 分钟。

安装完 (D)Dos deflate 后，继续修改配置文件以满足您的需求。

**/etc/ddos/ignore.host.list**

在此文件中，您可以添加要列入白名单的主机名列表。
例如:

> googlebot.com <br />
> my-dynamic-ip.somehost.com

**/etc/ddos/ignore.ip.list**

在此文件中，您可以添加要列入白名单的IP列表。
例如:

> 12.43.63.13 <br />
> 165.123.34.43-165.123.34.100 <br />
> 192.168.1.0/24 <br />
> 129.134.131.2

**/etc/ddos/ddos.conf**

ddos 脚本的行为由该配置文件修改。
有关更多详细信息，请参阅 **man ddos**，其中包含不同配置选项的文档。

修改配置文件后，您将需要重新启动守护程序。
如果在 systemd 上运行：

> systemctl restart ddos

如果作为常规的 init.d 脚本运行：

> /etc/init.d/ddos restart <br />
> or <br />
> service ddos restart

将脚本作为 cronjob 运行时，不需要重新启动。

## 命令行使用方法

**ddos** [选项] [N]

*N :  tcp / udp连接数（默认 150）*

#### 选项

**-h | --help:**

   显示帮助.

**-c | --cron:**

   创建cron作业以定期运行脚本（默认 1 分钟）。

**-i | --ignore-list:**

   列出白名单中的IP地址。

**-b | --bans-list:**

   列出当前禁止的IP地址。

**-u | --unban:**

   取消禁止指定的IP地址。

**-d | --start:**

   启动（初始化一个守护进程来监控连接。）

**-s | --stop:**

   停止守护进程。

**-t | --status:**

   如果当前正在运行，则显示守护程序和pid的状态。.

**-v[4|6] | --view [4|6]:**

   显示与服务器的活动连接。

**-y[4|6] | --view-port [4|6]:**

   显示与服务器的活动连接，包括端口。

**-k | --kill:**

   阻止所有超过 N 个连接的IP地址。
