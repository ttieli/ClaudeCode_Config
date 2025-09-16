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
    # 第一个通知：使用 alerter 风格的持久通知（如果安装了 alerter）
    if command -v alerter &> /dev/null; then
        # alerter 支持带按钮的持久通知
        alerter \
            -title "⚠️ Claude Code 需要授权" \
            -subtitle "项目: $PROJECT_NAME" \
            -message "$AUTH_TYPE" \
            -sound "Blow" \
            -timeout 0 \
            -actions "查看终端" \
            -closeLabel "稍后" &
    else
        # 标准 terminal-notifier 通知
        terminal-notifier \
            -title "⚠️ Claude Code 需要授权" \
            -subtitle "项目: $PROJECT_NAME" \
            -message "$AUTH_TYPE" \
            -sound "Blow" \
            -group "claude-auth" \
            -ignoreDnD \
            -activate "com.microsoft.VSCode"
    fi
    
    # 第二个通知：确保注意到
    sleep 0.5
    terminal-notifier \
        -title "🔔 请查看终端" \
        -subtitle "项目: $PROJECT_NAME | 时间: $TIMESTAMP" \
        -message "Claude Code 正在等待您的响应" \
        -sound "Ping" \
        -group "claude-auth-reminder"
    
    # 第三个通知：10秒后再次提醒（如果还未处理）
    (sleep 10 && terminal-notifier \
        -title "⏰ 授权请求仍在等待" \
        -subtitle "项目: $PROJECT_NAME" \
        -message "Claude Code 仍在等待您的授权" \
        -sound "Basso" \
        -group "claude-auth-waiting" \
        -ignoreDnD) &
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

# 持续提醒循环（每30秒一次，共3次）
(
    for i in 1 2 3; do
        sleep 30
        if command -v terminal-notifier &> /dev/null; then
            terminal-notifier \
                -title "⏰ 授权请求提醒 ($i/3)" \
                -subtitle "项目: $PROJECT_NAME" \
                -message "Claude Code 仍需要您的授权" \
                -sound "Blow" \
                -group "claude-auth-loop-$i" \
                -ignoreDnD
        fi
    done
) &

# 记录到日志
LOG_DIR=~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config
LOG_FILE="$LOG_DIR/claude_auth_requests.log"
mkdir -p "$LOG_DIR"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 授权请求 - 项目: $PROJECT_NAME - 类型: $AUTH_TYPE" >> "$LOG_FILE"