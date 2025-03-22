# 初始化备份目录
BACKUP_DIR="$HOME/.iz_mirror_backup"

function _backup_file() {
  # 创建目录若失败则直接退出
  mkdir -p "$BACKUP_DIR" || { echo "❌ 无法创建备份目录 $BACKUP_DIR"; return 1; }

  local file="$1"
  local filename=$(basename "$file")

  # 组合检查逻辑（按优先级顺序）
  [ -z "$file" ]   && { echo "❌ 未指定文件路径"; return 1; }     # 空参数
  [ -L "$file" ]   && { echo "🔗 跳过符号链接: $filename"; return; } # 符号链接
  [ ! -f "$file" ] && { echo "⚠️  $filename 不存在"; return 1; }  # 文件不存在

  # 执行核心备份逻辑
  local timestamp=$(date +%Y%m%d%H%M%S)
  local backup_path="$BACKUP_DIR/${filename}_${timestamp}.bak"

  cp -p "$file" "$backup_path" || { echo "❌ 备份失败: $filename"; return 1; }
  echo "✅ 已备份 $filename 到 $backup_path"
}

# 添加设置，支持传入自定义标识符
function _inject_settings() {
  # 参数检查
  if [ "$#" -lt 4 ]; then
    echo "❌ 需要至少4个参数"
    return 1
  fi

  local target_file="$1"
  local start_tag="$2"
  local end_tag="$3"
  shift 3
  local settings=("$@")

  # 检查目标文件是否存在
  if [ ! -f "$target_file" ]; then
    echo "❌ 指定的目标文件不存在 '$target_file'"
    return 1
  fi
  
  _backup_file "$target_file"
  
  if grep -Fq "$start_tag" "$target_file"; then
    echo "⚠️  已存在对应设置，请先取消后再设置"
    return 1
  fi
  
  {
    echo ""
    echo "$start_tag"
    for setting in "${settings[@]}"; do
      echo "$setting"
    done
    echo "$end_tag"
  } >> "$target_file"
}

# 移除指定标识符之间的设置，支持多个不同设置块共存时只删除对应块
function _remove_settings() {
  # 参数检查
  if [ "$#" -ne 3 ]; then
    echo "错误：需要3个参数"
    return 1
  fi

  local target_file="$1"
  local start_tag="$2"
  local end_tag="$3"

  # 检查目标文件是否存在
  if [ ! -f "$target_file" ]; then
    echo "错误：指定的目标文件不存在 '$target_file'"
    return 1
  fi

  _backup_file "$target_file"

  # 使用转义防止特殊字符导致问题
  start_tag_escaped=$(printf '%s\n' "$start_tag" | sed 's:[][\/.^$*]:\\&:g')
  end_tag_escaped=$(printf '%s\n' "$end_tag" | sed 's:[][\/.^$*]:\\&:g')

  sed -i '' "/$start_tag_escaped/,/$end_tag_escaped/d" "$target_file"
}

# 检查文件并执行
function _execute_script_if_exists() {
    local script_name=$1
    local script_dir="${${(%):-%x}%/*}"

    local full_path="${script_dir}/${script_name}"

    if [[ -f "$full_path" ]]; then
        if [[ -x "$full_path" ]]; then
            bash "$full_path"
        else
            echo "⚠️  ${script_name} 没有执行权限，正在尝试添加..."
            chmod +x "$full_path"
            if [[ $? -eq 0 ]]; then
                echo "✅ 已成功为 ${script_name} 添加执行权限."
                bash "$full_path"
            else
                echo "❌ 无法为 ${script_name} 添加执行权限."
            fi
        fi
    else
        echo "❌ ${script_name} 文件不存在"
    fi
}

# 显示菜单
function _show_menu() {
    # 定义选项
    local options=("设置Git代理" "设置Flutter镜像" "退出")
    
    echo -e "\n请选择要设置的代理："
    local i=1
    for option in "${options[@]}"; do
        echo "$i) $option"
        ((i++))
    done
}

# 主函数入口
function izproxy() {
    _show_menu

    echo -n "➡️  请输入选项数字："
    read choice

    # 输入验证
    if ! [[ "$choice" =~ ^[1-3]$ ]]; then
        echo "❌ 无效输入"
        return
    fi

    case "$choice" in
        1) _execute_script_if_exists "git_proxy.sh" ;;
        2) _execute_script_if_exists "flutter_mirror.sh" ;;
        3) : ;;
    esac
}
