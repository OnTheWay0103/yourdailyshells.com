# 在 Claude Code 中接入 DeepSeek 模型

在 Claude Code 中接入 DeepSeek 模型,不仅能大幅降低成本（相比 Claude 官方模型），还能保留 Claude Code 强大的代码理解和终端协作能力。以下是基于开源工具和社区实践的 **3 种主流配置方案**，均验证有效且部署简单：

---

### ⚙️ 方案一：通过 claude-bridge 代理（最轻量）
**特点**：适合快速部署，仅需 Node.js 环境，5 分钟完成配置。  
**原理**：`claude-bridge` 作为本地代理，将 Claude Code 的请求转为 DeepSeek 兼容的 OpenAI 格式。  

#### 配置步骤：
1. **安装 Claude Code**（需 Node.js ≥ 18）：  
   ```bash
   npm install -g @anthropic-ai/claude-code
   ```

2. **安装 claude-bridge**：  
   ```bash
   npm install -g @mariozechner/claude-bridge
   ```

3. **设置环境变量**（替换为你的 DeepSeek API Key）：  
   ```bash
   export OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxx
   ```

4. **启动代理服务**：  
   ```bash
   claude-bridge openai deepseek-chat --baseURL https://api.deepseek.com/v1
   ```

5. **运行 Claude Code**：  
   ```bash
   claude  # 此时请求实际由 DeepSeek 处理
   ```  
**效果**：终端输入指令后，DeepSeek 模型会生成代码并自动执行文件操作（如创建/修改文件）[citation:2]。

> ✅ **优点**：无需修改配置文件，一条命令启动。  
> ❌ **局限**：不支持多模型路由，复杂场景需进阶方案。

---

### 🔄 方案二：通过 LiteLLM 代理（支持多模型路由）
**特点**：可同时接入 DeepSeek、Gemini、OpenAI 等模型，按任务类型自动分流请求。  

#### 配置步骤：
1. **安装 LiteLLM**：  
   ```bash
   pip install 'litellm[proxy]'
   ```

2. **创建配置文件 `config.yaml`**：  
   ```yaml
   model_list:
     - model_name: deepseek-reasoner
       litellm_params:
         model: deepseek/deepseek-reasoner
         api_key: os.environ/DEEPSEEK_API_KEY  # 替换为你的Key
   ```

3. **启动代理服务**：  
   ```bash
   litellm -c config.yaml --detailed_debug
   ```

4. **设置 Claude Code 环境变量**：  
   ```bash
   export ANTHROPIC_BASE_URL=http://localhost:4000  # LiteLLM 默认端口
   export ANTHROPIC_MODEL=deepseek-reasoner
   claude
   ```  

**智能路由示例**：  
- 简单任务 → DeepSeek-Chat（低成本）  
- 复杂推理 → DeepSeek-Reasoner（高性能）  
- 长上下文 → Gemini 或 Qwen（需额外配置）[citation:3]

> ✅ **优点**：灵活切换模型，支持预算控制和审计日志。  
> ❌ **局限**：需 Python 环境，配置略复杂。

---

### 🧠 方案三：通过 Claude Code Router（国产优化版）
**特点**：专为国内开发者优化，预置 DeepSeek 路由规则，支持动态模型切换。  

#### 配置步骤：
1. **安装 Claude Code Router**：  
   ```bash
   npm install -g @musistudio/claude-code-router
   ```

2. **编辑配置文件 `~/.claude-code-router/config.json`**：  
   ```json
   {
     "OPENAI_API_KEY": "sk-xxxxxxxx",  // DeepSeek API Key
     "OPENAI_BASE_URL": "https://api.deepseek.com",
     "Providers": [
       {
         "name": "deepseek",
         "api_base_url": "https://api.deepseek.com",
         "api_key": "sk-xxxxxxxx",
         "models": ["deepseek-reasoner", "deepseek-chat"]
       }
     ],
     "Router": {
       "background": "deepseek,deepseek-chat",     // 后台任务用低成本模型
       "think": "deepseek,deepseek-reasoner",      // 核心推理用高性能模型
       "longContext": "deepseek,deepseek-reasoner" // 长文本任务
     }
   }
   ```

3. **启动服务**：  
   ```bash
   ccr code  # 替代原版 claude 命令
   ```  

**动态切换模型**（终端内操作）：  
```bash
/model deepseek,deepseek-reasoner  # 切换到高性能模型
/model deepseek,deepseek-chat       # 切换到经济模型
```[citation:4]

> ✅ **优点**：中文文档完善，支持混合路由（如 DeepSeek + Qwen 长文本）。  
> ❌ **局限**：仅限 Node.js 环境。

---

### ⚠️ 关键注意事项：
1. **API 成本控制**：  
   - DeepSeek 当前定价 ≈ $0.001/千 tokens，比 Claude 低 90%+  
   - 在 `config.json` 中设置 `max_tokens` 和 `rate_limit` 防超额[citation:4]。

2. **模型能力适配**：  
   - **代码生成**：优先选 `deepseek-reasoner`（128K 上下文）  
   - **简单问答**：用 `deepseek-chat` 降低成本  
   - **超长文本**（>128K）：需搭配 Gemini 或 Qwen[citation:4]。

3. **安全建议**：  
   - 切勿泄露 API Key，环境变量优先于硬编码  
   - 首次使用建议关闭 `Auto-Approve`，确认操作权限[citation:6]。

---

### 💎 三种方案对比总结
| **特性**          | claude-bridge       | LiteLLM              | Claude Code Router  |
|-------------------|---------------------|----------------------|---------------------|
| **安装速度**       | ⭐⭐⭐⭐ (最快)        | ⭐⭐⭐ (需Python)       | ⭐⭐⭐⭐               |
| **多模型支持**     | ❌                   | ⭐⭐⭐⭐⭐                | ⭐⭐⭐⭐               |
| **动态路由**       | ❌                   | ⭐⭐⭐⭐                 | ⭐⭐⭐⭐⭐ (中文友好)    |
| **长上下文处理**   | ❌                   | ⭐⭐⭐⭐ (需配置Gemini)  | ⭐⭐⭐⭐ (支持Qwen)    |
| **适合人群**       | 快速尝鲜开发者       | 多模型需求团队        | 国内深度使用者       |

**所有工具均开源，代码见:
[claude-bridge](https://github.com/badlogic/claude-bridge) 
[LiteLLM](https://github.com/BerriAI/litellm) 
[Claude Code Router](https://github.com/musistudio/claude-code-router)

> 初次尝试建议从 
**方案一（claude-bridge）**入门，追求灵活选 
**方案二（LiteLLM）**适合团队
**方案三（Router）**企业级部署用 


