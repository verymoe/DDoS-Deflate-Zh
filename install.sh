#!/bin/sh

# 检查是否是root权限
if [ "$(id -u)" -ne 0 ]; then
    echo "请在root用户下运行。"
    exit 1
fi

# 检查需要的依赖
if [ -f "/usr/bin/apt-get" ]; then
    install_type='2';
    install_command="apt-get"
elif [ -f "/usr/bin/yum" ]; then
    install_type='3';
    install_command="yum"
elif [ -f "/usr/sbin/pkg" ]; then
    install_type='4';
    install_command="pkg"
else
    install_type='0'
fi

packages='nslookup netstat ss ifconfig tcpdump tcpkill timeout awk sed grep grepcidr'

if  [ "$install_type" = '4' ]; then
    packages="$packages ipfw"
else
    packages="$packages iptables"
fi

for dependency in $packages; do
    is_installed=`which $dependency`
    if [ "$is_installed" = "" ]; then
        echo "错误: 依赖项 '$dependency' 缺失。"
        if [ "$install_type" = '0' ]; then
            exit 1
        else
            echo -n "通过 '$install_command'? 自动安装依赖(回车继续，输入n退出) "
        fi
        read install_sign
        if [ "$install_sign" = 'N' -o "$install_sign" = 'n' ]; then
           exit 1
        fi
        eval "$install_command install -y $(grep $dependency config/dependencies.list | awk '{print $'$install_type'}')"
    fi
done

if [ -d "$DESTDIR/usr/local/ddos" ]; then
    echo "请先卸载之前的版本。"
    exit 0
else
    mkdir -p "$DESTDIR/usr/local/ddos"
fi

clear

if [ ! -d "$DESTDIR/etc/ddos" ]; then
    mkdir -p "$DESTDIR/etc/ddos"
fi

if [ ! -d "$DESTDIR/var/lib/ddos" ]; then
    mkdir -p "$DESTDIR/var/lib/ddos"
fi

echo; echo '安装 DOS-Deflate 1.3'; echo

if [ ! -e "$DESTDIR/etc/ddos/ddos.conf" ]; then
    echo -n '添加: /etc/ddos/ddos.conf...'
    cp config/ddos.conf "$DESTDIR/etc/ddos/ddos.conf" > /dev/null 2>&1
    echo " (完成)"
fi

if [ ! -e "$DESTDIR/etc/ddos/ignore.ip.list" ]; then
    echo -n '添加: /etc/ddos/ignore.ip.list...'
    cp config/ignore.ip.list "$DESTDIR/etc/ddos/ignore.ip.list" > /dev/null 2>&1
    echo " (完成)"
fi

if [ ! -e "$DESTDIR/etc/ddos/ignore.host.list" ]; then
    echo -n '添加: /etc/ddos/ignore.host.list...'
    cp config/ignore.host.list "$DESTDIR/etc/ddos/ignore.host.list" > /dev/null 2>&1
    echo " (完成)"
fi

echo -n '添加: /usr/local/ddos/LICENSE...'
cp LICENSE "$DESTDIR/usr/local/ddos/LICENSE" > /dev/null 2>&1
echo " (完成)"

echo -n '添加: /usr/local/ddos/ddos.sh...'
cp src/ddos.sh "$DESTDIR/usr/local/ddos/ddos.sh" > /dev/null 2>&1
chmod 0755 /usr/local/ddos/ddos.sh > /dev/null 2>&1
echo " (完成)"

echo -n '创建 ddos​​ 脚本: /usr/local/sbin/ddos...'
mkdir -p "$DESTDIR/usr/local/sbin/"
echo "#!/bin/sh" > "$DESTDIR/usr/local/sbin/ddos"
echo "/usr/local/ddos/ddos.sh \$@" >> "$DESTDIR/usr/local/sbin/ddos"
chmod 0755 "$DESTDIR/usr/local/sbin/ddos"
echo " (完成)"

echo -n '添加指令帮助页...'
mkdir -p "$DESTDIR/usr/share/man/man1/"
cp man/ddos.1 "$DESTDIR/usr/share/man/man1/ddos.1" > /dev/null 2>&1
chmod 0644 "$DESTDIR/usr/share/man/man1/ddos.1" > /dev/null 2>&1
echo " (完成)"

if [ -d /etc/logrotate.d ]; then
    echo -n '添加 logrotate 配置...'
    mkdir -p "$DESTDIR/etc/logrotate.d/"
    cp src/ddos.logrotate "$DESTDIR/etc/logrotate.d/ddos" > /dev/null 2>&1
    chmod 0644 "$DESTDIR/etc/logrotate.d/ddos"
    echo " (完成)"
fi

echo;

if [ -d /etc/newsyslog.conf.d ]; then
    echo -n '添加 newsyslog 配置...'
    mkdir -p "$DESTDIR/etc/newsyslog.conf.d"
    cp src/ddos.newsyslog "$DESTDIR/etc/newsyslog.conf.d/ddos" > /dev/null 2>&1
    chmod 0644 "$DESTDIR/etc/newsyslog.conf.d/ddos"
    echo " (完成)"
fi

echo;

if [ -d /lib/systemd/system ]; then
    echo -n '正在设置 systemd 服务...'
    mkdir -p "$DESTDIR/lib/systemd/system/"
    cp src/ddos.service "$DESTDIR/lib/systemd/system/" > /dev/null 2>&1
    chmod 0644 "$DESTDIR/lib/systemd/system/ddos.service" > /dev/null 2>&1
    echo " (完成)"

    # 检查是否安装了 systemctl 并激活服务
    SYSTEMCTL_PATH=`whereis systemctl`
    if [ "$SYSTEMCTL_PATH" != "systemctl:" ] && [ "$DESTDIR" = "" ]; then
        echo -n "正在激活 ddos​​防御 服务..."
        systemctl enable ddos > /dev/null 2>&1
        systemctl start ddos > /dev/null 2>&1
        echo " (完成)"
    else
        echo "（警告）ddos服务需要手动启动..."
    fi
elif [ -d /etc/init.d ]; then
    echo -n '设置初始化脚本...'
    mkdir -p "$DESTDIR/etc/init.d/"
    cp src/ddos.initd "$DESTDIR/etc/init.d/ddos" > /dev/null 2>&1
    chmod 0755 "$DESTDIR/etc/init.d/ddos" > /dev/null 2>&1
    echo " (完成)"

    # 检查是否安装了 update-rc 并激活服务
    UPDATERC_PATH=`whereis update-rc.d`
    if [ "$UPDATERC_PATH" != "update-rc.d:" ] && [ "$DESTDIR" = "" ]; then
        echo -n "正在激活 ddos​​ 服务..."
        update-rc.d ddos defaults > /dev/null 2>&1
        service ddos start > /dev/null 2>&1
        echo " (完成)"
    else
        echo "（警告）ddos服务需要手动启动..."
    fi
elif [ -d /etc/rc.d ]; then
    echo -n '正在设置 rc 脚本...'
    mkdir -p "$DESTDIR/etc/rc.d/"
    cp src/ddos.rcd "$DESTDIR/etc/rc.d/ddos" > /dev/null 2>&1
    chmod 0755 "$DESTDIR/etc/rc.d/ddos" > /dev/null 2>&1
    echo " (完成)"

    # Activate the service
    echo -n "正在激活 ddos​​ 服务..."
    echo 'ddos_enable="YES"' >> /etc/rc.conf
    service ddos start > /dev/null 2>&1
    echo " (完成)"
elif [ -d /etc/cron.d ] || [ -f /etc/crontab ]; then
    echo -n '创建 cron 以每分钟运行一次脚本...'
    /usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
    echo " (完成)"
fi

echo; echo '安装完成！'
echo '配置文件在 /etc/ddos/'
echo
echo '请将您的建议发送至：'
echo 'https://github.com/jgmdev/ddos-deflate/issues'
echo '有关汉化建议发送至：'
echo 'https://justmyblog.net/882.html'
echo

exit 0
