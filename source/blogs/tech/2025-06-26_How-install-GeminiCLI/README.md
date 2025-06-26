# Gemini CLI 安装方法

以下是 Gemini CLI 的详细安装方法，结合官方文档和社区实践整理为清晰的步骤：

---

### ⚙️ **安装前提**
1. **Node.js 环境**  
   - 必须安装 **Node.js v18 或更高版本**（[官网下载](https://nodejs.org/en/download)）[citation:1][citation:6]。  
   - 验证安装：  
     ```bash
     node -v  # 应输出 v18.x.x 或更高
     npm -v   # 验证 npm 是否正常
     ```
   - 未安装时：  
     - **macOS/Linux**：用 Homebrew `brew install node`[citation:6]。  
     - **Windows**：直接下载安装包并重启终端[citation:6]。

---

### 📥 **安装方法**
#### **方法一：npx 快速体验（推荐首次使用）**
```bash
npx https://github.com/google-gemini/gemini-cli
```
- **特点**：无需全局安装，自动下载依赖，适合测试[citation:1][citation:6][citation:7]。  
- **流程**：  
  1. 运行命令后按提示输入 `y` 确认。  
  2. 等待依赖安装完成（约10-30秒）。  

#### **方法二：全局安装（推荐长期使用）**
```bash
npm install -g @google/gemini-cli
```
- **权限问题处理**：  
  - macOS/Linux：`sudo npm install -g @google/gemini-cli`  
  - Windows：以管理员身份运行终端[citation:6]。  
- **验证安装**：  
  ```bash
  gemini --version  # 输出版本号即成功
  ```

---

### ⚡️ **首次配置**
1. **启动 CLI**：  
   ```bash
   gemini          # 全局安装后
   # 或
   npx https://github.com/google-gemini/gemini-cli  # npx 方式
   ```
2. **选择主题颜色**：  
   - 通过键盘方向键选择配色方案，按 Enter 确认[citation:1][citation:6]。  
3. **身份认证**：  
   - **推荐方式**：选择 **Google 账号登录**（个人账号免费额度：1000次/天）[citation:1][citation:6]。  
     - 终端自动弹出浏览器或显示链接，登录 Google 账号并授权。  
     - 复制授权码粘贴回终端完成认证[citation:6]。  
   - **替代方式**：使用 API Key（需在 [Google AI Studio](https://aistudio.google.com/) 生成）[citation:6]：  
     ```bash
     # 临时设置（当前会话有效）
     export GEMINI_API_KEY="your_key"  # macOS/Linux
     $env:GEMINI_API_KEY="your_key"    # Windows PowerShell
     ```
     - **永久设置**：将 `export GEMINI_API_KEY="your_key"` 添加到 `~/.bashrc` 或 `~/.zshrc`（macOS/Linux），或通过系统环境变量配置（Windows）[citation:6]。

---

### ⚠️ **常见问题解决**
| 问题现象                  | 解决方案                                                                 |
|---------------------------|------------------------------------------------------------------------|
| **`command not found`**   | 检查 Node.js 安装和 PATH 配置；重装 Node.js 或重启终端[citation:6]。     |
| **登录失败**              | 若提示 `Ensure your Google account is not a Workspace account`：<br> 设置环境变量 `GOOGLE_CLOUD_PROJECT="项目编号"`（从 [Google Cloud 控制台](https://console.cloud.google.com/) 获取）[citation:8]。 |
| **网络超时**              | 检查代理或防火墙，配置 npm 代理：<br> `npm config set proxy http://proxy.example.com:8080`[citation:6]。 |
| **权限不足（EACCES）**    | 用 `sudo` 重试或修正 npm 全局目录权限[citation:6]。                     |

---

### 💡 **进阶使用**
- **文件交互**：上传 PDF 或 URL 分析内容：  
  ```bash
  gemini "分析此 PDF：/path/to/file.pdf"  # 需文件路径
  ```
- **自动化任务**：  
  ```bash
  gemini "将此目录下所有图片转为 PNG 格式"
  ```
- **VS Code 集成**：与 Gemini Code Assist 共享底层能力，支持多步推理[citation:5][citation:7]。

---

> 安装完成后，通过 `gemini "你的问题"` 直接提问，或输入 `gemini` 进入交互式对话模式[citation:1][citation:6]。更多命令参考 `gemini --help`。  
> 如遇安装失败，建议优先尝试 **npx 方式**或检查网络权限[citation:6][citation:7]。