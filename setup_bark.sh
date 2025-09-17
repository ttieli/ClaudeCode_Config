#!/bin/bash

# Claude Code Bark 通知配置助手
# 此脚本帮助您快速配置 Bark 通知

echo "======================================"
echo "Claude Code Bark 通知配置助手"
echo "======================================"
echo ""

# 检查 shell 配置文件
SHELL_CONFIG=""
if [ -f ~/.zshrc ]; then
    SHELL_CONFIG=~/.zshrc
    echo "检测到 zsh 配置文件"
elif [ -f ~/.bashrc ]; then
    SHELL_CONFIG=~/.bashrc
    echo "检测到 bash 配置文件"
else
    echo "未找到 shell 配置文件，将创建 ~/.zshrc"
    SHELL_CONFIG=~/.zshrc
    touch $SHELL_CONFIG
fi

# 检查是否已配置
if grep -q "BARK_KEY" "$SHELL_CONFIG" 2>/dev/null; then
    echo "⚠️  检测到已有 BARK_KEY 配置"
    read -p "是否要更新配置？(y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "配置未更改"
        exit 0
    fi
fi

# 获取用户输入
echo ""
echo "请输入您的 Bark Key（从 Bark App 获取）："
read -r BARK_KEY_INPUT

if [ -z "$BARK_KEY_INPUT" ]; then
    echo "❌ Bark Key 不能为空"
    exit 1
fi

# 询问通知方式
echo ""
echo "请选择默认通知方式："
echo "1) bark - 只使用 Bark 手机通知（推荐）"
echo "2) terminal - 只使用本地 terminal-notifier"
echo "3) both - 同时使用两种通知方式"
read -p "请输入选择 (1-3): " -n 1 -r
echo

case $REPLY in
    1) NOTIFY_METHOD="bark" ;;
    2) NOTIFY_METHOD="terminal" ;;
    3) NOTIFY_METHOD="both" ;;
    *) NOTIFY_METHOD="bark" ;;
esac

# 备份配置文件
if [ -f "$SHELL_CONFIG" ]; then
    cp "$SHELL_CONFIG" "${SHELL_CONFIG}.backup.$(date +%Y%m%d%H%M%S)"
    echo "✅ 已备份原配置文件"
fi

# 移除旧配置（如果存在）
sed -i '' '/# Claude Code Bark 通知配置/,/export CLAUDE_NOTIFY_METHOD/d' "$SHELL_CONFIG" 2>/dev/null

# 添加新配置
cat >> "$SHELL_CONFIG" << EOF

# Claude Code Bark 通知配置
export BARK_KEY="$BARK_KEY_INPUT"
export BARK_SERVER="https://api.day.app"
export CLAUDE_NOTIFY_METHOD="$NOTIFY_METHOD"
EOF

echo ""
echo "✅ 配置已成功添加到 $SHELL_CONFIG"
echo ""
echo "请运行以下命令使配置生效："
echo "  source $SHELL_CONFIG"
echo ""
echo "或重新打开终端窗口"
echo ""
echo "测试通知命令："
echo "  bash claude_notify_terminal.sh \"测试通知\""
echo ""