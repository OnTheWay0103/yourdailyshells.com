# Waline 评论系统使用教程

Waline 评论系统的详细介绍及从零部署的简明教程，结合最新官方文档和实践经验整理（截至 2025 年 6 月）。

## 一、Waline 是什么？

Waline 是一款轻量级、开源的现代化评论系统，专为静态网站（如 Hexo、Hugo、VitePress）设计。其核心特点包括：

### 轻量高效

- 前端仅约 50KB（gzip 压缩）
- 支持按需加载
- 对页面性能影响极小

### 功能丰富

- 支持 Markdown 语法、表情包、数学公式、暗黑模式
- 提供评论审核、垃圾过滤、IP 黑名单等安全机制
- 集成社交登录（微信/QQ/Telegram）、多语言、邮件通知

### 灵活部署

- 支持 Vercel/Netlify 等无服务器平台，以及 Docker 独立部署
- 兼容 LeanCloud、Supabase、MongoDB、MySQL 等主流数据库

### 开源免费

- 采用 GPL-2.0 许可证
- 无商用限制

## 二、快速部署教程（Vercel + LeanCloud）

### Step 1：创建数据库（LeanCloud）

1. 注册 [LeanCloud](https://leancloud.app/)  
2. 创建新应用：
   - 点击"创建应用"
   - 输入应用名称（如：`yourdailyshells-waline`）
   - 选择开发版（免费）
   - 点击"创建"
3. 获取应用配置：
   - 进入应用控制台
   - 点击"设置" -> "应用 Keys"
   - 记录以下信息：
     - App ID
     - App Key
     - Master Key
4. 配置安全域名：
   - 点击"设置" -> "安全中心"
   - 在"Web 安全域名"中添加你的网站域名
   - 在"服务器安全域名"中添加 Vercel 域名（如：`*.vercel.app`）

### Step 2：部署服务端（Vercel）

1. 通过模板一键部署：
   - 访问 [Vercel 部署链接](https://vercel.com/new/clone?repository-url=https://github.com/walinejs/waline/tree/main/example)
   - 使用 GitHub 登录 Vercel → 输入项目名称 → 点击 Create
2. 配置环境变量：
   - 进入项目 Settings → Environment Variables，添加以下变量：
     - `LEAN_ID` → 填入 LeanCloud 的 App ID
     - `LEAN_KEY` → 填入 App Key
     - `LEAN_MASTER_KEY` → 填入 Master Key
   - 返回 Deployments → 重新部署（Redeploy）使配置生效

### Step 3：集成到网站（客户端）

在网站 HTML 中引入 Waline 前端库并初始化（以 Hugo/Hexo 为例）：

```html
<!-- 引入样式 -->
<link
  rel="stylesheet"
  href="https://unpkg.com/@waline/client@v3/dist/waline.css"
/>

<!-- 评论容器 -->
<div id="waline"></div>

<!-- 初始化脚本 -->
<script type="module">
  import { init } from "https://unpkg.com/@waline/client@v3/dist/waline.js";
  init({
    el: "#waline",
    serverURL: "https://your-vercel-app.vercel.app", // Step 2 部署的服务端地址
    path: location.pathname, // 自动区分文章页
    dark: "auto", // 自动切换暗黑模式
  });
</script>
```

### Step 4：管理后台与高级功能

#### 管理员注册

- 访问服务端地址（如 https://your-vercel-app.vercel.app）
- 首次注册用户自动成为管理员

#### 后台管理

- 登录 https://your-vercel-app.vercel.app/ui
- 审核评论、管理用户、查看数据报表

#### 通知配置

- 在 Vercel 环境变量中添加邮箱/SMTP 配置
- 添加 `SMTP_HOST`, `SMTP_USER` 等变量启用邮件通知

## 三、避坑指南

### 域名访问问题

- Vercel 默认域名（\*.vercel.app）在国内可能被屏蔽
- 解决方案：绑定自定义域名并配置 DNS 解析

### 数据库管理

- LeanCloud 免费版提供：
  - 3GB 存储空间
  - 30GB 流量/月
  - 30,000 次 API 调用/天
  - 支持云引擎、云函数等高级功能
- 建议：定期监控使用情况，必要时升级付费版

### 安全加固

- 启用 `JWT_TOKEN` 环境变量加密数据传输
- 在 LeanCloud 控制台配置安全域名
- 定期备份数据库

## 总结

Waline 以"轻量易用 + 功能完备"成为静态网站评论系统的优选。通过 Vercel + LeanCloud 组合可实现快速部署，尤其适合个人博客与技术文档。LeanCloud 作为国内云服务提供商，提供稳定的数据库服务和良好的本地化支持，是评论系统的理想选择。

## 扩展资源

- [官方文档](https://waline.js.org/guide/get-started/)
- [主题适配](https://waline.js.org/guide/client/integration.html)
- [LeanCloud 文档](https://leancloud.app/docs/)
