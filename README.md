# Claude Code 通知配置

为 Claude Code 配置 macOS 系统通知，实现任务完成提醒和授权请求提示。

## ✨ 功能特点

- 🔔 **双重通知** - 任务完成温和提醒 + 授权请求紧急提示
- 🧠 **智能项目识别** - 自动识别 Git 仓库名或当前项目名
- 📊 **状态显示** - 显示 Git 分支、文件变更数等信息
- 🎨 **终端美化** - 格式化的终端输出，清晰易读
- 🚀 **VSCode 优化** - 完美支持 VSCode 集成终端
- 📝 **可选日志** - 默认禁用，需要时可启用

## 📁 项目结构

```
ClaudeCode_Config/
├── README.md                      # 本文档
├── claude_notify_terminal.sh      # 任务完成通知脚本
├── claude_auth_notify.sh          # 授权请求提醒脚本
└── hooks.md                      # Hooks 原理说明
```

## 🚀 快速开始

### 1. 安装 terminal-notifier

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

### 2. 系统权限设置

```bash
# 打开系统通知设置
open x-apple.systempreferences:com.apple.preference.notifications
```

- **VSCode 用户**：找到 **Visual Studio Code**，开启 **允许通知**
- **Terminal 用户**：找到 **Terminal**，开启 **允许通知**

### 3. 配置 Claude Code Hooks

在 Claude Code 会话中执行 `/hooks`，配置两个事件：

#### Stop 事件 - 任务完成通知

```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh"
```

- **触发时机**：Claude Code 完成响应后
- **提示音**：Glass（温和）
- **通知内容**：项目名称、Git 状态、完成时间

#### HumanInputRequired 事件 - 授权请求提醒

```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh"
```

- **触发时机**：Claude Code 需要用户授权时
- **提示音**：Blow（紧急）
- **特性**：2个相同通知（间隔2秒）、忽略勿扰模式、自动激活 VSCode

两个配置都保存到 **User Settings**（所有项目生效）

### 4. 测试通知

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

## 🛠️ Hook 事件详解

### 核心事件（已配置）

| Hook 事件 | 脚本文件 | 用途 | 提示音 |
|-----------|---------|------|--------|
| Stop | `claude_notify_terminal.sh` | 任务完成通知 | Glass（温和） |
| HumanInputRequired | `claude_auth_notify.sh` | 授权请求提醒 | Blow（紧急） |

### 可选事件（扩展用）

#### PreToolUse 事件 - 工具调用监控

监控 Claude Code 即将执行的操作，特别是敏感命令：

```bash
# 记录所有工具调用
echo "[$(date)] 工具调用: $1" >> ~/claude_tools.log

# 或对特定工具发送通知
if [[ "$1" == *"rm"* ]] || [[ "$1" == *"delete"* ]]; then
    terminal-notifier -title "⚠️ 删除操作" -message "$1" -sound Basso
fi
```

#### ToolOutputError 事件 - 错误提醒

当工具执行出错时立即通知：

```bash
terminal-notifier -title "❌ 工具执行错误" -subtitle "$(basename $PWD)" -message "请检查终端输出" -sound Sosumi
```

## 🧠 智能项目名称识别

脚本会按以下优先级智能获取项目名称：

1. **Git 仓库名** - 如果在 Git 项目中，使用仓库根目录名
2. **子目录名** - 如果在 "Project" 父目录，显示最近修改的子目录
3. **当前目录名** - 作为兜底方案

这解决了在父目录启动 Claude Code 时项目名显示不准确的问题。

## 📝 自定义配置

### 修改通知声音

编辑脚本中的 `sound name` 参数：

- **紧急**：Blow, Basso, Sosumi, Hero
- **提醒**：Glass, Ping, Pop
- **温和**：Purr, Tink
- **特殊**：Morse, Submarine, Funk, Frog

### 修改通知图标

在脚本中使用不同表情符号：

- ✅ 任务完成
- ⚠️ 需要授权
- ❌ 执行错误
- 🚀 部署任务
- 🔧 修复任务
- 📝 文档任务

## 📊 日志管理（可选）

日志功能默认已禁用。如需启用，请编辑脚本文件，找到以下注释并取消：

```bash
# 日志功能（默认禁用，如需启用请取消注释）
```

启用后，日志将保存在：
- 任务日志：`~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_tasks.log`
- 授权日志：`~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_requests.log`

## 🔧 故障排除

### 没有收到通知？

1. **测试 terminal-notifier：**
```bash
which terminal-notifier
terminal-notifier -title "测试" -message "通知测试" -sound Glass
```

2. **检查系统权限：**
   - VSCode 用户：确保 **Visual Studio Code** 有通知权限
   - Terminal 用户：确保 **Terminal** 有通知权限

3. **检查勿扰模式：**
   - 确保 Mac 未开启勿扰/专注模式
   - 授权提醒会忽略勿扰模式，但任务完成通知不会

4. **检查脚本权限：**
```bash
ls -la ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/*.sh
```

5. **检查 Hook 配置：**
```bash
# 在 Claude Code 中查看当前配置
/hooks
```

### VSCode 特殊说明

VSCode 集成终端的通知需要：
1. 给 **Visual Studio Code** 应用授予通知权限（不是 Terminal）
2. 使用 terminal-notifier 而非 osascript 更可靠
3. 授权提醒会自动激活 VSCode 窗口

### 重装 terminal-notifier

```bash
brew uninstall terminal-notifier
brew install terminal-notifier
which terminal-notifier  # 应显示：/usr/local/bin/terminal-notifier
```

## 🎯 最佳实践

1. **两个 Hook 都要配置** - 任务完成和授权提醒相辅相成
2. **保存到用户设置** - 确保所有项目都能使用
3. **测试后再使用** - 先用测试命令验证配置正确
4. **自定义提示音** - 根据个人喜好调整声音类型
5. **日志按需启用** - 避免不必要的磁盘写入

## 📄 许可

本项目为个人配置文件集合，可自由使用和修改。

## 🤝 贡献

欢迎提出改进建议或分享你的配置优化方案。

## 📜 更新历史

### v2.2 (2025-09-16)
- 🧠 新增智能项目名称识别功能
- 🔧 优化 Git 仓库检测逻辑
- 📝 合并配置文档，精简项目结构

### v2.1 (2025-09-16)  
- 🔔 简化授权通知为 2 个相同通知
- 📊 默认禁用日志功能
- 🗑️ 移除冗余脚本文件

### v2.0 (2025-09-16)
- ⚠️ 新增授权请求提醒功能
- 🎨 优化终端输出美化
- 📝 完善文档说明

---

*当前版本：2.2 | 最后更新：2025-09-16*