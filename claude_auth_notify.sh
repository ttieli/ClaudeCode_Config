#!/bin/bash

# Claude Code 授权请求通知脚本
# 用于在 Claude Code 请求授权时发送系统通知

# 获取当前项目和时间信息
PROJECT_NAME=$(basename "$PWD")
TIMESTAMP=$(date "+%H:%M:%S")

# 解析输入参数（如果有）
AUTH_TYPE="${1:-需要您的授权}"

# 使用 terminal-notifier 发送紧急通知
if command -v terminal-notifier &> /dev/null; then
    # 第一个通知：主要授权通知（使用提醒样式）
    terminal-notifier \
        -title "⚠️ Claude Code 需要授权" \
        -subtitle "项目: $PROJECT_NAME" \
        -message "$AUTH_TYPE - 请立即查看终端" \
        -sound "Blow" \
        -group "claude-auth" \
        -ignoreDnD \
        -activate "com.microsoft.VSCode" \
        -sender "com.apple.Terminal"
    
    # 第二个通知：1秒后确保注意到
    sleep 1
    terminal-notifier \
        -title "🔔 授权请求等待中" \
        -subtitle "项目: $PROJECT_NAME | 时间: $TIMESTAMP" \
        -message "Claude Code 正在等待您的响应" \
        -sound "Ping" \
        -group "claude-auth-reminder" \
        -ignoreDnD
    
    # 第三个通知：5秒后最后提醒
    (sleep 5 && terminal-notifier \
        -title "⏰ 请立即响应" \
        -subtitle "项目: $PROJECT_NAME" \
        -message "Claude Code 授权请求仍在等待" \
        -sound "Basso" \
        -group "claude-auth-final" \
        -ignoreDnD \
        -activate "com.microsoft.VSCode") &
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


# 记录到日志
LOG_DIR=~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config
LOG_FILE="$LOG_DIR/claude_auth_requests.log"
mkdir -p "$LOG_DIR"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 授权请求 - 项目: $PROJECT_NAME - 类型: $AUTH_TYPE" >> "$LOG_FILE"