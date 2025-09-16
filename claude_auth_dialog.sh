#!/bin/bash

# Claude Code 授权请求持久对话框脚本
# 使用 AppleScript 创建一个必须响应的对话框

# 获取当前项目和时间信息
PROJECT_NAME=$(basename "$PWD")
TIMESTAMP=$(date "+%H:%M:%S")
AUTH_TYPE="${1:-需要您的授权}"

# 创建持久对话框（会置顶并等待用户响应）
/usr/bin/osascript <<EOF
tell application "System Events"
    set frontApp to name of first application process whose frontmost is true
    
    -- 播放提示音
    do shell script "afplay /System/Library/Sounds/Glass.aiff &"
    
    -- 创建对话框
    display dialog "Claude Code 需要您的授权确认

📁 项目: $PROJECT_NAME
🔐 操作: $AUTH_TYPE  
⏰ 时间: $TIMESTAMP

请返回终端查看并响应授权请求" ¬
        with title "⚠️ Claude Code 授权请求" ¬
        buttons {"稍后提醒", "立即查看"} ¬
        default button "立即查看" ¬
        with icon caution ¬
        giving up after 300
    
    set userChoice to button returned of result
    
    if userChoice is "立即查看" then
        -- 激活 VSCode
        tell application "Visual Studio Code" to activate
    else if userChoice is "稍后提醒" then
        -- 30秒后再次提醒
        delay 30
        display notification "Claude Code 仍在等待您的授权" with title "⏰ 授权提醒" subtitle "项目: $PROJECT_NAME" sound name "Blow"
    end if
end tell
EOF

# 同时也发送常规通知作为备份
if command -v terminal-notifier &> /dev/null; then
    terminal-notifier \
        -title "⚠️ 授权请求已发送" \
        -subtitle "项目: $PROJECT_NAME" \
        -message "请查看弹出的对话框" \
        -sound "Glass" \
        -group "claude-auth-backup"
fi