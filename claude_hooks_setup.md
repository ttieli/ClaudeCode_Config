# Claude Code Hooks 配置指南

## 前置准备

### 安装 terminal-notifier（推荐）
```bash
# 检查 Homebrew
brew --version

# 安装 terminal-notifier
brew install terminal-notifier

# 验证安装
terminal-notifier -title "测试" -message "安装成功！" -sound Glass
```

### 系统权限设置
1. 打开系统通知设置：
```bash
open x-apple.systempreferences:com.apple.preference.notifications
```
2. 找到 **Visual Studio Code**（VSCode 用户）或 **Terminal**
3. 开启 **允许通知**

## Hook 事件配置

### 1. Stop 事件 - 任务完成通知

**用途：** 在 Claude Code 完成响应后通知你，显示项目名称和完成的工作。

**配置步骤：**
1. 在 Claude Code 中执行 `/hooks`
2. 选择 **Stop** 事件
3. 添加命令：
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh"
```
4. 保存到 **User Settings**

**测试：**
```bash
bash ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh "测试完成通知"
```

**通知内容：**
- 🚀 项目名称
- 🔧 Git 分支和变更数
- 📝 任务描述
- ⏰ 完成时间

---

### 2. HumanInputRequired 事件 - 授权请求提醒

**用途：** 当 Claude Code 需要你的授权或确认时，立即发送醒目的系统通知。

**配置步骤：**
1. 在 Claude Code 中执行 `/hooks`
2. 选择 **HumanInputRequired** 事件
3. 添加命令：
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh" "需要您的授权确认"
```
4. 保存到 **User Settings**

**测试：**
```bash
bash ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh "测试授权提醒"
```

**通知特点：**
- ⚠️ 紧急提示音（Blow/Ping/Basso）
- 🔔 连续 3 个通知（立即、1秒、5秒）
- 📱 忽略勿扰模式
- 🖥️ 终端醒目显示框
- 🚀 自动激活 VSCode 窗口

---

### 3. PreToolUse 事件 - 工具调用监控（可选）

**用途：** 监控 Claude Code 即将执行的操作，特别是敏感命令。

**示例配置：**
```bash
# 记录所有工具调用
echo "[$(date)] 工具调用: $1" >> ~/claude_tools.log

# 或对特定工具发送通知
if [[ "$1" == *"rm"* ]] || [[ "$1" == *"delete"* ]]; then
    terminal-notifier -title "⚠️ 删除操作" -message "$1" -sound Basso
fi
```

---

### 4. ToolOutputError 事件 - 错误提醒（可选）

**用途：** 当工具执行出错时立即通知。

**示例配置：**
```bash
terminal-notifier -title "❌ 工具执行错误" -subtitle "$(basename $PWD)" -message "请检查终端输出" -sound Sosumi
```

## 所有可用脚本

| 脚本文件 | Hook 事件 | 用途 |
|---------|-----------|------|
| `claude_notify_terminal.sh` | Stop | 任务完成通知 |
| `claude_auth_notify.sh` | HumanInputRequired | 授权请求提醒 |

## 日志文件

| 日志文件 | 内容 |
|---------|------|
| `claude_tasks.log` | 所有完成的任务记录 |
| `claude_auth_requests.log` | 所有授权请求记录 |

**查看日志：**
```bash
# 任务日志
tail -f ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_tasks.log

# 授权请求日志
tail -f ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_requests.log
```

## 自定义配置

### 修改通知声音

可用的系统声音：
- **紧急：** Blow, Basso, Sosumi
- **提醒：** Glass, Ping, Pop
- **温和：** Purr, Tink
- **特殊：** Morse, Submarine, Funk

### 修改通知图标

在脚本中使用不同表情：
- ⚠️ 警告/授权
- ✅ 完成
- ❌ 错误
- 🚀 部署
- 🔧 修复
- 📝 文档

## 故障排除

### 没有收到通知？

1. **检查 terminal-notifier：**
```bash
which terminal-notifier
terminal-notifier -title "测试" -message "测试" -sound Glass
```

2. **检查系统权限：**
- VSCode 用户：确保 Visual Studio Code 有通知权限
- Terminal 用户：确保 Terminal 有通知权限

3. **检查 Hook 配置：**
```bash
# 在 Claude Code 中查看当前配置
/hooks
```

4. **检查脚本执行权限：**
```bash
ls -la ~/Library/Mobile\ Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/*.sh
```

### VSCode 特殊说明

VSCode 集成终端的通知需要：
1. 给 Visual Studio Code 应用授予通知权限（不是 Terminal）
2. 使用 terminal-notifier（更可靠）
3. 确保 VSCode 在前台或后台运行

## 完整配置示例

推荐的完整配置（在 `/hooks` 中设置）：

1. **Stop 事件：**
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_notify_terminal.sh"
```

2. **HumanInputRequired 事件：**
```bash
bash "/Users/tieli/Library/Mobile Documents/com~apple~CloudDocs/Project/ClaudeCode_Config/claude_auth_notify.sh"
```

两个都保存到 **User Settings**，这样在所有项目中都会生效。

---

*最后更新：2025-09-16*