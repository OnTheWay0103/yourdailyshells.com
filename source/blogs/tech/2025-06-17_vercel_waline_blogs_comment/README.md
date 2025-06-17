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
- 兼容 Supabase、MongoDB、MySQL 等主流数据库

### 开源免费

- 采用 GPL-2.0 许可证
- 无商用限制

## 二、快速部署教程（Vercel + Supabase）

### Step 1：创建数据库（Supabase）

1. 注册 [Supabase](https://supabase.com/)
2. 创建新项目：

   - 点击"New Project"
   - 输入项目名称（如：`yourdailyshells-waline`）
   - 设置数据库密码
   - 选择地区（建议选择离用户最近的区域）
   - 点击"Create new project"

3. 获取数据库配置：

   - 进入项目
   - 点击"Settings" -> "Database"
   - 记录以下信息：
     - Project URL
     - Project API Key (anon public)
     - Database Password

4. 初始化数据库表：
   - 进入 SQL 编辑器
   - 执行以下 SQL 创建必要的表：

```sql
-- 创建评论表
CREATE TABLE IF NOT EXISTS "comments" (
  "id" SERIAL PRIMARY KEY,
  "user_id" VARCHAR(255),
  "comment" TEXT,
  "ip" VARCHAR(255),
  "ua" VARCHAR(255),
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  "pid" INTEGER,
  "rid" INTEGER,
  "status" VARCHAR(255) DEFAULT 'approved',
  "link" VARCHAR(255),
  "mail" VARCHAR(255),
  "nick" VARCHAR(255)
);

-- 创建用户表
CREATE TABLE IF NOT EXISTS "users" (
  "id" SERIAL PRIMARY KEY,
  "display_name" VARCHAR(255),
  "email" VARCHAR(255),
  "password" VARCHAR(255),
  "type" VARCHAR(255),
  "created_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 创建计数器表
CREATE TABLE IF NOT EXISTS "counters" (
  "id" SERIAL PRIMARY KEY,
  "time" INTEGER,
  "reaction0" INTEGER DEFAULT 0,
  "reaction1" INTEGER DEFAULT 0,
  "reaction2" INTEGER DEFAULT 0,
  "reaction3" INTEGER DEFAULT 0,
  "reaction4" INTEGER DEFAULT 0,
  "reaction5" INTEGER DEFAULT 0,
  "reaction6" INTEGER DEFAULT 0,
  "reaction7" INTEGER DEFAULT 0,
  "reaction8" INTEGER DEFAULT 0
);
```

### Step 2：部署服务端（Vercel）

1. 通过模板一键部署：

   - 访问 [Vercel 部署链接](https://vercel.com/new/clone?repository-url=https://github.com/walinejs/waline/tree/main/example)
   - 使用 GitHub 登录 Vercel → 输入项目名称 → 点击 Create

2. 配置环境变量：
   - 进入项目 Settings → Environment Variables，添加以下变量：
     - `SUPABASE_URL` → 填入 Supabase 的 Project URL
     - `SUPABASE_KEY` → 填入 Project API Key
     - `SUPABASE_PASSWORD` → 填入 Database Password
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

- Supabase 免费版提供：
  - 500MB 数据库
  - 1GB 文件存储
  - 50MB 数据库备份
  - 2GB 带宽
- 建议：定期监控使用情况，必要时升级付费版

### 安全加固

- 启用 `JWT_TOKEN` 环境变量加密数据传输
- 配置 Supabase 的 Row Level Security (RLS) 策略
- 定期备份数据库

## 总结

Waline 以"轻量易用 + 功能完备"成为静态网站评论系统的优选。通过 Vercel + Supabase 组合可实现快速部署，尤其适合个人博客与技术文档。Supabase 提供更强大的数据库功能和更好的国际化支持，是评论系统的理想选择。

## 扩展资源

- [官方文档](https://waline.js.org/guide/get-started/)
- [主题适配](https://waline.js.org/guide/client/integration.html)
- [Supabase 文档](https://supabase.com/docs)
