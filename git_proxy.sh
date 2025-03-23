#!/bin/zsh

# 默认配置
DEFAULT_HTTP_PORT=7897
DEFAULT_SOCKS5_PORT=1080
DEFAULT_HOST="127.0.0.1"

show_menu() {
    while true; do
        clear
        echo "Git 代理设置:"
        echo "1) 设置 HTTP 代理"
        echo "2) 设置 SOCKS5 代理"
        echo "3) 取消代理设置"
        echo "4) 退出"
        echo -n "➡️  请输入选项数字："

        read choice

        case $choice in
            1) enable_proxy "http" ;;
            2) enable_proxy "socks5" ;;
            3) disable_proxy ;;
            4) exit 0 ;;
            *) 
                echo "❌ 无效选项，请重新输入" 
                read -p "按回车键继续..."
                ;;
        esac

        # read -k1 "?\n按任意键返回菜单..."
    done
}

enable_proxy() {
    local protocol=$1
    local port_default=$([ "$protocol" = "http" ] && echo $DEFAULT_HTTP_PORT || echo $DEFAULT_SOCKS5_PORT)
    local scheme=$([ "$protocol" = "http" ] && echo "http" || echo "socks5h")

    # 获取代理信息
    echo -n "➡️  请输入代理地址 (默认: $DEFAULT_HOST):"
    read host

    host=${host:-$DEFAULT_HOST}

    while true; do
        echo -n "➡️  请输入代理端口 (默认: $port_default):"
        read port

        port=${port:-$port_default}
        [[ $port =~ ^[0-9]+$ ]] && break || echo "❌ 端口必须是数字"
    done

    # 设置代理
    git config --global http.proxy "$scheme://$host:$port"
    git config --global https.proxy "$scheme://$host:$port"
    echo "✅ ${protocol:u} 代理已设置: $scheme://$host:$port"
    exit 0
}

disable_proxy() {
    git config --global --unset http.proxy
    git config --global --unset https.proxy
    echo "✅ 已取消所有 Git 代理设置"

    # read -p "按回车键继续..." -n 1 -r
    exit 0
}

# 如果直接执行脚本则自动启动菜单
# [[ $ZSH_EVAL_CONTEXT == "toplevel" ]] && show_menu
show_menu