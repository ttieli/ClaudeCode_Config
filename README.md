# Claude Code Notification Configuration | Claude Code 通知配置

[English](#english) | [中文](#中文)

---

## English

Configure macOS system notifications for Claude Code, supporting both local notifications and mobile push notifications for task completion and tool call alerts.

### ✨ Features

- 📱 **Bark Mobile Push** - Push notifications to iPhone/iPad (requires Bark App)
- 🔔 **Dual Notification Modes** - Choose between local notifications, mobile push, or both
- 🧠 **Smart Project Recognition** - Automatically identifies Git repository name or current project name
- 📊 **Status Display** - Shows Git branch, file changes count, and other information
- 🔐 **Privacy Protection** - Bark key configured via environment variables, never exposed in code
- 🎨 **Terminal Beautification** - Formatted terminal output for better readability
- 🚀 **VSCode Optimized** - Perfect support for VSCode integrated terminal
- 📝 **Optional Logging** - Disabled by default, can be enabled when needed

### 📁 Project Structure

```
ClaudeCode_Config/
├── README.md                      # This document
├── install.sh                     # One-click installation script (New)
├── claude_notify_terminal.sh      # Task completion notification script
├── claude_auth_notify.sh          # Tool call notification script
├── .env.example                   # Environment variable configuration example
├── setup_bark.sh                  # Bark configuration helper script
├── setup_github_token.sh          # GitHub token global configuration script
└── hooks.md                      # Hooks principle documentation
```

### 🚀 Quick Start

#### Automatic Installation (Recommended)

One-click installation for all users:

```bash
# Clone repository
git clone https://github.com/yourusername/ClaudeCode_Config.git
cd ClaudeCode_Config

# Run installation script
./install.sh
```

The installation script will automatically:
- ✅ Create compatible paths
- ✅ Install dependencies
- ✅ Configure Bark (optional)
- ✅ Test notifications
- ✅ Display Hook commands

#### 1. Configure Bark Mobile Push (Optional)

If you want to receive mobile push notifications:

**Install Bark App**
1. Install [Bark](https://apps.apple.com/app/bark-customed-notifications/id1403753865) from App Store on your iPhone/iPad
2. Open the app and copy your key from the push URL
   - Example URL: `https://api.day.app/YOUR_KEY_HERE/content`
   - You need: `YOUR_KEY_HERE`

**Configure Bark Key**

Method 1: Using configuration helper (Recommended)
```bash
# Run configuration script
bash setup_bark.sh
```

Method 2: Manual configuration
```bash
# Edit shell configuration file
echo 'export BARK_KEY="your_bark_key"' >> ~/.zshrc
echo 'export CLAUDE_NOTIFY_METHOD="bark"' >> ~/.zshrc
source ~/.zshrc
```

Method 3: Using .env file
```bash
# Copy example file and edit
cp .env.example .env
# Edit .env file and add your BARK_KEY
```

#### 2. Install terminal-notifier (Local Notifications)

```bash
# Check Homebrew
brew --version

# Install Homebrew if not installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install terminal-notifier
brew install terminal-notifier

# Verify installation
terminal-notifier -title "Test" -message "Installation successful!" -sound Glass
```

#### 3. System Permission Settings (Local Notifications)

```bash
# Open system notification settings
open x-apple.systempreferences:com.apple.preference.notifications
```

- **VSCode Users**: Find **Visual Studio Code**, enable **Allow Notifications**
- **Terminal Users**: Find **Terminal**, enable **Allow Notifications**

#### 4. Configure Claude Code Hooks

Execute `/hooks` in Claude Code session to configure two events:

> 💡 **Tip**: After running `./install.sh`, you can use these standard commands regardless of where you cloned the project.

**Stop Event - Task Completion Notification**
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh"
```

**Notification Event - Tool Call Notification**
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh"
```

Save both configurations to **User Settings** (applies to all projects)

#### 5. Test Notifications

```bash
# Test task completion notification
bash ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh "Test message"

# Test tool call notification
bash ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh "Test notification"
```

#### 6. Choose Notification Method

Control notification method via `CLAUDE_NOTIFY_METHOD` environment variable:

```bash
# Use Bark mobile push only (default)
export CLAUDE_NOTIFY_METHOD="bark"

# Use local terminal-notifier only
export CLAUDE_NOTIFY_METHOD="terminal"  

# Use both notification methods
export CLAUDE_NOTIFY_METHOD="both"
```

### 📄 License

This project is a collection of personal configuration files, free to use and modify.

### 🤝 Contributing

Welcome to suggest improvements or share your configuration optimization solutions.

---

## 中文

为 Claude Code 配置 macOS 系统通知，支持本地通知和手机推送，实现任务完成提醒和工具调用通知。

### ✨ 功能特点

- 📱 **Bark 手机推送** - 支持推送通知到 iPhone/iPad（需 Bark App）
- 🔔 **双重通知模式** - 可选本地通知、手机推送或两者同时使用
- 🧠 **智能项目识别** - 自动识别 Git 仓库名或当前项目名
- 📊 **状态显示** - 显示 Git 分支、文件变更数等信息
- 🔐 **隐私保护** - Bark key 通过环境变量配置，不会泄露到代码
- 🎨 **终端美化** - 格式化的终端输出，清晰易读
- 🚀 **VSCode 优化** - 完美支持 VSCode 集成终端
- 📝 **可选日志** - 默认禁用，需要时可启用

### 📁 项目结构

```
ClaudeCode_Config/
├── README.md                      # 本文档
├── install.sh                     # 一键安装脚本（新增）
├── claude_notify_terminal.sh      # 任务完成通知脚本
├── claude_auth_notify.sh          # 工具调用通知脚本
├── .env.example                   # 环境变量配置示例
├── setup_bark.sh                  # Bark 配置助手脚本
├── setup_github_token.sh          # GitHub token 全局配置脚本
└── hooks.md                      # Hooks 原理说明
```

### 🚀 快速开始

#### 自动安装（推荐 | Recommended）

适用于所有用户的一键安装方式：
One-click installation for all users:

```bash
# 克隆仓库 | Clone repository
git clone https://github.com/yourusername/ClaudeCode_Config.git
cd ClaudeCode_Config

# 运行安装脚本 | Run installation script
./install.sh
```

安装脚本会自动：
The installation script will automatically:
- ✅ 创建兼容路径 | Create compatible paths
- ✅ 安装依赖项 | Install dependencies
- ✅ 配置 Bark（可选）| Configure Bark (optional)
- ✅ 测试通知功能 | Test notifications
- ✅ 显示 Hook 命令 | Display Hook commands

#### 1. 配置 Bark 手机推送（可选）

如果您想接收手机推送通知：

**安装 Bark App**
1. 在 iPhone/iPad 上从 App Store 安装 [Bark](https://apps.apple.com/cn/app/bark-customed-notifications/id1403753865)
2. 打开 App，复制您的推送 URL 中的 key 部分
   - 示例 URL：`https://api.day.app/YOUR_KEY_HERE/推送内容`
   - 您需要的是：`YOUR_KEY_HERE`

**配置 Bark Key**

方法 1：使用配置助手（推荐）
```bash
# 运行配置脚本
bash setup_bark.sh
```

方法 2：手动配置
```bash
# 编辑 shell 配置文件
echo 'export BARK_KEY="your_bark_key"' >> ~/.zshrc
echo 'export CLAUDE_NOTIFY_METHOD="bark"' >> ~/.zshrc
source ~/.zshrc
```

方法 3：使用 .env 文件
```bash
# 复制示例文件并编辑
cp .env.example .env
# 编辑 .env 文件，填入您的 BARK_KEY
```

#### 2. 安装 terminal-notifier（本地通知）

```bash
# 检查 Homebrew
brew --version

# 如果未安装 Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 terminal-notifier
brew install terminal-notifier

# 验证安装
terminal-notifier -title "测试" -message "安装成功！" -sound Glass
```

#### 3. 系统权限设置（本地通知）

```bash
# 打开系统通知设置
open x-apple.systempreferences:com.apple.preference.notifications
```

- **VSCode 用户**：找到 **Visual Studio Code**，开启 **允许通知**
- **Terminal 用户**：找到 **Terminal**，开启 **允许通知**

#### 4. 配置 Claude Code Hooks

在 Claude Code 会话中执行 `/hooks`，配置两个事件：

> 💡 **提示**: 运行 `./install.sh` 后，无论您将项目克隆到何处，都可以使用以下标准命令。
> **Tip**: After running `./install.sh`, you can use these standard commands regardless of where you cloned the project.

**Stop 事件 - 任务完成通知**
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh"
```

**Notification 事件 - 工具调用通知**
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh"
```

两个配置都保存到 **User Settings**（所有项目生效）

#### 5. 测试通知

```bash
# 测试任务完成通知
bash ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh "测试消息"

# 测试工具调用通知
bash ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh "测试通知"
```

#### 6. 选择通知方式

通过环境变量 `CLAUDE_NOTIFY_METHOD` 控制通知方式：

```bash
# 只使用 Bark 手机推送（默认）
export CLAUDE_NOTIFY_METHOD="bark"

# 只使用本地 terminal-notifier
export CLAUDE_NOTIFY_METHOD="terminal"  

# 同时使用两种通知
export CLAUDE_NOTIFY_METHOD="both"
```

### 📄 许可

本项目为个人配置文件集合，可自由使用和修改。

### 🤝 贡献

欢迎提出改进建议或分享你的配置优化方案。

---

## 📜 Version History | 版本历史

### v3.1 (2025-09-17)
- 🚀 Added one-click installation script | 新增一键安装脚本
- 🔗 Path compatibility via symbolic links | 通过符号链接实现路径兼容
- 📝 Improved documentation for GitHub users | 改进文档对 GitHub 用户更友好
- ✅ Maintains backward compatibility | 保持向后兼容性

### v3.0 (2025-09-17)
- 📱 Added Bark mobile push support | 新增 Bark 手机推送支持
- 🔐 Use environment variables to protect Bark key privacy | 使用环境变量保护 Bark key 隐私
- 🔄 Support auto-loading .env configuration file | 支持自动加载 .env 配置文件
- 🎯 Provide three notification modes: bark/terminal/both | 提供三种通知模式
- 📝 Fixed Hook event to Notification | 修正 Hook 事件为 Notification

### v2.2 (2025-09-16)
- 🧠 Added smart project name recognition | 新增智能项目名称识别功能
- 🔧 Optimized Git repository detection logic | 优化 Git 仓库检测逻辑
- 📝 Merged configuration documents | 合并配置文档，精简项目结构

---

*Current Version | 当前版本：3.1 | Last Updated | 最后更新：2025-09-17*