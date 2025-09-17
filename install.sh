#!/bin/bash

# Claude Code Notification Configuration Installation Script
# Claude Code 通知配置安装脚本
# This script sets up the notification system for Claude Code on macOS
# 此脚本用于在 macOS 上设置 Claude Code 的通知系统

set -e  # Exit on error | 出错时退出

# Color codes for output | 输出颜色代码
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color | 无颜色

# Get the directory where this script is located | 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Standard installation path (maintains compatibility with existing hooks)
# 标准安装路径（保持与现有 hooks 的兼容性）
STANDARD_PATH="/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Claude Code Notification System Installer         ║${NC}"
echo -e "${BLUE}║     Claude Code 通知系统安装程序                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to check if running on macOS | 检查是否在 macOS 上运行
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo -e "${RED}❌ This script is designed for macOS only.${NC}"
        echo -e "${RED}   此脚本仅适用于 macOS。${NC}"
        exit 1
    fi
}

# Function to check if user is the original author | 检查是否为原作者
check_original_author() {
    if [ "$HOME" = "/Users/tieli" ]; then
        echo -e "${GREEN}✅ Detected original author environment.${NC}"
        echo -e "${GREEN}   检测到原作者环境。${NC}"
        echo -e "${YELLOW}   No additional configuration needed.${NC}"
        echo -e "${YELLOW}   无需额外配置。${NC}"
        return 0
    fi
    return 1
}

# Function to create symbolic link for path compatibility
# 创建符号链接以实现路径兼容
create_symlink() {
    local target_path="$1"
    local parent_dir="$(dirname "$target_path")"
    
    echo -e "${BLUE}🔧 Setting up path compatibility...${NC}"
    echo -e "${BLUE}   设置路径兼容性...${NC}"
    
    # Create parent directories if they don't exist | 如果父目录不存在则创建
    if [ ! -d "$parent_dir" ]; then
        echo -e "${YELLOW}   Creating directory structure...${NC}"
        echo -e "${YELLOW}   创建目录结构...${NC}"
        mkdir -p "$parent_dir"
    fi
    
    # Remove existing symlink if it exists | 如果存在旧的符号链接则删除
    if [ -L "$target_path" ]; then
        echo -e "${YELLOW}   Removing existing symbolic link...${NC}"
        echo -e "${YELLOW}   删除现有符号链接...${NC}"
        rm "$target_path"
    elif [ -d "$target_path" ]; then
        echo -e "${RED}❌ Directory already exists at target path.${NC}"
        echo -e "${RED}   目标路径已存在目录。${NC}"
        echo -e "${YELLOW}   Please remove or rename: $target_path${NC}"
        echo -e "${YELLOW}   请删除或重命名：$target_path${NC}"
        return 1
    fi
    
    # Create new symbolic link | 创建新的符号链接
    ln -s "$SCRIPT_DIR" "$target_path"
    
    if [ -L "$target_path" ]; then
        echo -e "${GREEN}✅ Symbolic link created successfully!${NC}"
        echo -e "${GREEN}   符号链接创建成功！${NC}"
        echo -e "${BLUE}   $target_path -> $SCRIPT_DIR${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to create symbolic link.${NC}"
        echo -e "${RED}   创建符号链接失败。${NC}"
        return 1
    fi
}

# Function to check and install dependencies | 检查并安装依赖
check_dependencies() {
    echo ""
    echo -e "${BLUE}📦 Checking dependencies...${NC}"
    echo -e "${BLUE}   检查依赖项...${NC}"
    
    # Check for Homebrew | 检查 Homebrew
    if ! command -v brew &> /dev/null; then
        echo -e "${YELLOW}⚠️  Homebrew is not installed.${NC}"
        echo -e "${YELLOW}   Homebrew 未安装。${NC}"
        echo -e "${BLUE}   Would you like to install it? (y/n)${NC}"
        echo -e "${BLUE}   是否要安装？(y/n)${NC}"
        read -r response
        if [[ "$response" == "y" || "$response" == "Y" ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
    else
        echo -e "${GREEN}✅ Homebrew is installed.${NC}"
        echo -e "${GREEN}   Homebrew 已安装。${NC}"
    fi
    
    # Check for terminal-notifier | 检查 terminal-notifier
    if ! command -v terminal-notifier &> /dev/null; then
        echo -e "${YELLOW}⚠️  terminal-notifier is not installed.${NC}"
        echo -e "${YELLOW}   terminal-notifier 未安装。${NC}"
        echo -e "${BLUE}   Installing terminal-notifier...${NC}"
        echo -e "${BLUE}   正在安装 terminal-notifier...${NC}"
        brew install terminal-notifier
        echo -e "${GREEN}✅ terminal-notifier installed successfully.${NC}"
        echo -e "${GREEN}   terminal-notifier 安装成功。${NC}"
    else
        echo -e "${GREEN}✅ terminal-notifier is installed.${NC}"
        echo -e "${GREEN}   terminal-notifier 已安装。${NC}"
    fi
}

# Function to setup Bark configuration | 设置 Bark 配置
setup_bark() {
    echo ""
    echo -e "${BLUE}📱 Bark Mobile Push Setup${NC}"
    echo -e "${BLUE}   Bark 手机推送设置${NC}"
    echo ""
    
    # Check if BARK_KEY is already set | 检查是否已设置 BARK_KEY
    if [ -n "$BARK_KEY" ]; then
        echo -e "${GREEN}✅ BARK_KEY is already configured.${NC}"
        echo -e "${GREEN}   BARK_KEY 已配置。${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Would you like to configure Bark for mobile push notifications? (y/n)${NC}"
    echo -e "${YELLOW}是否要配置 Bark 手机推送通知？(y/n)${NC}"
    read -r response
    
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        # Run the Bark setup script if it exists | 如果存在则运行 Bark 设置脚本
        if [ -f "$SCRIPT_DIR/setup_bark.sh" ]; then
            bash "$SCRIPT_DIR/setup_bark.sh"
        else
            echo -e "${YELLOW}⚠️  Bark setup script not found.${NC}"
            echo -e "${YELLOW}   Bark 设置脚本未找到。${NC}"
            echo -e "${BLUE}   Please configure BARK_KEY manually in your shell profile.${NC}"
            echo -e "${BLUE}   请在 shell 配置文件中手动配置 BARK_KEY。${NC}"
        fi
    else
        echo -e "${BLUE}ℹ️  Skipping Bark configuration.${NC}"
        echo -e "${BLUE}   跳过 Bark 配置。${NC}"
        echo -e "${YELLOW}   You can configure it later by running setup_bark.sh${NC}"
        echo -e "${YELLOW}   您可以稍后运行 setup_bark.sh 进行配置${NC}"
    fi
}

# Function to test notifications | 测试通知
test_notifications() {
    echo ""
    echo -e "${BLUE}🧪 Testing notifications...${NC}"
    echo -e "${BLUE}   测试通知...${NC}"
    
    # Test task completion notification | 测试任务完成通知
    echo -e "${YELLOW}   Testing task completion notification...${NC}"
    echo -e "${YELLOW}   测试任务完成通知...${NC}"
    if bash "$STANDARD_PATH/claude_notify_terminal.sh" "Installation test | 安装测试" 2>/dev/null; then
        echo -e "${GREEN}   ✅ Task notification works!${NC}"
        echo -e "${GREEN}      任务通知正常！${NC}"
    else
        echo -e "${RED}   ❌ Task notification test failed.${NC}"
        echo -e "${RED}      任务通知测试失败。${NC}"
    fi
    
    # Test authorization notification | 测试授权通知
    echo -e "${YELLOW}   Testing authorization notification...${NC}"
    echo -e "${YELLOW}   测试授权通知...${NC}"
    if bash "$STANDARD_PATH/claude_auth_notify.sh" "Installation test | 安装测试" 2>/dev/null; then
        echo -e "${GREEN}   ✅ Authorization notification works!${NC}"
        echo -e "${GREEN}      授权通知正常！${NC}"
    else
        echo -e "${RED}   ❌ Authorization notification test failed.${NC}"
        echo -e "${RED}      授权通知测试失败。${NC}"
    fi
}

# Function to display hook commands | 显示 Hook 命令
display_hook_commands() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         Installation Complete! | 安装完成！            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BLUE}📋 Claude Code Hook Commands | Claude Code Hook 命令：${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${GREEN}Stop Event | 停止事件:${NC}"
    echo 'bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh"'
    echo ""
    echo -e "${GREEN}Notification Event | 通知事件:${NC}"
    echo 'bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh"'
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BLUE}ℹ️  To configure hooks in Claude Code:${NC}"
    echo -e "${BLUE}   在 Claude Code 中配置 hooks：${NC}"
    echo -e "${BLUE}   1. Run /hooks in Claude Code session${NC}"
    echo -e "${BLUE}      在 Claude Code 会话中运行 /hooks${NC}"
    echo -e "${BLUE}   2. Copy and paste the commands above${NC}"
    echo -e "${BLUE}      复制并粘贴上述命令${NC}"
    echo -e "${BLUE}   3. Save to User Settings${NC}"
    echo -e "${BLUE}      保存到用户设置${NC}"
    echo ""
}

# Main installation process | 主安装流程
main() {
    # Check macOS | 检查 macOS
    check_macos
    
    # Check if original author | 检查是否为原作者
    if check_original_author; then
        display_hook_commands
        exit 0
    fi
    
    # For other users, create symbolic link | 对其他用户，创建符号链接
    if create_symlink "$STANDARD_PATH"; then
        # Check and install dependencies | 检查并安装依赖
        check_dependencies
        
        # Setup Bark if needed | 如需要则设置 Bark
        setup_bark
        
        # Test notifications | 测试通知
        test_notifications
        
        # Display hook commands | 显示 Hook 命令
        display_hook_commands
    else
        echo -e "${RED}❌ Installation failed. Please check the error messages above.${NC}"
        echo -e "${RED}   安装失败。请查看上述错误信息。${NC}"
        exit 1
    fi
}

# Run main function | 运行主函数
main