# 快速确定系统终端生效的配置文件

要确定 macOS 系统当前生效的是 `~/.bashrc` 还是 `~/.zshrc`，请按以下步骤操作：

---

### 1. **确认当前使用的 Shell**
```bash
echo $0
```
- 如果输出是 `-zsh` → **当前使用 Zsh**，生效的是 `~/.zshrc`
- 如果输出是 `-bash` → **当前使用 Bash**，生效的是 `~/.bashrc`

### 2. **查看系统默认 Shell**
```bash
dscl . -read ~/ UserShell
```
- 输出如：`UserShell: /bin/zsh` → 系统默认使用 **Zsh**
- 输出如：`UserShell: /bin/bash` → 系统默认使用 **Bash**

> 💡 **macOS Catalina(10.15) 及以上版本默认使用 Zsh**

### 3. **验证配置文件加载**
```bash
# 在 .bashrc 中添加测试命令
echo 'echo "BASH CONFIG LOADED"' >> ~/.bashrc

# 在 .zshrc 中添加测试命令
echo 'echo "ZSH CONFIG LOADED"' >> ~/.zshrc
```
**关闭并重新打开终端**：
- 如果显示 `BASH CONFIG LOADED` → 使用 Bash
- 如果显示 `ZSH CONFIG LOADED` → 使用 Zsh

### 4. **检查配置文件是否存在**
```bash
ls -la ~/ | grep -E '\.(bashrc|zshrc)'
```
- 如果只有 `.zshrc` → 系统使用 Zsh
- 如果只有 `.bashrc` → 系统使用 Bash
- 如果两个文件都存在 → 根据步骤1确认

---

### 最终确认表格
| 测试命令 | 输出结果 | 生效文件 |
|----------|---------|-----------|
| `echo $0` | `-zsh` | `~/.zshrc` |
| `echo $0` | `-bash` | `~/.bashrc` |
| `dscl . -read ~/ UserShell` | `/bin/zsh` | `~/.zshrc` |
| 启动终端后 | 显示`ZSH CONFIG LOADED` | `~/.zshrc` |
| 启动终端后 | 显示`BASH CONFIG LOADED` | `~/.bashrc` |

---

### ⚠️ 常见问题解析
1. **我两个文件都存在，但都不生效？**
   - Bash 默认只加载 `~/.bash_profile`，需要在其中添加：
     ```bash
     if [ -f ~/.bashrc ]; then source ~/.bashrc; fi
     ```

2. **为什么改了配置文件不生效？**
   ```bash
   # 手动强制重载
   source ~/.zshrc    # 如果使用 Zsh
   source ~/.bashrc   # 如果使用 Bash
   ```

3. **如何永久切换？**
   ```bash
   # 切换到 Bash
   chsh -s /bin/bash

   # 切换到 Zsh
   chsh -s /bin/zsh
   ```
   > 重启终端后生效

4. **查看所有可用 Shell**
   ```bash
   cat /etc/shells
   ```
   ```
   /bin/bash
   /bin/csh
   /bin/ksh
   /bin/sh
   /bin/tcsh
   /bin/zsh  # 这是默认选项
   ```

---

只需通过 `echo $0` 命令即可最快速地确定当前生效的配置文件是哪个 🚀
