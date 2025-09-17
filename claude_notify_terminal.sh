#!/bin/bash

# Claude Code Notification Script - Supports Bark (mobile push) and terminal-notifier (local notifications)
# Claude Code 通知脚本 - 支持 Bark（手机通知）和 terminal-notifier（本地通知）

# Auto-load .env file if exists | 自动加载 .env 文件（如果存在）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/.env" ]; then
    source "$SCRIPT_DIR/.env"
fi

# Configuration Area | 配置区域
# Bark configuration - read from environment variables for privacy protection
# Bark 配置 - 从环境变量读取，保护隐私
# Setup method | 设置方法：export BARK_KEY="your_bark_key"
BARK_KEY="${BARK_KEY:-}"
BARK_SERVER="${BARK_SERVER:-https://api.day.app}"
# Notification method: bark (default), terminal, both | 通知方式：bark（默认）, terminal, both（两者都用）
NOTIFY_METHOD="${CLAUDE_NOTIFY_METHOD:-bark}"

# Check Bark configuration | 检查 Bark 配置
check_bark_config() {
    if [ -z "$BARK_KEY" ]; then
        echo "⚠️  BARK_KEY environment variable not set | BARK_KEY 环境变量未设置"
        echo "   Please add to ~/.zshrc or ~/.bashrc | 请在 ~/.zshrc 或 ~/.bashrc 中添加："
        echo "   export BARK_KEY=\"your_bark_key\""
        return 1
    fi
    return 0
}

# Smart project name detection | 智能获取项目名称
get_project_name() {
    # Prefer Git repository name if in a Git project | 优先使用 Git 仓库名（如果在 Git 项目中）
    if git rev-parse --git-dir > /dev/null 2>&1; then
        basename "$(git rev-parse --show-toplevel)"
    else
        # Otherwise use current directory name | 否则使用当前目录名
        basename "$PWD"
    fi
}

# Get project information | 获取项目信息
PROJECT_NAME=$(get_project_name)
PROJECT_PATH="$PWD"
TIMESTAMP=$(date "+%H:%M")
FULL_TIME=$(date "+%Y-%m-%d %H:%M:%S")
WORK_DONE="${1:-Claude Code task completed | Claude Code 任务已完成}"

# Check Git status | 检查 Git 状态
if [ -d .git ]; then
    GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    CHANGES=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    GIT_INFO="Branch | 分支: $GIT_BRANCH | Changes | 变更: $CHANGES"
else
    GIT_INFO="Not a Git project | 非 Git 项目"
fi

# Bark notification function | Bark 通知函数
send_bark_notification() {
    # Check Bark configuration | 检查 Bark 配置
    if ! check_bark_config; then
        return 1
    fi
    
    local title="🚀 $PROJECT_NAME"
    local body="$WORK_DONE | $GIT_INFO"
    
    # Simplified URL encoding - using Python for more reliable encoding | 简化的 URL 编码 - 使用 python 进行更可靠的编码
    local encoded_title=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$title'))")
    local encoded_body=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$body'))")
    
    # Build complete URL | 构建完整 URL
    local full_url="$BARK_SERVER/$BARK_KEY/$encoded_title/$encoded_body?group=ClaudeCode&sound=glass.caf"
    
    # Send Bark notification | 发送 Bark 通知
    if response=$(curl -s -m 10 "$full_url" 2>&1) && echo "$response" | grep -q '"code":200'; then
        echo "✅ Notification sent to phone (Bark) | 通知已发送到手机 (Bark)"
        return 0
    else
        echo "⚠️  Bark notification failed | Bark 通知发送失败"
        return 1
    fi
}

# Terminal-notifier notification function | Terminal-notifier 通知函数
send_terminal_notification() {
    if command -v terminal-notifier &> /dev/null; then
        terminal-notifier \
            -title "🚀 $PROJECT_NAME" \
            -subtitle "$GIT_INFO" \
            -message "$WORK_DONE" \
            -sound Glass \
            -group "claude-code" \
            -activate "com.microsoft.VSCode"
        
        echo "✅ Notification sent via terminal-notifier | 通知已通过 terminal-notifier 发送"
        return 0
    else
        # Fallback: use osascript | 备用方案：使用 osascript
        /usr/bin/osascript <<EOF
tell application "System Events"
    display notification "$WORK_DONE" with title "🚀 $PROJECT_NAME" subtitle "$GIT_INFO" sound name "Glass"
end tell
EOF
        echo "⚠️  terminal-notifier not installed, using fallback | terminal-notifier 未安装，使用备用方案"
        echo "   Run the following command to install | 运行以下命令安装："
        echo "   brew install terminal-notifier"
        return 0
    fi
}

# Send notification based on configuration | 根据配置发送通知
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
        # Default to Bark | 默认使用 Bark
        send_bark_notification || send_terminal_notification
        ;;
esac

# Logging feature (disabled by default, uncomment to enable) | 日志功能（默认禁用，如需启用请取消注释）
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

# Terminal output (beautified) | 终端输出（美化版）
echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║        ✅ Claude Code Task Completed | 任务完成          ║"
echo "╠════════════════════════════════════════════════════════╣"
echo "║  📁 Project | 项目: $PROJECT_NAME"
echo "║  🔧 $GIT_INFO"
echo "║  📝 $WORK_DONE"
echo "║  ⏰ Time | 时间: $TIMESTAMP"
echo "╚════════════════════════════════════════════════════════╝"
echo ""