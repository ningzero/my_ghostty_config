Ghostty SSH 快捷连接
1. 安装软件

需要：
```
brew install fzf
brew install --cask hammerspoon
```

已有 Ghostty 即可。

2. SSH 配置

使用已有的：
```
~/.ssh/config
```
例如：
```
Host prod-api
    HostName 10.0.0.10
    User root

Host prod-db
    HostName 10.0.0.11
    User root
```

3. 创建 SSH 选择脚本

文件：
```
~/bin/ghostty-ssh
```
内容：
```
#!/bin/zsh

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

host=$(
    grep -E '^Host ' ~/.ssh/config |
    awk '{print $2}' |
    grep -v '[*?]' |
    fzf \
        --height=100% \
        --layout=reverse \
        --border \
        --prompt=' SSH > ' \
        --header='Select SSH Host'
)

[ -z "$host" ] && exit 0

exec ssh "$host"
```
赋予执行权限：
```
chmod +x ~/bin/ghostty-ssh
```
测试：
```
~/bin/ghostty-ssh
```

4. 安装并配置 Hammerspoon

配置文件：
```
~/.hammerspoon/init.lua
```
内容：
```
hs.hotkey.bind({"cmd", "shift"}, "s", function()
    local app = hs.application.frontmostApplication()

    if app and app:name() == "Ghostty" then
        hs.osascript.applescript([[
            tell application "Ghostty"
                set win to front window
                set newTab to new tab in win
                set newTerm to focused terminal of newTab

                delay 0.1
                input text "/Users/ningzihao/bin/ghostty-ssh" & return to newTerm
            end tell
        ]])
    end
end)
```
修改后在 Hammerspoon 菜单栏：
```
Hammerspoon → Reload Config
```
5. macOS 权限

第一次使用 Hammerspoon，需要在：

系统设置
→ 隐私与安全性
→ 辅助功能

允许：

`Hammerspoon ✓`

最终使用方式

在 Ghostty 中：

`⌘⇧S`

然后：
```
fzf
 ↓
选择 ~/.ssh/config 中的 Host
 ↓
Ghostty 自动新建 Tab
 ↓
ssh <Host>
```
最终效果：
```
⌘⇧S
  ↓
┌─────────────────────┐
│ SSH >               │
│ > prod-api          │
│   prod-db           │
│   staging-api       │
└─────────────────────┘
  ↓ Enter
新 Ghostty Tab
  ↓
ssh prod-api
```
涉及的核心文件就 3 个：

- ~/.ssh/config             # SSH 主机列表
- ~/bin/ghostty-ssh         # fzf 选择 + ssh
- ~/.hammerspoon/init.lua   # ⌘⇧S 快捷键 + Ghostty 新 Tab

另外记住一个关键点：hs.task.new() 不适合直接运行 fzf，因为它没有交互式 TTY；这里通过 AppleScript 在 Ghostty 新 Tab 的 terminal 中执行脚本，所以 fzf 才能正常工作。
