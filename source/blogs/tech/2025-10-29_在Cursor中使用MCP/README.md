# 在Cursor中使用MCP

---

### 第一部分：在 Cursor 中使用 MCP

MCP 是一种协议，允许像 Cursor 这样的 AI 编码助手安全、可控地访问外部工具、数据源和系统。你可以把它想象成给 Cursor 安装了“插件”，极大地扩展了它的能力。

#### 1. 如何启用和使用现有的 MCP Server

Cursor 内置了对 MCP 的支持，但你需要通过配置文件来启用和连接不同的 Server。

**步骤如下：**

1.  **找到或创建配置文件：**
    Cursor 的 MCP 配置通常位于以下目录：
    *   **Windows:** `%USERPROFILE%\.cursor\mcp.json`
    *   **macOS/Linux:** `~/.cursor/mcp.json`

    如果文件不存在，你需要手动创建它。

2.  **编辑 `mcp.json` 文件：**
    这个文件是一个 JSON 数组，用于注册你想要使用的 MCP Server。每个 Server 的配置通常包含以下几个关键字段：
    *   `name`: 你给这个 Server 起的别名（在 Cursor 中提示时使用）。
    *   `command`: 启动 Server 的可执行命令或脚本的路径。
    *   `args`: (可选) 传递给命令的参数。
    *   `env`: (可选) 设置环境变量。

3.  **配置示例：**

    **示例 1：使用 Cursor 官方内置的 `curl` Server（无需安装）**
    Cursor 自带了一些简单的 Server，你可以直接配置使用。

    ```json
    [
      {
        "name": "curl",
        "command": "cursor",
        "args": ["mcp", "serve", "curl"]
      }
    ]
    ```
    保存文件后，重启 Cursor。现在你在聊天框里输入 `/`，就能看到可用的 `curl` 工具了，例如让 AI 帮你获取某个 API 的数据。

    **示例 2：使用流行的第三方 Server（如 `bash`）**
    许多第三方 MCP Server 需要通过 npm 或 pip 先安装。

    *   **安装 `@modelcontextprotocol/server-bash`：**
        ```bash
        npm install -g @modelcontextprotocol/server-bash
        # 或者
        # pip install mcp-server-bash
        ```

    *   **配置 `mcp.json`：**
        ```json
        [
          {
            "name": "bash",
            "command": "mcp-server-bash",
            "args": []
          }
        ]
        ```
        *注意：请确保 `mcp-server-bash` 命令在你的系统 PATH 里。重启 Cursor 后，你就可以在聊天中让 AI 安全地运行一些简单的 bash 命令了（例如列出文件、查看进程等）。*

4.  **在 Cursor 中使用：**
    *   配置好并重启 Cursor 后，当你打开聊天界面时，输入 `/`，就会自动列出所有可用的 MCP 工具和资源。
    *   选择你想要使用的工具，AI 就会通过你配置的 Server 来执行操作并获取结果，并将其作为上下文来回答你的问题。

---

### 第二部分：开发和集成自定义 MCP Server

当现有的 Server 无法满足你的需求时，你可以开发自己的 Server。官方推荐使用 **TypeScript/JavaScript** 或 **Python** 进行开发，因为有完善的 SDK。

#### 开发步骤（以 TypeScript 为例）：

1.  **环境准备：**
    *   安装 Node.js (>= 18)
    *   初始化一个新项目：
        ```bash
        mkdir my-mcp-server
        cd my-mcp-server
        npm init -y
        ```
    *   安装官方 SDK：
        ```bash
        npm install @modelcontextprotocol/sdk
        ```

2.  **编写 Server 代码：**
    创建一个文件，例如 `index.ts`。

    ```typescript
    import { Server } from '@modelcontextprotocol/sdk/server/index.js';
    import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
    import {
      CallToolRequest,
      ListToolsRequest,
      Tool,
    } from '@modelcontextprotocol/sdk/types.js';

    // 1. 创建一个 Server 实例
    const server = new Server(
      {
        name: 'my-custom-server', // 你的 Server 名称
        version: '1.0.0',         // 版本
      },
      {
        capabilities: {
          tools: {}, // 声明你的 Server 提供 Tools 功能
        },
      }
    );

    // 2. 定义你的工具（Tools）
    const tools: Tool[] = [
      {
        name: 'get-random-number',
        description: 'Generates a random number between a given min and max',
        inputSchema: {
          type: 'object',
          properties: {
            min: { type: 'number', description: 'Minimum value' },
            max: { type: 'number', description: 'Maximum value' },
          },
          required: ['min', 'max'],
        },
      },
      {
        name: 'get-current-time',
        description: 'Gets the current time in a specific timezone',
        inputSchema: {
          type: 'object',
          properties: {
            timezone: { type: 'string', description: 'Timezone identifier, e.g., Asia/Shanghai' },
          },
          required: [],
        },
      },
    ];

    // 3. 处理工具列表请求
    server.setRequestHandler(ListToolsRequest, async () => ({
      tools: tools,
    }));

    // 4. 处理工具执行请求
    server.setRequestHandler(CallToolRequest, async (request) => {
      const { name, arguments: args } = request.params;
      switch (name) {
        case 'get-random-number': {
          const { min, max } = args as { min: number; max: number };
          const randomNum = Math.floor(Math.random() * (max - min + 1)) + min;
          return {
            content: [
              {
                type: 'text',
                text: `Your random number is: ${randomNum}`,
              },
            ],
          };
        }

        case 'get-current-time': {
          const timezone = (args as { timezone?: string })?.timezone || 'UTC';
          const now = new Date().toLocaleString('en-US', { timeZone: timezone });
          return {
            content: [
              {
                type: 'text',
                text: `Current time in ${timezone} is: ${now}`,
              },
            ],
          };
        }

        default:
          throw new Error(`Unknown tool: ${name}`);
      }
    });

    // 5. 启动 Server，使用 STDIO 传输
    const transport = new StdioServerTransport();
    server.connect(transport);
    ```

3.  **编译和运行：**
    *   安装 `ts-node` 和 `typescript`（如果你使用 TypeScript）：
        ```bash
        npm install -D typescript ts-node
        npx tsc --init
        ```
    *   在 `package.json` 中添加一个启动脚本：
        ```json
        {
          "scripts": {
            "start": "ts-node index.ts"
          }
        }
        ```
    *   你可以先测试一下你的 Server：
        ```bash
        npm start
        ```
        它会在标准输入输出上运行，等待 Cursor 连接。

4.  **集成到 Cursor：**
    现在，修改你的 `~/.cursor/mcp.json` 文件，将你的自定义 Server 添加进去。

    ```json
    [
      {
        "name": "my-random-generator",
        "command": "node",
        "args": [
          "/path/to/your/my-mcp-server/dist/index.js" // 请替换为你的编译后的 JS 文件的实际绝对路径
        ]
      }
    ]
    ```
    *更好的做法是使用 `npm link` 或者将你的项目全局安装，这样就可以直接使用命令名而不是路径。*

5.  **重启并测试：**
    重启 Cursor，在聊天框中输入 `/`，你应该能看到 `get-random-number` 和 `get-current-time` 这两个工具了。尝试使用它们！

#### 开发提示：

*   **资源（Resources）**： 除了 Tools，你还可以实现 `ListResourcesRequest` 和 `ReadResourceRequest`，为 AI 提供可读取的静态或动态数据源（例如，你的项目配置文件、数据库 schema 等）。
*   **调试**： 开发时，可以在 Server 代码中添加 `console.log()` 来输出日志到终端，这对于调试非常有用。
*   **安全性**： 牢记你的 Server 将被 AI 调用，务必对输入进行严格的验证和清理，防止命令注入等安全风险。不要提供具有破坏性功能的工具（如 `rm -rf`）。

### 总结

| 步骤 | 使用 MCP | 开发自定义 MCP |
| :--- | :--- | :--- |
| **1** | 编辑 `~/.cursor/mcp.json` | 初始化项目，安装 SDK |
| **2** | 配置现有 Server 的命令 | 编写 Server 逻辑（Tools/Resources） |
| **3** | 重启 Cursor | 测试 Server 是否正常运行 |
| **4** | 在聊天框中按 `/` 使用 | 在 `mcp.json` 中注册你的 Server |
| **5** | - | 重启 Cursor 并进行测试 |

通过 MCP，将 Cursor 的能力与内部工具、数据库、API 以及任何系统无缝连接起来，极大地提升开发效率和 AI 助手的实用性。