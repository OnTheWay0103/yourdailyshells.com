# 3小时带你学会前端开发 Next.js 14 + TypeScript

## 简介
本指南旨在帮助初级和中级前端开发者使用 Next.js 14、TypeScript、Tailwind CSS、Framer Motion、Zustand、Radix UI、Headless UI 以及 Fabric.js + Canvas API 进行开发。我们将从环境搭建开始，逐步介绍各个技术栈的使用方法，并提供一个简单的示例项目供练习。

## 环境搭建
### 安装 Node.js 和 npm
确保你已经安装了 Node.js（推荐版本 18 及以上）和 npm。你可以从 [Node.js 官方网站](https://nodejs.org/) 下载安装。

### 创建 Next.js 项目
使用以下命令创建一个新的 Next.js 项目：
```bash
npx create-next-app@latest my-next-app --typescript
cd my-next-app
```

### 安装依赖
安装所需的依赖：
```bash
npm install tailwindcss framer-motion zustand @radix-ui/react-dialog @headlessui/react fabric
```

## 技术栈详解
### Next.js 14 + TypeScript
Next.js 是一个基于 React 的全栈框架，支持服务端渲染（SSR）和静态站点生成（SSG）。TypeScript 为 JavaScript 添加了静态类型，提高了代码的可维护性。

#### 配置 TypeScript
Next.js 已经默认支持 TypeScript，你可以在 `pages` 目录下创建 `.tsx` 文件。

### Tailwind CSS + Framer Motion
Tailwind CSS 是一个实用类优先的 CSS 框架，而 Framer Motion 是一个用于创建动画的 React 库。

#### 配置 Tailwind CSS
运行以下命令初始化 Tailwind CSS：
```bash
npx tailwindcss init -p
```
在 `tailwind.config.js` 中添加以下配置：
```javascript
module.exports = { 
  content: [
    "./pages/**/*.{js,ts,jsx,tsx}",
    "./components/**/*.{js,ts,jsx,tsx}",
  ],
  theme: { 
    extend: {}, 
  }, 
  plugins: [], 
}
```
在 `styles/globals.css` 中添加 Tailwind CSS 的指令：
```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

### Zustand
Zustand 是一个轻量级的状态管理库，易于使用和集成。

#### 创建状态存储
在 `src` 目录下创建 `store.ts` 文件：
```typescript
import create from 'zustand';

interface CounterState {
  count: number;
  increment: () => void;
  decrement: () => void;
}

const useCounterStore = create<CounterState>((set) => ({ 
  count: 0, 
  increment: () => set((state) => ({ count: state.count + 1 })), 
  decrement: () => set((state) => ({ count: state.count - 1 })), 
}));

export default useCounterStore;
```

### Radix UI + Headless UI
Radix UI 和 Headless UI 提供了一系列可访问的 UI 组件。

#### 使用 Radix UI 对话框组件
```tsx
import * as Dialog from '@radix-ui/react-dialog';

const MyDialog = () => (
  <div>
    <Dialog.Root>
      <Dialog.Trigger asChild>
        <button>打开对话框</button>
      </Dialog.Trigger>
      <Dialog.Portal>
        <Dialog.Overlay />
        <Dialog.Content>
          <Dialog.Title>这是一个对话框</Dialog.Title>
          <Dialog.Description>对话框内容</Dialog.Description>
          <Dialog.Close asChild>
            <button>关闭</button>
          </Dialog.Close>
        </Dialog.Content>
      </Dialog.Portal>
    </Dialog.Root>
  </div>
);

export default MyDialog;
```

### Fabric.js + Canvas API
Fabric.js 是一个强大的 Canvas 库，简化了 Canvas 的操作。

#### 创建 Canvas 画布
```tsx
import { fabric } from 'fabric';

const FabricCanvas = () => {
  useEffect(() => {
    const canvas = new fabric.Canvas('myCanvas');
    const rect = new fabric.Rect({ 
      left: 100, 
      top: 100, 
      width: 60, 
      height: 70, 
      fill: 'red', 
    }); 
    canvas.add(rect); 
  }, []); 

  return <canvas id="myCanvas" width="800" height="600" />;
};

export default FabricCanvas;
```

## 示例项目
### 项目结构
```
my-next-app/
├── pages/
│   ├── index.tsx
├── components/
│   ├── MyDialog.tsx
│   ├── FabricCanvas.tsx
├── src/
│   ├── store.ts
├── styles/
│   ├── globals.css
├── tailwind.config.js
```

### 运行项目
使用以下命令启动开发服务器：
```bash
npm run dev
```
访问 `http://localhost:3000` 查看项目。

## 总结
通过本指南，你已经了解了如何使用 Next.js 14、TypeScript、Tailwind CSS、Framer Motion、Zustand、Radix UI、Headless UI 以及 Fabric.js + Canvas API 进行前端开发。