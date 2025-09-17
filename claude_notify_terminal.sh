#!/bin/bash

# Claude Code 通知脚本 - 支持 Bark（手机通知）和 terminal-notifier（本地通知）

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

# 获取项目信息
PROJECT_NAME=$(get_project_name)
PROJECT_PATH="$PWD"
TIMESTAMP=$(date "+%H:%M")
FULL_TIME=$(date "+%Y-%m-%d %H:%M:%S")
WORK_DONE="${1:-Claude Code 任务已完成}"

# 检查 Git 状态
if [ -d .git ]; then
    GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    GIT_INFO="分支: $GIT_BRANCH | 变更: $CHANGES"
else
    GIT_INFO="非 Git 项目"
fi

# Bark 通知函数
send_bark_notification() {
    # 检查 Bark 配置
    if ! check_bark_config; then
        return 1
    fi
    
    local title="🚀 $PROJECT_NAME"
    local body="$WORK_DONE | $GIT_INFO"
    
    # 简化的 URL 编码 - 使用 python 进行更可靠的编码
    local encoded_title=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$title'))")
    local encoded_body=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$body'))")
    
    # 构建完整 URL
    local full_url="$BARK_SERVER/$BARK_KEY/$encoded_title/$encoded_body?group=ClaudeCode&sound=glass.caf"
    
    # 发送 Bark 通知
    if response=$(curl -s -m 10 "$full_url" 2>&1) && echo "$response" | grep -q '"code":200'; then
        echo "✅ 通知已发送到手机 (Bark)"
        return 0
    else
        echo "⚠️  Bark 通知发送失败"
        return 1
    fi
}

# Terminal-notifier 通知函数
send_terminal_notification() {
    if command -v terminal-notifier &> /dev/null; then
        terminal-notifier \
            -title "🚀 $PROJECT_NAME" \
            -subtitle "$GIT_INFO" \
            -message "$WORK_DONE" \
            -sound Glass \
            -group "claude-code" \
            -activate "com.microsoft.VSCode"
        
        echo "✅ 通知已通过 terminal-notifier 发送"
        return 0
    else
        # 备用方案：使用 osascript
        /usr/bin/osascript <<EOF
tell application "System Events"
    display notification "$WORK_DONE" with title "🚀 $PROJECT_NAME" subtitle "$GIT_INFO" sound name "Glass"
end tell
EOF
        echo "⚠️  terminal-notifier 未安装，使用备用方案"
        echo "   运行以下命令安装："
        echo "   bash /Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/install_notifier.sh"
        return 0
    fi
}

# 根据配置发送通知
case "$NOTIFY_METHOD" in
    bark)
        send_bark_notification || send_terminal_notification
        ;;
    terminal)
        send_terminal_notification
        ;;
    both)
        send_bark_notification
        send_terminal_notification
        ;;
    *)
        # 默认使用 Bark
        send_bark_notification || send_terminal_notification
        ;;
esac

# 日志功能（默认禁用，如需启用请取消注释）
# LOG_DIR=~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config
# LOG_FILE="$LOG_DIR/claude_tasks.log"
# mkdir -p "$LOG_DIR"
# 
# echo "[$FULL_TIME]" >> "$LOG_FILE"
# echo "  项目: $PROJECT_NAME" >> "$LOG_FILE"
# echo "  路径: $PROJECT_PATH" >> "$LOG_FILE"
# echo "  状态: $GIT_INFO" >> "$LOG_FILE"
# echo "  任务: $WORK_DONE" >> "$LOG_FILE"
# echo "---" >> "$LOG_FILE"

# 终端输出（美化版）
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║              ✅ Claude Code 任务完成                     ║"
echo "╠════════════════════════════════════════════════════════╣"
echo "║  📁 项目: $PROJECT_NAME"
echo "║  🔧 $GIT_INFO"
echo "║  📝 $WORK_DONE"
echo "║  ⏰ 时间: $TIMESTAMP"
echo "╚════════════════════════════════════════════════════════╝"
echo ""