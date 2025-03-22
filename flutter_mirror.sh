#!/bin/zsh

# 参数定义
START_TAG="# BEGIN FLUTTER MIRROR SETTINGS"
END_TAG="# END FLUTTER MIRROR SETTINGS"

# 确保加载插件中的函数
source $ZSH/custom/plugins/iz-proxy/iz-proxy.plugin.zsh
if ! type _inject_settings &>/dev/null; then
    echo "❌ 错误：未找到 _inject_settings 函数，请确认 iz-proxy 插件已正确安装"
    exit 1
fi

show_menu() {
    while true; do
        clear
        echo "请选择镜像源："
        echo "1) Flutter 社区 (CFUG) 镜像"
        echo "2) 清华大学镜像"
        echo "3) 取消镜像源"      
        echo "4) 退出"            
        echo -n "➡️  请输入选项数字："

        read choice

        case $choice in
            1) 
                enable_mirror 1
                # sleep 1
                exit 0
                ;;
            2)  
                enable_mirror 2
                exit 0
                ;;
            3) 
                disable_mirror
                exit 0
                ;;
            4) exit 0 ;;          
            *) echo "❌ 无效选项，请重新输入" ;;
        esac

    done
}

enable_mirror() {
    local mirror_choice=$1
    local setting=""

    case $mirror_choice in
        1)
            setting=$'export FLUTTER_STORAGE_BASE_URL="https://storage.flutter-io.cn"\nexport PUB_HOSTED_URL="https://pub.flutter-io.cn"'
            ;;
        2)
            setting=$'export FLUTTER_STORAGE_BASE_URL="https://mirrors.tuna.tsinghua.edu.cn/flutter"\nexport PUB_HOSTED_URL="https://mirrors.tuna.tsinghua.edu.cn/dart-pub"'
            ;;
        *)
            echo "❌ 镜像源选择无效"
            return 1
            ;;
    esac

    _inject_settings "$HOME/.zshrc" "$START_TAG" "$END_TAG" "$setting"
    echo "✅ 镜像设置已生效，请重新加载终端配置或运行 'source ~/.zshrc'"
}


disable_mirror() {
    _remove_settings "$HOME/.zshrc" "$START_TAG" "$END_TAG"
    unset FLUTTER_STORAGE_BASE_URL PUB_HOSTED_URL
    echo "✅ 镜像已取消，请重新加载终端配置或运行 'source ~/.zshrc'"
}

show_menu