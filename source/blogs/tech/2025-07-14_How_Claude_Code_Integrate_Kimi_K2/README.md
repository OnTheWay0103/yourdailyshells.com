# Claude Code 接入 Kimi K2 的完整方案

## 综合实践验证与避坑指南，提供三种主流方法供不同系统环境选择：
---

### 🔑 一、核心原理
通过环境变量重定向 Claude Code 的 API 请求至 Kimi K2 的兼容端点，实现模型替换：
- **技术基础**：Kimi K2 提供与 Anthropic 完全兼容的 API 端点 `https://api.moonshot.cn/anthropic`
- **成本优势**：Kimi K2 价格仅为 Claude 的 1/10（百万 Token 约 16 元）

---

### ⚙️ 二、准备工作
1. **申请 Kimi API Key**
   - 访问 https://platform.moonshot.cn/console/api-keys 注册账号
   - 在 API Key 管理页面创建密钥（新用户赠 15 元体验额度）
   - **注意**：区分国内/全球站点密钥（国内用 `.cn` 域名，全球用 `.ai`）

2. **安装运行环境**
   - Node.js ≥ v18（https://nodejs.org/en）
   - 安装 Claude Code：  
     ```bash
     npm install -g @anthropic-ai/claude-code
     ```  
     

---

### 🛠️ 三、接入方案（三种方法）

#### 方法一：环境变量法（通用性强）
```bash
# 设置 API 重定向（国内密钥）
export ANTHROPIC_BASE_URL=https://api.moonshot.cn/anthropic
export ANTHROPIC_API_KEY=你的Kimi_API_Key

# 启动 Claude Code
claude
```
**验证成功标志**：  
终端显示 `Connected to custom endpoint: Moonshot AI`  
**系统适配**：
- Linux/Mac：直接终端执行
- Windows PowerShell：  
  ```powershell
  $env:ANTHROPIC_BASE_URL="https://api.moonshot.cn/anthropic/"
  $env:ANTHROPIC_API_KEY="你的Key"
  claude
  ```  
  

#### 方法二：自动化脚本法（适合快速部署）
```bash
# 使用开源工具 kimi-cc 自动配置
bash -c "$(curl -fsSL https://raw.githubusercontent.com/LLM-Red-Team/kimi-cc/main/install.sh)"
```
- 按提示粘贴 API Key 即可完成绑定
- 支持自动创建配置文件 `~/.claude.json`

#### 方法三：Windows 永久配置（生产环境推荐）
1. 创建 PowerShell 配置文件：  
   ```powershell
   notepad $PROFILE  # 编辑配置文件
   ```
2. 添加以下内容：  
   ```powershell
   $env:ANTHROPIC_BASE_URL = "https://api.moonshot.cn/anthropic/"
   $env:ANTHROPIC_API_KEY = "你的Key"
   $env:CLAUDE_CODE_GIT_BASH_PATH = "C:\Program Files\Git\bin\bash.exe"  # 替换实际路径
   ```  
   
3. 重启终端后直接运行 `claude`

---

### ⚠️ 四、关键避坑指南
1. **API 地址混淆**  
   国内 Key 必须用 `https://api.moonshot.cn/anthropic`，全球 Key 用 `https://api.moonshot.ai/anthropic`，否则报 `401 Invalid token`

2. **Claude Code 首次配置**  
   首次运行 `claude` 后需修改配置文件：
   - 找到 `~/.claude.json`
   - 添加 `"hasCompletedOnboarding": true` 并关闭自动更新：  
     ```json
     {
       "autoUpdates": false,
       "hasCompletedOnboarding": true
     }
     ```  
     

3. **Windows 路径问题**  
   - 路径含空格时需加引号：`$env:CLAUDE_CODE_GIT_BASH_PATH="C:\My Tools\Git\bin\bash.exe"`  
   - 验证路径存在：`Test-Path "C:\...\bash.exe"`

---

### 🚨 五、常见问题解决
| 问题现象                | 解决方案                                                                 |
|-------------------------|--------------------------------------------------------------------------|
| `Error: Invalid API Key` | 检查 Key 是否复制完整，确认账户余额 >0         |
| 端口冲突（Windows）     | 修改端口号：`-p 8080:8080` → `-p 8800:8080`                 |
| `429 Too Many Requests` | 免费账户并发受限，升级企业版或降低请求频率                  |
| 无法识别设备（Mac）     | 执行 `adb kill-server && adb start-server` 重置连接         |

---

### 💡 六、进阶应用
- **企业级调用**：通过 Kimi K2 的批量异步接口（单次支持 100+ 任务并行），处理合同审查或日志分析
- **结构化输出**：在提示词中要求生成 JSON/XML 格式，直接对接业务系统
- **成本监控**：Moonshot 控制台提供实时 Token 消耗统计

> 通过上述配置，Claude Code 可完整调用 Kimi K2 的 **200K 超长上下文**和 **MoE 架构高效推理**能力，尤其适合中文代码生成与文档处理，成本降低 50% 以上。建议首次使用后执行 `claude --version` 验证连接状态，输出 `Kimi-K2-Engine` 即表示成功接入。
