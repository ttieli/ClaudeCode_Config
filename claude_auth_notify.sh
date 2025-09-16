#!/bin/bash

# Claude Code 授权请求通知脚本
# 用于在 Claude Code 请求授权时发送系统通知

# 智能获取项目名称
get_project_name() {
    # 方法1：如果在 Git 仓库中，使用仓库名
    if git rev-parse --git-dir > /dev/null 2>&1; then
        echo $(basename "$(git rev-parse --show-toplevel)")
    # 方法2：如果当前目录名是 "Project"，尝试获取最近修改的子目录
    elif [ "$(basename "$PWD")" = "Project" ]; then
        # 获取最近修改的子目录作为项目名
        RECENT_DIR=$(ls -td */ 2>/dev/null | head -1 | sed 's|/$||')
        if [ -n "$RECENT_DIR" ]; then
            echo "$RECENT_DIR"
        else
            echo "$(basename "$PWD")"
        fi
    # 方法3：使用当前目录名
    else
        echo "$(basename "$PWD")"
    fi
}

PROJECT_NAME=$(get_project_name)
TIMESTAMP=$(date "+%H:%M:%S")

# 解析输入参数（如果有）
AUTH_TYPE="${1:-需要您的授权}"

# 使用 terminal-notifier 发送紧急通知
if command -v terminal-notifier &> /dev/null; then
    # 第一个通知
    terminal-notifier \
        -title "⚠️ Claude Code 需要授权" \
        -subtitle "项目: $PROJECT_NAME | 时间: $TIMESTAMP" \
        -message "$AUTH_TYPE" \
        -sound "Blow" \
        -group "claude-auth" \
        -ignoreDnD \
        -activate "com.microsoft.VSCode"
    
    # 第二个通知：2秒后重复
    sleep 2
    terminal-notifier \
        -title "⚠️ Claude Code 需要授权" \
        -subtitle "项目: $PROJECT_NAME | 时间: $TIMESTAMP" \
        -message "$AUTH_TYPE" \
        -sound "Blow" \
        -group "claude-auth-repeat" \
        -ignoreDnD \
        -activate "com.microsoft.VSCode"
else
    # 备用方案：使用 osascript 并选择更醒目的提示音
    /usr/bin/osascript <<EOF
tell application "System Events"
    display notification "$AUTH_TYPE" with title "⚠️ Claude Code 需要授权" subtitle "项目: $PROJECT_NAME" sound name "Blow"
end tell
EOF
fi

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