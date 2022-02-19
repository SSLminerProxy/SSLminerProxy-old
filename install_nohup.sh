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

install() {
    if [ -d "/root/minerproxy" ]; then
        echo -e "您已安装了该软件,如果确定没有安装,请输入rm -rf /root/minerproxy" && exit 1
    fi
	if [ -d "/root/miner_Proxy" ]; then
        echo -e "您已安装了该软件,如果确定没有安装,请输入rm -rf /root/miner_Proxy" && exit 1
    fi

    $cmd update -y
	
	if [ ! -d "/root/SSLminerproxy" ]; then
    mkdir /root/SSLminerproxy
    fi
	
    wget https://raw.githubusercontent.com/MIRA-GE/SSLminerProxy/main/SSLminerProxy_linux -O /root/SSLminerproxy/minerProxy

    chmod 777 /root/SSLminerproxy/minerProxy

    wget https://raw.githubusercontent.com/MIRA-GE/SSLminerProxy/main/run.sh -O /root/SSLminerproxy/run.sh
	
    chmod 777 /root/SSLminerproxy/run.sh
	
    echo "如果没有报错则安装成功"
    echo "正在启动..."
    nohup ./SSLminerProxy & 
    sleep 1s
    cat /root/SSLminerproxy/config.yml
    echo "<<<如果成功了,这是您的端口号 请打开 http://服务器ip:端口 访问web服务进行配置:默认端口号为18888,请记录您的token,请尽快登陆并修改账号密码"
    echo "已启动web后台 您可运行 tail -f nohup.out 查看程序输出"

}

uninstall() {
    read -p "是否确认删除SSLminerProxy[yes/no]：" flag
    if [ -z $flag ]; then
        echo "输入错误" && exit 1
    else
        if [ "$flag" = "yes" -o "$flag" = "ye" -o "$flag" = "y" ]; then
            killall SSLminerProxy
            rm -rf /root/SSLminerProxy
            echo "卸载SSLminerProxy成功"
        fi
    fi
}


restart() {
    killall SSLminerProxy
    cd /root/SSLminerProxy
    nohup ./SSLminerProxy &
    sleep 0.2s
    echo "SSLminerProxy 重新启动成功"
    echo "您可运行 tail -f nohup.out 查看程序输出"
}

stop() {
        killall minerProxy
    fi
    echo "SSLminerProxy 已停止"
}

change_limit(){
    num="n"
    if [ $(grep -c "root soft nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root soft nofile 102400" >>/etc/security/limits.conf
        num="y"
    fi

    if [[ "$num" = "y" ]]; then
        echo "连接数限制已修改为102400,重启服务器后生效"
    else
        echo -n "当前连接数限制："
        ulimit -n
    fi
}

check_limit(){
    echo -n "当前连接数限制："
    ulimit -n
}

echo "======================================================="
echo "加密中转SSLminerProxy一键管理工具"
echo "  1、安装(默认安装到/root/SSLminerProxy)"
echo "  2、卸载"
echo "  3、重启"
echo "  4、停止"
echo "  5、解除linux系统连接数限制(需要重启服务器生效)"
echo "  6、查看当前系统连接数限制"
#echo "  8、配置开机启动"
echo "======================================================="
read -p "$(echo -e "请选择[1-7]：")" choose
case $choose in
1)
    install
    ;;
2)
    uninstall
    ;;
3)
    restart
    ;;
4)
    stop
    ;;
5)
    change_limit
    ;;
6)
    check_limit
    ;;
*)
    echo "输入错误请重新输入！"
    ;;
esac
