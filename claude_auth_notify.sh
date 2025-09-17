#!/bin/bash

# Claude Code 授权请求通知脚本
# 用于在 Claude Code 请求授权时发送系统通知

# 自动加载 .env 文件（如果存在）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
fi

# 配置区域
# Bark 配置 - 从环境变量读取，保护隐私
# 设置方法：export BARK_KEY="your_bark_key"
BARK_KEY="${BARK_KEY:-}"
BARK_SERVER="${BARK_SERVER:-https://api.day.app}"
# 通知方式：bark（默认）, terminal, both（两者都用）
NOTIFY_METHOD="${CLAUDE_NOTIFY_METHOD:-bark}"

# 检查 Bark 配置
check_bark_config() {
    if [ -z "$BARK_KEY" ]; then
        echo "⚠️  BARK_KEY 环境变量未设置"
        echo "   请在 ~/.zshrc 或 ~/.bashrc 中添加："
        echo "   export BARK_KEY=\"your_bark_key\""
        return 1
    fi
    return 0
}

# 智能获取项目名称
get_project_name() {
    # 优先使用 Git 仓库名（如果在 Git 项目中）
    if git rev-parse --git-dir > /dev/null 2>&1; then
        basename "$(git rev-parse --show-toplevel)"
    else
        # 否则使用当前目录名
        basename "$PWD"
    fi
}

PROJECT_NAME=$(get_project_name)
TIMESTAMP=$(date "+%H:%M:%S")

# 解析输入参数（如果有）
AUTH_TYPE="${1:-需要您的授权}"

# Bark 授权通知函数
send_bark_auth() {
    # 检查 Bark 配置
    if ! check_bark_config; then
        send_terminal_auth
        return
    fi
    
    local title="⚠️ Claude Code 需要授权"
    local body="项目: $PROJECT_NAME | 类型: $AUTH_TYPE | 时间: $TIMESTAMP"
    
    # 使用 python 进行 URL 编码
    local encoded_title=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$title'))")
    local encoded_body=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$body'))")
    
    # 构建完整 URL
    local full_url="$BARK_SERVER/$BARK_KEY/$encoded_title/$encoded_body?group=ClaudeAuth&sound=glass.caf"
    
    # 发送通知
    if response=$(curl -s -m 10 "$full_url" 2>&1) && echo "$response" | grep -q '"code":200'; then
        echo "✅ 授权通知已发送到手机 (Bark)"
    else
        echo "⚠️  Bark 授权通知发送失败，使用备用方案"
        send_terminal_auth
    fi
}

# Terminal 授权通知函数
send_terminal_auth() {
    if command -v terminal-notifier &> /dev/null; then
        # 发送一个通知
        terminal-notifier \
            -title "⚠️ Claude Code 需要授权" \
            -subtitle "项目: $PROJECT_NAME | 时间: $TIMESTAMP" \
            -message "$AUTH_TYPE" \
            -sound "Blow" \
            -group "claude-auth" \
            -ignoreDnD \
            -activate "com.microsoft.VSCode"
        
        echo "✅ 授权通知已通过 terminal-notifier 发送"
    else
        # 备用方案：使用 osascript 并选择更醒目的提示音
        /usr/bin/osascript <<EOF
tell application "System Events"
    display notification "$AUTH_TYPE" with title "⚠️ Claude Code 需要授权" subtitle "项目: $PROJECT_NAME" sound name "Blow"
end tell
EOF
    fi
}

# 根据配置发送通知
case "$NOTIFY_METHOD" in
    bark)
        send_bark_auth
        ;;
    terminal)
        send_terminal_auth
        ;;
    both)
        send_bark_auth &
        send_terminal_auth
        ;;
    *)
        # 默认使用 Bark
        send_bark_auth
        ;;
esac

# 在终端显示醒目提示
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                          ║"
echo "║         ⚠️  Claude Code 需要您的授权  ⚠️                ║"
echo "║                                                          ║"
echo "╠════════════════════════════════════════════════════════╣"
echo "║  📁 项目: $PROJECT_NAME"
echo "║  🔐 类型: $AUTH_TYPE"
echo "║  ⏰ 时间: $TIMESTAMP"
echo "║                                                          ║"
echo "║  👉 请在终端中查看并响应授权请求                          ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# 发出系统提示音（额外提醒）
afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &


# 日志功能（默认禁用，如需启用请取消注释）
# LOG_DIR=~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config
# LOG_FILE="$LOG_DIR/claude_auth_requests.log"
# mkdir -p "$LOG_DIR"
# echo "[$(date '+%Y-%m-%d %H:%M:%S')] 授权请求 - 项目: $PROJECT_NAME - 类型: $AUTH_TYPE" >> "$LOG_FILE"