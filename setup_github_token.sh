#!/bin/bash

# GitHub Token Global Configuration Script | GitHub Token 全局配置脚本
# Let all tools that support GITHUB_TOKEN share gh CLI authentication | 让所有支持 GITHUB_TOKEN 的工具都能共享 gh CLI 的认证

echo "======================================"
echo "GitHub Token Global Configuration | GitHub Token 全局配置"
echo "======================================"
echo ""

# Check if gh is authenticated | 检查 gh 是否已认证
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ Please complete gh auth login first | 请先完成 gh auth login"
    echo "Run: gh auth login --web | 运行: gh auth login --web"
    exit 1
fi

# Get current token | 获取当前 token
TOKEN=$(gh auth token)
if [ -z "$TOKEN" ]; then
    echo "❌ Unable to get GitHub token | 无法获取 GitHub token"
    exit 1
fi

# Detect shell configuration file | 检测 shell 配置文件
SHELL_CONFIG=""
if [ -f ~/.zshrc ]; then
    SHELL_CONFIG=~/.zshrc
elif [ -f ~/.bashrc ]; then
    SHELL_CONFIG=~/.bashrc
else
    SHELL_CONFIG=~/.zshrc
    touch $SHELL_CONFIG
fi

# Check if already configured | 检查是否已配置
if grep -q "GITHUB_TOKEN=" "$SHELL_CONFIG" 2>/dev/null; then
    echo "⚠️  Existing GITHUB_TOKEN configuration detected | 检测到已有 GITHUB_TOKEN 配置"
    # Update existing configuration | 更新现有配置
    sed -i '' "/export GITHUB_TOKEN=/d" "$SHELL_CONFIG"
fi

# Add configuration | 添加配置
cat >> "$SHELL_CONFIG" << 'EOF'

# GitHub Token (obtained from gh CLI) | GitHub Token（从 gh CLI 获取）
export GITHUB_TOKEN=$(gh auth token 2>/dev/null)
EOF

echo "✅ GITHUB_TOKEN environment variable configured to $SHELL_CONFIG | 已配置 GITHUB_TOKEN 环境变量到 $SHELL_CONFIG"
echo ""
echo "Please run the following command to apply configuration | 请运行以下命令使配置生效："
echo "  source $SHELL_CONFIG"
echo ""
echo "After configuration, the following tools can use the same authentication | 配置完成后，以下工具都可以使用同一认证："
echo "  • gh CLI commands | gh CLI 命令"
echo "  • VS Code GitHub extensions | VS Code GitHub 扩展"
echo "  • GitHub Copilot"
echo "  • Other tools that support GITHUB_TOKEN | 其他支持 GITHUB_TOKEN 的工具"