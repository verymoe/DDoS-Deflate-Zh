#!/bin/sh

# 检查是否是root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请在root用户下运行。"
    exit 1
fi

clear

echo "卸载 DOS-Deflate"

if [ -e '/etc/init.d/ddos' ]; then
    echo; echo -n "正在删除初始化服务..."
    UPDATERC_PATH=`whereis update-rc.d`
    if [ "$UPDATERC_PATH" != "update-rc.d:" ]; then
        service ddos stop > /dev/null 2>&1
        update-rc.d ddos remove > /dev/null 2>&1
    fi
    rm -f /etc/init.d/ddos
    echo -n ".."
    echo " (完成)"
fi

if [ -e '/etc/rc.d/ddos' ]; then
    echo; echo -n "正在删除 rc 服务..."
    service ddos stop > /dev/null 2>&1
    rm -f /etc/rc.d/ddos
    sed -i '' '/ddos_enable/d' /etc/rc.conf
    echo -n ".."
    echo " (完成)"
fi

if [ -e '/usr/lib/systemd/system/ddos.service' ]; then
    echo; echo -n "正在删除旧的 systemd 服务..."
    SYSTEMCTL_PATH=`whereis update-rc.d`
    if [ "$SYSTEMCTL_PATH" != "systemctl:" ]; then
        systemctl stop ddos > /dev/null 2>&1
        systemctl disable ddos > /dev/null 2>&1
    fi
    rm -f /usr/lib/systemd/system/ddos.service
    echo -n ".."
    echo " (完成)"
fi

if [ -e '/lib/systemd/system/ddos.service' ]; then
    echo; echo -n "正在删除 systemd 服务..."
    SYSTEMCTL_PATH=`whereis update-rc.d`
    if [ "$SYSTEMCTL_PATH" != "systemctl:" ]; then
        systemctl stop ddos > /dev/null 2>&1
        systemctl disable ddos > /dev/null 2>&1
    fi
    rm -f /lib/systemd/system/ddos.service
    echo -n ".."
    echo " (完成)"
fi

echo -n "正在删除脚本文件..."
if [ -e '/usr/local/sbin/ddos' ]; then
    rm -f /usr/local/sbin/ddos
    echo -n "."
fi

if [ -d '/usr/local/ddos' ]; then
    rm -rf /usr/local/ddos
    echo -n "."
fi
echo " (done)"

echo -n "正在删除指令手册..."
if [ -e '/usr/share/man/man1/ddos.1' ]; then
    rm -f /usr/share/man/man1/ddos.1
    echo -n "."
fi
if [ -e '/usr/share/man/man1/ddos.1.gz' ]; then
    rm -f /usr/share/man/man1/ddos.1.gz
    echo -n "."
fi
echo " (done)"

if [ -e '/etc/logrotate.d/ddos' ]; then
    echo -n "正在删除 logrotate 配置..."
    rm -f /etc/logrotate.d/ddos
    echo -n ".."
    echo " (完成)"
fi

if [ -e '/etc/cron.d/ddos' ]; then
    echo -n "正在删除 cron 作业..."
    rm -f /etc/cron.d/ddos
    echo -n ".."
fi
if [ -e '/etc/crontab' ]; then
    echo -n "正在删除 cron 作业..."
    sed -i '' '/ddos/d' /etc/crontab 2>/dev/null
    echo -n ".."
fi
echo " (完成)"
if [ -e '/etc/newsyslog.d/ddos' ]; then
    echo -n "正在删除 newsyslog 作业..."
    rm -f /etc/newsyslog.d/ddos
    echo -n ".."
    echo " (完成)"
fi

echo; echo "卸载完成!"; echo
