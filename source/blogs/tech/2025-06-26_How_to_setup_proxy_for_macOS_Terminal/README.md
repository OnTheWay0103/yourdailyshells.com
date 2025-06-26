# macOS 终端（Terminal）中设置网络代理的方法

在 macOS 终端（Terminal）中设置网络代理是解决国内访问 GitHub 等资源缓慢或失败问题的常见需求。以下是基于不同场景的配置方法，涵盖临时设置、永久配置、工具集成及专用软件代理设置：

---

### 🔧 **一、基础环境变量配置**
#### **1. 临时设置（关闭终端后失效）**
- **HTTP/HTTPS 代理**：  
  ```bash
  export http_proxy="http://127.0.0.1:7890"  # 替换为你的代理端口（如 1087、8889）
  export https_proxy="http://127.0.0.1:7890"
  export no_proxy="localhost,127.0.0.1,::1"   # 排除本地地址
  ```
- **SOCKS5 代理**：  
  ```bash
  export ALL_PROXY="socks5://127.0.0.1:1089"  # 替换为 SOCKS 端口
  ```
- **验证生效**：  
  ```bash
  curl -I http://www.google.com  # 返回 HTTP 头则成功
  curl cip.cc                    # 查看当前 IP 归属地[citation:2][citation:4]
  ```

#### **2. 永久配置（写入 Shell 配置文件）**
- **Bash 用户**（macOS Mojave 及更早版本）：  
  编辑 `~/.bash_profile`，添加：  
  ```bash
  alias proxy_on='export http_proxy=http://127.0.0.1:7890 https_proxy=$http_proxy'
  alias proxy_off='unset http_proxy https_proxy'
  ```
  生效命令：`source ~/.bash_profile`  
- **Zsh 用户**（macOS Catalina 及更新版本）：  
  编辑 `~/.zshrc`，添加：  
  ```bash
  alias proxy_on='export all_proxy=socks5://127.0.0.1:1089'  # SOCKS 示例
  alias proxy_off='unset all_proxy'
  ```
  生效命令：`source ~/.zshrc`  
  → 日常使用：`proxy_on` 开启代理，`proxy_off` 关闭[citation:1][citation:2][citation:3]。

---

### 🔄 **二、专用工具代理设置**
#### **1. Git 代理配置**
- **设置代理**：  
  ```bash
  git config --global http.proxy http://127.0.0.1:7890
  git config --global https.proxy http://127.0.0.1:7890
  ```
- **取消代理**：  
  ```bash
  git config --global --unset http.proxy
  git config --global --unset https.proxy
  ```
- **注意**：需单独配置，终端代理不会自动作用于 Git[citation:3][citation:5]。

#### **2. NPM 代理配置**
- **设置代理**：  
  ```bash
  npm config set proxy http://127.0.0.1:7890
  npm config set https-proxy http://127.0.0.1:7890
  ```
- **取消代理**：  
  ```bash
  npm config delete proxy
  npm config delete https-proxy
  ```
  ⚠️ 若需禁用 SSL 验证（不推荐）：`npm config set strict-ssl false`[citation:3]。

---

### ⚙️ **三、自动化脚本工具**
使用开源脚本 `proxy_tool.sh` 简化操作,这个脚本很简单，也可以AI生成一个：    
1. **功能**：  
   - 一键设置/取消终端代理  
   - 同步配置 Git 代理  
   - 检测当前 IP 及代理状态  
2. **使用流程**：  
   ```bash
   chmod +x proxy_tool.sh  # 添加执行权限
   ./proxy_tool.sh         # 运行菜单
   ```
   → 选择选项：设置代理（支持 HTTP/SOCKS）、检查状态等[citation:5]。

---

### 📌 **四、注意事项**
1. **端口一致性**：  
   - 代理端口需与本地客户端（如 Clash、Surge）的 **HTTP/SOCKS 端口一致**，常见端口：`7890`（HTTP）、`1080`/`1089`（SOCKS）[citation:1][citation:2][citation:4]。
2. **系统代理与终端的区别**：  
   - 系统设置（“网络偏好设置 → 代理”）仅影响 GUI 应用（如浏览器），**终端需单独配置**[citation:4][citation:6][citation:7]。
3. **复杂环境处理**：  
   - 若代理需认证，格式为：`http://用户名:密码@IP:端口`[citation:4]。
   - 长连接场景（如下载大文件）建议用 `nohup` 避免中断。

---

### 💎 **配置建议总结**
| **场景**                     | **推荐方法**                     | **优势**                              |
|-----------------------------|----------------------------------|---------------------------------------|
| 临时使用代理                | 直接 `export` 环境变量           | 快速、无需重启终端                   |
| 长期频繁切换代理            | 写入 `~/.bash_profile` 或 `~/.zshrc` | 命令别名一键开关                     |
| 统一管理终端 + Git 代理      | 使用 `proxy_tool.sh` 脚本        | 自动化检测、支持同步配置             |
| 仅需 Git 代理               | `git config` 单独设置            | 不影响其他终端命令                   |

> 首次配置后务必验证 IP 是否切换（`curl cip.cc`）。若失效，检查代理客户端是否运行、端口是否匹配，或尝试替换 `http://` 为 `socks5://`（SOCKS 代理更稳定）[citation:2][citation:5]。  
> 