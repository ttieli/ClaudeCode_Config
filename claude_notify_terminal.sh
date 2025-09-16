#!/bin/bash

# 使用 terminal-notifier 的通知脚本（最可靠）

# 获取项目信息
PROJECT_NAME=$(basename "$PWD")
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

# 使用 terminal-notifier 发送通知
if command -v terminal-notifier &> /dev/null; then
    terminal-notifier \
        -title "🚀 $PROJECT_NAME" \
        -subtitle "$GIT_INFO" \
        -message "$WORK_DONE" \
        -sound Glass \
        -group "claude-code" \
        -activate "com.microsoft.VSCode"
    
    echo "✅ 通知已通过 terminal-notifier 发送"
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
fi

# 记录到日志
LOG_DIR=~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config
LOG_FILE="$LOG_DIR/claude_tasks.log"
mkdir -p "$LOG_DIR"

echo "[$FULL_TIME]" >> "$LOG_FILE"
echo "  项目: $PROJECT_NAME" >> "$LOG_FILE"
echo "  路径: $PROJECT_PATH" >> "$LOG_FILE"
echo "  状态: $GIT_INFO" >> "$LOG_FILE"
echo "  任务: $WORK_DONE" >> "$LOG_FILE"
echo "---" >> "$LOG_FILE"

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