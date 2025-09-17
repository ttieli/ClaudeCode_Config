#!/bin/bash

# GitHub Token 全局配置脚本
# 让所有支持 GITHUB_TOKEN 的工具都能共享 gh CLI 的认证

echo "======================================"
echo "GitHub Token 全局配置"
echo "======================================"
echo ""

# 检查 gh 是否已认证
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ 请先完成 gh auth login"
    echo "运行: gh auth login --web"
    exit 1
fi

# 获取当前 token
TOKEN=$(gh auth token)
if [ -z "$TOKEN" ]; then
    echo "❌ 无法获取 GitHub token"
    exit 1
fi

# 检测 shell 配置文件
SHELL_CONFIG=""
if [ -f ~/.zshrc ]; then
    SHELL_CONFIG=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_CONFIG=~/.bashrc
else
    SHELL_CONFIG=~/.zshrc
    touch $SHELL_CONFIG
fi

# 检查是否已配置
if grep -q "GITHUB_TOKEN=" "$SHELL_CONFIG" 2>/dev/null; then
    echo "⚠️  检测到已有 GITHUB_TOKEN 配置"
    # 更新现有配置
    sed -i '' "/export GITHUB_TOKEN=/d" "$SHELL_CONFIG"
fi

# 添加配置
cat >> "$SHELL_CONFIG" << 'EOF'

# GitHub Token (从 gh CLI 获取)
export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
EOF

echo "✅ 已配置 GITHUB_TOKEN 环境变量到 $SHELL_CONFIG"
echo ""
echo "请运行以下命令使配置生效："
echo "  source $SHELL_CONFIG"
echo ""
echo "配置完成后，以下工具都可以使用同一认证："
echo "  • gh CLI 命令"
echo "  • VS Code GitHub 扩展"
echo "  • GitHub Copilot"
echo "  • 其他支持 GITHUB_TOKEN 的工具"