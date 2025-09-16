# Claude Code 通知配置

为 Claude Code 配置 macOS 系统通知，实现任务完成提醒和授权请求提示。

## ✨ 功能特点

- 🔔 **双重通知** - 任务完成温和提醒 + 授权请求紧急提示
- 📊 **智能识别** - 自动显示项目名称、Git 分支、文件变更数
- 📝 **完整日志** - 分别记录任务完成和授权请求历史
- 🎨 **终端美化** - 格式化的终端输出，清晰易读
- 🚀 **VSCode 优化** - 完美支持 VSCode 集成终端

## 📁 项目结构

```
ClaudeCode_Config/
├── README.md                      # 本文档
├── claude_hooks_setup.md          # 详细配置指南
├── claude_notify_terminal.sh      # 任务完成通知脚本
├── claude_auth_notify.sh          # 授权请求提醒脚本
└── hooks.md                      # Hooks 原理说明
```

## 🚀 快速开始

### 1. 安装 terminal-notifier

```bash
# 安装 Homebrew（如果未安装）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 安装 terminal-notifier
brew install terminal-notifier
```

### 2. 配置 Claude Code Hooks

在 Claude Code 会话中执行 `/hooks`，配置两个事件：

#### 任务完成通知（Stop 事件）
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh"
```
- 触发时机：Claude Code 完成响应后
- 提示音：Glass（温和）
- 通知内容：项目名称、Git 状态、完成时间

#### 授权请求提醒（HumanInputRequired 事件）
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh"
```
- 触发时机：Claude Code 需要用户授权时
- 提示音：Blow + Ping（紧急）
- 特性：连续两次通知、忽略勿扰模式、自动激活 VSCode

两个配置都保存到 **User Settings**（所有项目生效）

### 3. 测试通知

```bash
# 测试任务完成通知
bash ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh "测试消息"

# 测试授权请求提醒
bash ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh "测试授权"
```

## 📖 使用效果

### 任务完成通知示例
```
╔════════════════════════════════════════════════════════╗
║              ✅ Claude Code 任务完成                     ║
╠════════════════════════════════════════════════════════╣
║  📁 项目: MyProject
║  🔧 分支: main | 变更: 3
║  📝 实现了用户认证功能
║  ⏰ 时间: 14:30
╚════════════════════════════════════════════════════════╝
```

### 授权请求提醒示例
```
╔════════════════════════════════════════════════════════╗
║                                                          ║
║         ⚠️  Claude Code 需要您的授权  ⚠️                ║
║                                                          ║
╠════════════════════════════════════════════════════════╣
║  📁 项目: MyProject
║  🔐 类型: 需要确认操作
║  ⏰ 时间: 14:35:20
║                                                          ║
║  👉 请在终端中查看并响应授权请求                          ║
╚════════════════════════════════════════════════════════╝
```

## 🛠️ 脚本说明

| 脚本文件 | Hook 事件 | 用途 | 提示音 |
|---------|-----------|------|--------|
| `claude_notify_terminal.sh` | Stop | 任务完成通知 | Glass（温和） |
| `claude_auth_notify.sh` | HumanInputRequired | 授权请求提醒 | Blow/Ping（紧急） |

## 📊 日志管理（可选）

日志功能默认已禁用。如需启用，请编辑脚本文件，取消注释日志相关代码。

### 启用日志

编辑脚本文件，找到以下注释部分并取消注释：
```bash
# 日志功能（默认禁用，如需启用请取消注释）
```

### 日志文件位置

启用后，日志将保存在：
- 任务日志：`~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_tasks.log`
- 授权日志：`~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_requests.log`

## 🔧 故障排除

### 没有收到通知？

1. **测试 terminal-notifier：**
```bash
terminal-notifier -title "测试" -message "通知测试" -sound Glass
```

2. **检查系统权限：**
```bash
open x-apple.systempreferences:com.apple.preference.notifications
```
- VSCode 用户：确保 **Visual Studio Code** 有通知权限
- Terminal 用户：确保 **Terminal** 有通知权限

3. **检查勿扰模式：**
- 确保 Mac 未开启勿扰/专注模式
- 授权提醒会忽略勿扰模式，但任务完成通知不会

### VSCode 用户注意

1. 必须给 **Visual Studio Code** 应用（不是 Terminal）授予通知权限
2. 使用 terminal-notifier 而非 osascript 更可靠
3. 授权提醒会自动激活 VSCode 窗口

### 重装 terminal-notifier

```bash
brew uninstall terminal-notifier
brew install terminal-notifier
which terminal-notifier  # 应显示：/usr/local/bin/terminal-notifier
```

## 📝 自定义配置

### 修改通知声音

编辑脚本中的 `sound name` 参数：

**温和提示音：**
- Glass, Tink, Purr, Pop

**紧急提示音：**
- Blow, Basso, Sosumi, Hero

**特殊效果音：**
- Morse, Submarine, Funk, Frog

### 修改通知图标

在脚本中使用不同表情符号：
- ✅ 任务完成
- ⚠️ 需要授权
- ❌ 执行错误
- 🚀 部署任务
- 🔧 修复任务
- 📝 文档任务

## 🎯 最佳实践

1. **两个 Hook 都要配置** - 任务完成和授权提醒相辅相成
2. **保存到用户设置** - 确保所有项目都能使用
3. **定期清理日志** - 避免日志文件过大
4. **自定义提示音** - 根据个人喜好调整声音类型

## 📄 许可

本项目为个人配置文件集合，可自由使用和修改。

## 🤝 贡献

欢迎提出改进建议或分享你的配置优化方案。

---

*版本：2.0 | 最后更新：2025-09-16*
*新增授权提醒功能，优化项目结构*