#!/bin/bash
[[ $(id -u) != 0 ]] && echo -e "请使用root权限运行安装脚本" && exit 1

cmd="apt-get"
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
    if [[ $(command -v yum) ]]; then
        cmd="yum"
    fi
else
    echo "此脚本不支持该系统" && exit 1
fi

install_download() {
if [ ! -d "/root/SSLminerProxy/" ]; then
    mkdir /root/SSLminerproxy
	fi
	
    wget https://raw.githubusercontent.com/MIRA-GE/SSLminerProxy/main/SSLminerProxy_linux -O /root/SSLminerproxy/SSLminerProxy

    chmod 777 /root/SSLminerproxy/SSLminerProxy
}

start_write_config() {
    echo
    echo "下载完成，开启守护"
    echo
    chmod a+x $installPath/SSLminerProxy_linux
    if [ -d "/root/supervisor/conf/" ]; then
        rm /root/supervisor/conf/MinerProxy.conf -f
        echo "[program:MinerProxy]" >>/root/supervisor/conf/MinerProxy.conf
        echo "command=${installPath}/SSLminerProxy_linux" >>/root/supervisor/conf/MinerProxy.conf
        echo "directory=${installPath}/" >>/root/supervisor/conf/MinerProxy.conf
        echo "autostart=true" >>/root/supervisor/conf/MinerProxy.conf
        echo "autorestart=true" >>/root/supervisor/conf/MinerProxy.conf
    elif [ -d "/root/supervisor/conf.d/" ]; then
        rm /root/supervisor/conf.d/MinerProxy.conf -f
        echo "[program:MinerProxy]" >>/root/supervisor/conf.d/MinerProxy.conf
        echo "command=${installPath}/SSLminerProxy_linux" >>/root/supervisor/conf.d/MinerProxy.conf
        echo "directory=${installPath}/" >>/root/supervisor/conf.d/MinerProxy.conf
        echo "autostart=true" >>/root/supervisor/conf.d/MinerProxy.conf
        echo "autorestart=true" >>/root/supervisor/conf.d/MinerProxy.conf
    elif [ -d "/root/supervisord.d/" ]; then
        rm /root/supervisord.d/MinerProxy.ini -f
        echo "[program:MinerProxy]" >>/root/supervisord.d/MinerProxy.ini
        echo "command=${installPath}/SSLminerProxy_linux" >>/root/supervisord.d/MinerProxy.ini
        echo "directory=${installPath}/" >>/root/supervisord.d/MinerProxy.ini
        echo "autostart=true" >>/root/supervisord.d/MinerProxy.ini
        echo "autorestart=true" >>/root/supervisord.d/MinerProxy.ini
    else
        echo
        echo "----------------------------------------------------------------"
        echo
        echo " Supervisor安装目录没了，安装失败"
        echo
        exit 1
    fi

    if [[ $cmd == "apt-get" ]]; then
        ufw disable
    else
        systemctl stop firewalld
    fi

    changeLimit="n"
    if [ $(grep -c "root soft nofile" /root/security/limits.conf) -eq '0' ]; then
        echo "root soft nofile 60000" >>/root/security/limits.conf
        changeLimit="y"
    fi
    if [ $(grep -c "root hard nofile" /root/security/limits.conf) -eq '0' ]; then
        echo "root hard nofile 60000" >>/root/security/limits.conf
        changeLimit="y"
    fi

    clear
    echo
    echo "----------------------------------------------------------------"
    echo
    if [[ "$changeLimit" = "y" ]]; then
        echo "系统连接数限制已经改了，如果第一次运行本程序需要重启!"
        echo
    fi
    supervisorctl reload
    echo "本机防火墙端口18888已经开放，如果还无法连接，请到云服务商控制台操作安全组，放行对应的端口"
    echo "请以访问本机IP:18888"
    echo
    echo "安装完成...守护模式无日志，需要日志的请以nohup ./SSLminerProxy_linux &方式运行"
    echo
    echo "以下配置文件：/root/SSLminerProxy/config.yml，网页端可修改登录密码token"
    echo
    echo "[*---------]"
    sleep 1
    echo "[**--------]"
    sleep 1
    echo "[***-------]"
    sleep 1
    echo "[****------]"
    sleep 1
    echo "[*****-----]"
    sleep 1
    echo "[******----]"
    echo
    cat /root/SSLminerProxy/config.yml
    echo "----------------------------------------------------------------"
}

uninstall() {
    clear
    if [ -d "/root/supervisor/conf/" ]; then
        rm /root/supervisor/conf/MinerProxy.conf -f
    elif [ -d "/root/supervisor/conf.d/" ]; then
        rm /root/supervisor/conf.d/MinerProxy.conf -f
    elif [ -d "/root/supervisord.d/" ]; then
        rm /root/supervisord.d/MinerProxy.ini -f
    fi
    supervisorctl reload
    echo -e "$yellow 已关闭自启动${none}"
}

clear
while :; do
    echo
    echo "-------- MinerProxy 一键安装脚本 by:MinerProxy--------"
    echo "github下载地址:https://github.com/MIRA-GE/SSLminerProxy.git"
    echo "官方电报群:https://t.me/SSLminerProxy "
    echo
    echo " 1. 安装MinerProxy"
    echo
    echo " 2. 卸载MinerProxy"
    echo
    read -p "$(echo -e "请选择 [${magenta}1-2$none]:")" choose
    case $choose in
    1)
        install_download
        start_write_config
        break
        ;;
    2)
        uninstall
        break
        ;;
    *)
        error
        ;;
    esac
done
