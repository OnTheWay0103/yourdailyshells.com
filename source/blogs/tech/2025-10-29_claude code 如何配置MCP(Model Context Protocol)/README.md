# claude code 如何配置MCP(Model Context Protocol)。

MCP 允许 Claude Code 与外部工具、数据源和服务安全地交互，极大地扩展了其能力。配置主要分为**服务器端**和**客户端**两部分。

---

### 核心概念

1.  **MCP 服务器 (Server)**：提供工具或数据的独立进程（如 Python 脚本、二进制文件）。你需要安装或编写它。
2.  **MCP 客户端 (Client)**：Claude Code（或 Claude App）本身就是客户端，它会启动并连接到服务器。
3.  **配置**：你需要在 Claude Code 的配置文件中告诉客户端如何启动和连接哪些服务器。

---

### 配置步骤 (Claude Code 客户端)

配置主要通过修改 Claude Code 的 `settings.json` 文件完成。

#### 1. 打开 Claude Code 的设置

*   在 Claude Code 中，使用快捷键 `Ctrl + ,` (Windows/Linux) 或 `Cmd + ,` (Mac) 打开设置。
*   或者点击左下角的齿轮图标。

#### 2. 编辑 `settings.json`

*   在设置界面，点击右上角的 **{}** 图标（“打开设置 JSON”）。
*   这将打开一个可编辑的 `settings.json` 文件。

#### 3. 添加 MCP 服务器配置

在 `settings.json` 文件中，你需要添加一个 `"mcpServers"` 对象。该对象的每个属性名是你给这个服务器起的**自定义名称**，属性值是一个配置对象。

**基本配置结构如下：**

```json
{
  // ... 其他已有的设置 ...
  "mcpServers": {
    "my_calculator": {
      "command": "python",
      "args": [
        "/absolute/path/to/your/calculator_server.py"
      ]
    },
    "my_file_browser": {
      "command": "node",
      "args": [
        "/absolute/path/to/your/file-server/index.mjs"
      ]
    }
  }
}
```

**配置参数详解：**

*   `command` (**必需**): 用于启动服务器的命令（如 `python`, `node`, `bash`, 或二进制文件的绝对路径）。
*   `args` (**必需**): 传递给上述命令的参数数组，通常是你的服务器脚本或程序的路径。
*   `env` (可选): 设置服务器进程的环境变量。
    ```json
    "env": {
      "OPENAI_API_KEY": "your-api-key-here",
      "SERPAPI_KEY": "your-serpapi-key"
    }
    ```
*   `cwd` (可选): 设置服务器启动的工作目录。
    ```json
    "cwd": "/path/to/working/directory"
    ```

#### 4. 保存并重载

保存 `settings.json` 文件后，Claude Code 会自动重载配置。如果服务器配置正确，你就可以在对话中使用新的工具了。

---

### 服务器配置示例 (Python)

假设你想用一个用 Python 写的简单 MCP 服务器（例如，一个提供计算和获取随机数工具的服务器）。

**1. 创建服务器脚本 (`simple_server.py`)**

你需要先安装官方 MCP SDK：
```bash
pip install model-context-protocol
```

```python
# simple_server.py
import math
import random
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool

# 初始化 Server
server = Server("simple-python-server")

# 定义可用的工具列表
@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="calculate",
            description="计算一个数学表达式的值，例如 '(1 + 2) * 3'。",
            inputSchema={
                "type": "object",
                "properties": {
                    "expression": {
                        "type": "string",
                        "description": "要计算的数学表达式。"
                    }
                },
                "required": ["expression"]
            }
        ),
        Tool(
            name="get_random_number",
            description="在指定范围内生成一个随机整数。",
            inputSchema={
                "type": "object",
                "properties": {
                    "min": {
                        "type": "number",
                        "description": "范围下限（包含）。"
                    },
                    "max": {
                        "type": "number",
                        "description": "范围上限（包含）。"
                    }
                },
                "required": ["min", "max"]
            }
        )
    ]

# 实现工具的功能
@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[dict]:
    if name == "calculate":
        expression = arguments["expression"]
        try:
            # 警告：在实际生产环境中，直接 eval 是危险的！
            # 这里仅作演示，应使用更安全的方法（如 ast.literal_eval）
            result = eval(expression, {"__builtins__": None}, {"math": math})
            return [{
                "type": "text",
                "text": f"计算结果: {result}"
            }]
        except Exception as e:
            return [{
                "type": "text",
                "text": f"计算错误: {e}"
            }]
    elif name == "get_random_number":
        min_val = arguments["min"]
        max_val = arguments["max"]
        num = random.randint(int(min_val), int(max_val))
        return [{
            "type": "text",
            "text": f"随机数: {num}"
        }]
    else:
        raise ValueError(f"未知工具: {name}")

# 主入口点
if __name__ == "__main__":
    with stdio_server() as transport:
        server.run(transport)
```

**2. 配置 Claude Code**

在你的 `settings.json` 中，添加指向这个 Python 脚本的配置。

```json
{
  // ... 你的其他设置 ...
  "mcpServers": {
    "simple-python-demo": {
      "command": "python",
      "args": [
        "/absolute/path/to/your/simple_server.py"
      ]
    }
  }
}
```

**3. 使用**

配置完成后，重启 Claude Code。在对话中，当你输入 `@` 时，应该能看到一个名为 `simple-python-demo` 的服务器，其下的 `calculate` 和 `get_random_number` 工具可供选择。

---

### 使用现有的 MCP 服务器

社区已经开发了许多功能强大的 MCP 服务器，无需自己编写代码，只需配置即可。

**例如，配置 `sqlite` 服务器：**

1.  **安装服务器**：
    通常可以通过包管理器（如 npm、pip）安装。
    ```bash
    npm install -g @modelcontextprotocol/server-sqlite
    ```

2.  **配置 Claude Code**：
    在 `settings.json` 中指定该全局命令。

    ```json
    {
      "mcpServers": {
        "company-database": {
          "command": "mcp-server-sqlite",
          "args": [
            "/path/to/your/company.db"
          ]
        }
      }
    }
    ```

**其他流行的 MCP 服务器：**
*   **文件系统**: `@modelcontextprotocol/server-fs`
*   **HTTP 请求**: `@modelcontextprotocol/server-http`
*   **搜索引擎**: `@modelcontextprotocol/server-serpapi`
*   **Git**: `@modelcontextprotocol/server-git`
*   **SQL 数据库** (PostgreSQL, MySQL): 社区有多个选择

安装后，参照其文档进行配置即可。

---

### 故障排除和技巧

1.  **查看日志**：如果工具不出现，首先检查 Claude Code 的 **Help -> Toggle Developer Tools -> Console**，这里会有详细的错误信息。
2.  **使用绝对路径**：在 `command` 和 `args` 中，尽量使用程序的**绝对路径**，避免因环境变量 `PATH` 导致找不到命令的问题。
3.  **权限问题**：确保你的脚本或二进制文件具有可执行权限。
4.  **虚拟环境**：如果使用 Python 虚拟环境，`command` 应指向虚拟环境内的 `python` 解释器绝对路径。
5.  **社区资源**：访问 **https://modelcontextprotocol.io** 和 **https://github.com/modelcontextprotocol/awesome-mcp** 仓库，发现更多服务器和学习资源。
