# OpenSpec使用详解

OpenSpec 是一个轻量级的“规范驱动开发”工具，旨在通过引入一个规范层，让开发者与AI编程助手（如Cursor、Claude等）的协作变得可预测、可控。其核心哲学是：**先就“要构建什么”达成一致（写规范），然后再编写代码。**

以下是如何使用 OpenSpec 的步骤和核心工作流：

### 1. 安装与初始化
*   **安装**：确保系统已安装 Node.js 20.19.0 或更高版本。通过 npm 全局安装 OpenSpec。
    ```bash
    npm install -g openspec
    ```
*   **初始化项目**：进入你的项目根目录，运行初始化命令。这会在项目中创建 OpenSpec 所需的目录结构（如 `specs/`, `changes/`）和配置文件。
    ```bash
    openspec init
    ```

### 2. 核心工作流：从提案到归档
OpenSpec 推荐一个基于“变更提案”的原子化工作流。整个过程围绕 `changes/` 目录（变更沙箱）和 `specs/` 目录（权威规范库）展开。

**典型流程如下：**

1.  **创建变更提案**：
    *   在项目目录中，直接在你的AI编程助手（如Cursor的聊天框）中输入OpenSpec的指令：
        ```
        /opsx:propose
        ```
    *   AI助手会根据你的需求，引导你在 `changes/` 目录下创建一个 `proposal.md` 文件。你需要在此文件中清晰描述变更的**意图、范围、验收标准**以及**技术设计方案**。这是整个流程的起点，确保人类与AI先对齐“做什么”和“怎么做”。

2.  **基于提案实现代码**：
    *   提案完成后，你可以继续与AI助手协作，基于 `proposal.md` 和已有的 `specs/` 中的相关规范来实现代码。
    *   OpenSpec 提供了一套完整的斜杠命令来管理此过程（需通过 `openspec config profile` 选择并 `openspec update` 启用）：
        *   `/opsx:new`：开始一项新变更。
        *   `/opsx:continue`：继续当前的变更任务。
        *   `/opsx:verify`：验证变更是否符合规范。

3.  **同步与归档**：
    *   变更在 `changes/` 沙箱中完成并验证后，需要将其同步到主规范库。
    *   使用命令将本次变更的规范（提案和产生的spec增量）合并回 `specs/` 目录，完成知识沉淀：
        ```bash
        openspec sync
        # 或批量归档
        openspec bulk-archive
        ```

### 3. 关键命令与配置
*   **`openspec config profile`**：选择工作流配置文件。基础工作流只包含 `/opsx:propose`，而**扩展工作流**（expanded workflow）则包含上述完整的斜杠命令集（`/opsx:new`, `/opsx:continue`, `/opsx:ff`, `/opsx:verify`, `/opsx:sync`, `/opsx:bulk-archive`, `/opsx:onboard`）。对于完整体验，建议选择并启用扩展工作流。
*   **`openspec update`**：在更改配置（如切换profile）后，运行此命令来更新当前项目的AI助手指引，使新的斜杠命令生效。
*   **`/opsx:propose`**：最核心的启动命令，用于创建新的规范提案。

### 4. 最佳实践与注意事项
1.  **模型选择**：OpenSpec 在**高推理能力模型**上效果最佳。官方推荐使用 **Claude Opus 4.5** 和 **GPT 5.2** 来进行规划和实现。
2.  **保持上下文清洁**：OpenSpec 的有效性依赖于清晰的上下文。在开始实现前，**清空AI助手的聊天上下文**，并在整个会话中保持良好的上下文管理，避免无关历史对话干扰。
3.  **哲学理解**：使用OpenSpec时，始终记住其目标是**先对齐意图**。`proposal.md` 和 `specs/` 中的文档是你的“单一事实来源”，代码应由此生成。

### 总结：使用OpenSpec的简单步骤
1.  **安装**：`npm install -g openspec`
2.  **进入项目并初始化**：`cd your-project && openspec init`
3.  **配置工作流**：`openspec config profile` （选择扩展工作流，然后运行 `openspec update`）
4.  **开始一个新功能/修改**：在AI助手聊天框中输入 `/opsx:propose`，并遵循指引填写 `changes/proposal.md`。
5.  **协作开发**：使用 `/opsx:continue` 等命令，与AI一起基于提案实现代码。
6.  **完成与沉淀**：使用 `openspec sync` 将核准的变更归档到 `specs/`。

通过这个流程，OpenSpec 帮助你将对需求的讨论固化在版本控制的Markdown文件中，使AI的代码生成行为变得可预测、可审查，并将项目知识持续沉淀在 `specs/` 目录下，而非易逝的聊天记录里。