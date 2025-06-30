# 3 小时带你学会前端开发 Next.js 14 + TypeScript

## 简介

本指南旨在帮助初级和中级前端开发者使用 Next.js 14、TypeScript、Tailwind CSS、Framer Motion、Zustand、Radix UI、Headless UI 以及 Fabric.js + Canvas API 进行开发。我们将从环境搭建开始，逐步介绍各个技术栈的使用方法，并提供一个完整的示例项目供练习。

## 🚀 环境搭建

### 1. 安装 Node.js 和 npm

确保你已经安装了 Node.js（推荐版本 18 及以上）和 npm。你可以从 [Node.js 官方网站](https://nodejs.org/) 下载安装。

验证安装：

```bash
node --version
npm --version
```

### 2. 创建 Next.js 项目

使用以下命令创建一个新的 Next.js 项目：

```bash
npx create-next-app@latest frontend-learning-project --typescript --tailwind --eslint --app --src-dir --import-alias "@/*"
cd frontend-learning-project
```

### 3. 安装额外依赖

安装项目所需的所有依赖：

```bash
npm install framer-motion zustand @radix-ui/react-dialog @radix-ui/react-dropdown-menu @radix-ui/react-tabs @radix-ui/react-toast @radix-ui/react-tooltip @headlessui/react fabric @types/fabric clsx tailwind-merge
```

### 4. 验证项目结构

确保你的项目结构如下：

```
frontend-learning-project/
├── src/
│   ├── app/
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── page.tsx
│   ├── components/
│   ├── store/
│   ├── lib/
│   └── types/
├── package.json
├── tailwind.config.js
├── tsconfig.json
└── next.config.js
```

## 📦 技术栈详解

### Next.js 14 + TypeScript

Next.js 是一个基于 React 的全栈框架，支持服务端渲染（SSR）和静态站点生成（SSG）。TypeScript 为 JavaScript 添加了静态类型，提高了代码的可维护性。

#### 配置 TypeScript

Next.js 已经默认支持 TypeScript。在 `tsconfig.json` 中确保以下配置：

```json
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "es6"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [
      {
        "name": "next"
      }
    ],
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

### Tailwind CSS + Framer Motion

Tailwind CSS 是一个实用类优先的 CSS 框架，而 Framer Motion 是一个用于创建动画的 React 库。

#### 配置 Tailwind CSS

在 `tailwind.config.js` 中添加以下配置：

```javascript
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: "#eff6ff",
          500: "#3b82f6",
          600: "#2563eb",
          700: "#1d4ed8",
        },
      },
    },
  },
  plugins: [],
};
```

在 `src/app/globals.css` 中添加 Tailwind CSS 的指令：

```css
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer components {
  .card {
    @apply bg-white rounded-lg shadow-sm border border-gray-200 p-6;
  }
}
```

## 🛠️ 项目实现

### 1. 创建类型定义

首先创建 TypeScript 类型定义文件 `src/types/index.ts`：

```typescript
export interface Todo {
  id: string;
  text: string;
  completed: boolean;
  createdAt: Date;
}

export interface ThemeState {
  theme: "light" | "dark";
  toggleTheme: () => void;
}
```

### 2. 创建工具函数

创建 `src/lib/utils.ts` 文件：

```typescript
import { type ClassValue, clsx } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function generateId(): string {
  return Math.random().toString(36).substr(2, 9);
}

export function formatDate(date: Date): string {
  return new Intl.DateTimeFormat("zh-CN", {
    year: "numeric",
    month: "short",
    day: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  }).format(date);
}
```

### 3. 创建基础 UI 组件

创建 `src/components/ui/Button.tsx`：

```typescript
import React from "react";
import { cn } from "@/lib/utils";

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: "primary" | "secondary" | "ghost" | "outline";
  size?: "sm" | "md" | "lg";
}

export const Button: React.FC<ButtonProps> = ({
  children,
  className,
  variant = "primary",
  size = "md",
  ...props
}) => {
  const baseClasses =
    "inline-flex items-center justify-center rounded-md font-medium transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:pointer-events-none";

  const variants = {
    primary: "bg-primary-500 text-white hover:bg-primary-600",
    secondary: "bg-gray-100 text-gray-900 hover:bg-gray-200",
    ghost: "hover:bg-gray-100 text-gray-700",
    outline: "border border-gray-300 bg-white hover:bg-gray-50",
  };

  const sizes = {
    sm: "h-8 px-3 text-sm",
    md: "h-10 px-4 py-2",
    lg: "h-12 px-8 text-lg",
  };

  return (
    <button
      className={cn(baseClasses, variants[variant], sizes[size], className)}
      {...props}
    >
      {children}
    </button>
  );
};
```

创建 `src/components/ui/Input.tsx`：

```typescript
import React from "react";
import { cn } from "@/lib/utils";

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {}

export const Input: React.FC<InputProps> = ({ className, ...props }) => {
  return (
    <input
      className={cn(
        "flex h-10 w-full rounded-md border border-gray-300 bg-white px-3 py-2 text-sm ring-offset-white file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-gray-500 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500 focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
        className
      )}
      {...props}
    />
  );
};
```

### 4. 创建状态管理

创建 `src/store/todoStore.ts`：

```typescript
import { create } from "zustand";
import { devtools } from "zustand/middleware";
import { Todo } from "@/types";
import { generateId } from "@/lib/utils";

interface TodoState {
  todos: Todo[];
  addTodo: (text: string) => void;
  toggleTodo: (id: string) => void;
  deleteTodo: (id: string) => void;
  updateTodo: (id: string, text: string) => void;
  clearCompleted: () => void;
}

export const useTodoStore = create<TodoState>()(
  devtools(
    (set, get) => ({
      todos: [],

      addTodo: (text: string) => {
        const newTodo: Todo = {
          id: generateId(),
          text,
          completed: false,
          createdAt: new Date(),
        };
        set((state) => ({
          todos: [...state.todos, newTodo],
        }));
      },

      toggleTodo: (id: string) => {
        set((state) => ({
          todos: state.todos.map((todo) =>
            todo.id === id ? { ...todo, completed: !todo.completed } : todo
          ),
        }));
      },

      deleteTodo: (id: string) => {
        set((state) => ({
          todos: state.todos.filter((todo) => todo.id !== id),
        }));
      },

      updateTodo: (id: string, text: string) => {
        set((state) => ({
          todos: state.todos.map((todo) =>
            todo.id === id ? { ...todo, text } : todo
          ),
        }));
      },

      clearCompleted: () => {
        set((state) => ({
          todos: state.todos.filter((todo) => !todo.completed),
        }));
      },
    }),
    {
      name: "todo-store",
    }
  )
);
```

创建 `src/store/themeStore.ts`：

```typescript
import { create } from "zustand";
import { persist } from "zustand/middleware";

interface ThemeState {
  theme: "light" | "dark";
  toggleTheme: () => void;
}

export const useThemeStore = create<ThemeState>()(
  persist(
    (set) => ({
      theme: "light",
      toggleTheme: () =>
        set((state) => ({ theme: state.theme === "light" ? "dark" : "light" })),
    }),
    {
      name: "theme-store",
    }
  )
);
```

### 5. 创建待办事项组件

创建 `src/components/TodoList.tsx`：

```typescript
"use client";

import React, { useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import { useTodoStore } from "@/store/todoStore";
import { Button } from "@/components/ui/Button";
import { Input } from "@/components/ui/Input";
import { formatDate } from "@/lib/utils";

const TodoList: React.FC = () => {
  const { todos, addTodo, toggleTodo, deleteTodo, updateTodo, clearCompleted } =
    useTodoStore();
  const [newTodo, setNewTodo] = useState("");
  const [editingId, setEditingId] = useState<string | null>(null);
  const [editText, setEditText] = useState("");

  const handleAddTodo = (e: React.FormEvent) => {
    e.preventDefault();
    if (newTodo.trim()) {
      addTodo(newTodo.trim());
      setNewTodo("");
    }
  };

  const handleEdit = (todo: { id: string; text: string }) => {
    setEditingId(todo.id);
    setEditText(todo.text);
  };

  const handleSaveEdit = (id: string) => {
    if (editText.trim()) {
      updateTodo(id, editText.trim());
      setEditingId(null);
      setEditText("");
    }
  };

  const handleCancelEdit = () => {
    setEditingId(null);
    setEditText("");
  };

  const completedCount = todos.filter((todo) => todo.completed).length;
  const totalCount = todos.length;

  return (
    <div className="max-w-2xl mx-auto p-6">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="card"
      >
        <h1 className="text-3xl font-bold text-gray-900 mb-6">待办事项</h1>

        {/* 添加新待办事项 */}
        <form onSubmit={handleAddTodo} className="mb-6">
          <div className="flex gap-2">
            <Input
              value={newTodo}
              onChange={(e) => setNewTodo(e.target.value)}
              placeholder="添加新的待办事项..."
              className="flex-1"
            />
            <Button type="submit" disabled={!newTodo.trim()}>
              添加
            </Button>
          </div>
        </form>

        {/* 统计信息 */}
        {todos.length > 0 && (
          <div className="flex justify-between items-center mb-4 text-sm text-gray-600">
            <span>
              已完成 {completedCount} / {totalCount}
            </span>
            {completedCount > 0 && (
              <Button variant="ghost" size="sm" onClick={clearCompleted}>
                清除已完成
              </Button>
            )}
          </div>
        )}

        {/* 待办事项列表 */}
        <div className="space-y-2">
          <AnimatePresence>
            {todos.map((todo) => (
              <motion.div
                key={todo.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: 20 }}
                className="flex items-center gap-3 p-3 bg-gray-50 rounded-lg border"
              >
                <input
                  type="checkbox"
                  checked={todo.completed}
                  onChange={() => toggleTodo(todo.id)}
                  className="w-4 h-4 text-primary-600 rounded focus:ring-primary-500"
                />

                {editingId === todo.id ? (
                  <div className="flex-1 flex gap-2">
                    <Input
                      value={editText}
                      onChange={(e) => setEditText(e.target.value)}
                      onKeyDown={(e) => {
                        if (e.key === "Enter") handleSaveEdit(todo.id);
                        if (e.key === "Escape") handleCancelEdit();
                      }}
                      autoFocus
                    />
                    <Button size="sm" onClick={() => handleSaveEdit(todo.id)}>
                      保存
                    </Button>
                    <Button
                      variant="secondary"
                      size="sm"
                      onClick={handleCancelEdit}
                    >
                      取消
                    </Button>
                  </div>
                ) : (
                  <div className="flex-1">
                    <div
                      className={`${
                        todo.completed
                          ? "line-through text-gray-500"
                          : "text-gray-900"
                      } cursor-pointer`}
                      onClick={() => handleEdit(todo)}
                    >
                      {todo.text}
                    </div>
                    <div className="text-xs text-gray-400 mt-1">
                      {formatDate(todo.createdAt)}
                    </div>
                  </div>
                )}

                <div className="flex gap-1">
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => handleEdit(todo)}
                    disabled={editingId === todo.id}
                  >
                    编辑
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => deleteTodo(todo.id)}
                    className="text-red-600 hover:text-red-700"
                  >
                    删除
                  </Button>
                </div>
              </motion.div>
            ))}
          </AnimatePresence>
        </div>

        {todos.length === 0 && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="text-center py-8 text-gray-500"
          >
            暂无待办事项，开始添加吧！
          </motion.div>
        )}
      </motion.div>
    </div>
  );
};

export default TodoList;
```

### 6. 创建 Canvas 编辑器组件

创建 `src/components/CanvasEditor.tsx`：

```typescript
"use client";

import React, { useEffect, useRef, useState } from "react";
import { fabric } from "fabric";
import { motion } from "framer-motion";
import { Button } from "@/components/ui/Button";

const CanvasEditor: React.FC = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const fabricCanvasRef = useRef<fabric.Canvas | null>(null);
  const [selectedTool, setSelectedTool] = useState<
    "select" | "rect" | "circle" | "text" | "line"
  >("select");
  const [canvasHistory, setCanvasHistory] = useState<string[]>([]);
  const [historyIndex, setHistoryIndex] = useState(-1);

  useEffect(() => {
    if (canvasRef.current && !fabricCanvasRef.current) {
      const canvas = new fabric.Canvas(canvasRef.current, {
        width: 800,
        height: 600,
        backgroundColor: "#ffffff",
      });

      fabricCanvasRef.current = canvas;

      // 保存初始状态
      saveCanvasState();

      // 监听画布变化
      canvas.on("object:added", saveCanvasState);
      canvas.on("object:modified", saveCanvasState);
      canvas.on("object:removed", saveCanvasState);

      return () => {
        canvas.dispose();
      };
    }
  }, []);

  const saveCanvasState = () => {
    if (fabricCanvasRef.current) {
      const json = fabricCanvasRef.current.toJSON();
      const newHistory = canvasHistory.slice(0, historyIndex + 1);
      newHistory.push(JSON.stringify(json));
      setCanvasHistory(newHistory);
      setHistoryIndex(newHistory.length - 1);
    }
  };

  const addRectangle = () => {
    if (fabricCanvasRef.current) {
      const rect = new fabric.Rect({
        left: 100,
        top: 100,
        width: 100,
        height: 100,
        fill: "#3b82f6",
        stroke: "#1d4ed8",
        strokeWidth: 2,
      });
      fabricCanvasRef.current.add(rect);
      fabricCanvasRef.current.setActiveObject(rect);
    }
  };

  const addCircle = () => {
    if (fabricCanvasRef.current) {
      const circle = new fabric.Circle({
        left: 200,
        top: 100,
        radius: 50,
        fill: "#10b981",
        stroke: "#059669",
        strokeWidth: 2,
      });
      fabricCanvasRef.current.add(circle);
      fabricCanvasRef.current.setActiveObject(circle);
    }
  };

  const addText = () => {
    if (fabricCanvasRef.current) {
      const text = new fabric.Text("点击编辑文字", {
        left: 100,
        top: 200,
        fontSize: 20,
        fill: "#374151",
        fontFamily: "Arial",
      });
      fabricCanvasRef.current.add(text);
      fabricCanvasRef.current.setActiveObject(text);
    }
  };

  const addLine = () => {
    if (fabricCanvasRef.current) {
      const line = new fabric.Line([50, 50, 200, 200], {
        stroke: "#ef4444",
        strokeWidth: 3,
      });
      fabricCanvasRef.current.add(line);
      fabricCanvasRef.current.setActiveObject(line);
    }
  };

  const deleteSelected = () => {
    if (fabricCanvasRef.current) {
      const activeObject = fabricCanvasRef.current.getActiveObject();
      if (activeObject) {
        fabricCanvasRef.current.remove(activeObject);
      }
    }
  };

  const clearCanvas = () => {
    if (fabricCanvasRef.current) {
      fabricCanvasRef.current.clear();
      fabricCanvasRef.current.backgroundColor = "#ffffff";
      fabricCanvasRef.current.renderAll();
      saveCanvasState();
    }
  };

  const undo = () => {
    if (historyIndex > 0) {
      loadCanvasState(historyIndex - 1);
    }
  };

  const redo = () => {
    if (historyIndex < canvasHistory.length - 1) {
      loadCanvasState(historyIndex + 1);
    }
  };

  const loadCanvasState = (index: number) => {
    if (fabricCanvasRef.current && canvasHistory[index]) {
      const json = JSON.parse(canvasHistory[index]);
      fabricCanvasRef.current.loadFromJSON(json, () => {
        fabricCanvasRef.current?.renderAll();
      });
      setHistoryIndex(index);
    }
  };

  const exportCanvas = () => {
    if (fabricCanvasRef.current) {
      const dataURL = fabricCanvasRef.current.toDataURL({
        format: "png",
        quality: 1,
      });
      const link = document.createElement("a");
      link.download = "canvas-export.png";
      link.href = dataURL;
      link.click();
    }
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="card"
      >
        <h1 className="text-3xl font-bold text-gray-900 mb-6">
          Canvas 画板编辑器
        </h1>

        {/* 工具栏 */}
        <div className="flex flex-wrap gap-2 mb-6 p-4 bg-gray-50 rounded-lg">
          <Button
            variant={selectedTool === "select" ? "primary" : "secondary"}
            size="sm"
            onClick={() => setSelectedTool("select")}
          >
            选择
          </Button>
          <Button
            variant={selectedTool === "rect" ? "primary" : "secondary"}
            size="sm"
            onClick={() => {
              setSelectedTool("rect");
              addRectangle();
            }}
          >
            矩形
          </Button>
          <Button
            variant={selectedTool === "circle" ? "primary" : "secondary"}
            size="sm"
            onClick={() => {
              setSelectedTool("circle");
              addCircle();
            }}
          >
            圆形
          </Button>
          <Button
            variant={selectedTool === "text" ? "primary" : "secondary"}
            size="sm"
            onClick={() => {
              setSelectedTool("text");
              addText();
            }}
          >
            文字
          </Button>
          <Button
            variant={selectedTool === "line" ? "primary" : "secondary"}
            size="sm"
            onClick={() => {
              setSelectedTool("line");
              addLine();
            }}
          >
            直线
          </Button>

          <div className="border-l border-gray-300 mx-2" />

          <Button variant="secondary" size="sm" onClick={deleteSelected}>
            删除选中
          </Button>
          <Button variant="secondary" size="sm" onClick={clearCanvas}>
            清空画布
          </Button>
          <Button variant="secondary" size="sm" onClick={undo}>
            撤销
          </Button>
          <Button variant="secondary" size="sm" onClick={redo}>
            重做
          </Button>
          <Button variant="secondary" size="sm" onClick={exportCanvas}>
            导出图片
          </Button>
        </div>

        {/* Canvas 画布 */}
        <div className="flex justify-center">
          <canvas
            ref={canvasRef}
            className="border border-gray-300 rounded-lg shadow-sm"
          />
        </div>
      </motion.div>
    </div>
  );
};

export default CanvasEditor;
```

### 7. 创建 Radix UI 演示组件

创建 `src/components/RadixUIDemo.tsx`：

```typescript
"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import * as Dialog from "@radix-ui/react-dialog";
import * as DropdownMenu from "@radix-ui/react-dropdown-menu";
import * as Tabs from "@radix-ui/react-tabs";
import * as Toast from "@radix-ui/react-toast";
import * as Tooltip from "@radix-ui/react-tooltip";
import { Button } from "@/components/ui/Button";

const RadixUIDemo: React.FC = () => {
  const [toastOpen, setToastOpen] = useState(false);
  const [dialogOpen, setDialogOpen] = useState(false);

  return (
    <div className="max-w-4xl mx-auto p-6">
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="card"
      >
        <h1 className="text-3xl font-bold text-gray-900 mb-6">
          Radix UI 组件演示
        </h1>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Dialog 对话框 */}
          <div className="card">
            <h2 className="text-xl font-semibold mb-4">Dialog 对话框</h2>
            <Dialog.Root open={dialogOpen} onOpenChange={setDialogOpen}>
              <Dialog.Trigger asChild>
                <Button>打开对话框</Button>
              </Dialog.Trigger>
              <Dialog.Portal>
                <Dialog.Overlay className="fixed inset-0 bg-black/50 backdrop-blur-sm" />
                <Dialog.Content className="fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 bg-white rounded-lg p-6 shadow-xl max-w-md w-full mx-4">
                  <Dialog.Title className="text-lg font-semibold mb-2">
                    对话框标题
                  </Dialog.Title>
                  <Dialog.Description className="text-gray-600 mb-4">
                    这是一个使用 Radix UI Dialog 组件创建的对话框。
                  </Dialog.Description>
                  <div className="flex justify-end gap-2">
                    <Button
                      variant="secondary"
                      onClick={() => setDialogOpen(false)}
                    >
                      取消
                    </Button>
                    <Button onClick={() => setToastOpen(true)}>确认</Button>
                  </div>
                  <Dialog.Close asChild>
                    <button className="absolute top-4 right-4 text-gray-400 hover:text-gray-600">
                      ✕
                    </button>
                  </Dialog.Close>
                </Dialog.Content>
              </Dialog.Portal>
            </Dialog.Root>
          </div>

          {/* Dropdown Menu 下拉菜单 */}
          <div className="card">
            <h2 className="text-xl font-semibold mb-4">
              Dropdown Menu 下拉菜单
            </h2>
            <DropdownMenu.Root>
              <DropdownMenu.Trigger asChild>
                <Button variant="outline">打开菜单</Button>
              </DropdownMenu.Trigger>
              <DropdownMenu.Portal>
                <DropdownMenu.Content className="min-w-[200px] bg-white rounded-lg shadow-lg border border-gray-200 p-1">
                  <DropdownMenu.Item className="flex items-center px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded cursor-pointer">
                    编辑
                  </DropdownMenu.Item>
                  <DropdownMenu.Item className="flex items-center px-3 py-2 text-sm text-gray-700 hover:bg-gray-100 rounded cursor-pointer">
                    复制
                  </DropdownMenu.Item>
                  <DropdownMenu.Separator className="h-px bg-gray-200 my-1" />
                  <DropdownMenu.Item className="flex items-center px-3 py-2 text-sm text-red-600 hover:bg-red-50 rounded cursor-pointer">
                    删除
                  </DropdownMenu.Item>
                </DropdownMenu.Content>
              </DropdownMenu.Portal>
            </DropdownMenu.Root>
          </div>

          {/* Tabs 标签页 */}
          <div className="card">
            <h2 className="text-xl font-semibold mb-4">Tabs 标签页</h2>
            <Tabs.Root defaultValue="tab1" className="w-full">
              <Tabs.List className="flex border-b border-gray-200">
                <Tabs.Trigger
                  value="tab1"
                  className="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 border-b-2 border-transparent hover:border-gray-300 data-[state=active]:border-primary-500 data-[state=active]:text-primary-600"
                >
                  标签一
                </Tabs.Trigger>
                <Tabs.Trigger
                  value="tab2"
                  className="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 border-b-2 border-transparent hover:border-gray-300 data-[state=active]:border-primary-500 data-[state=active]:text-primary-600"
                >
                  标签二
                </Tabs.Trigger>
                <Tabs.Trigger
                  value="tab3"
                  className="px-4 py-2 text-sm font-medium text-gray-600 hover:text-gray-900 border-b-2 border-transparent hover:border-gray-300 data-[state=active]:border-primary-500 data-[state=active]:text-primary-600"
                >
                  标签三
                </Tabs.Trigger>
              </Tabs.List>
              <Tabs.Content value="tab1" className="mt-4">
                <p className="text-gray-600">这是第一个标签页的内容。</p>
              </Tabs.Content>
              <Tabs.Content value="tab2" className="mt-4">
                <p className="text-gray-600">这是第二个标签页的内容。</p>
              </Tabs.Content>
              <Tabs.Content value="tab3" className="mt-4">
                <p className="text-gray-600">这是第三个标签页的内容。</p>
              </Tabs.Content>
            </Tabs.Root>
          </div>

          {/* Tooltip 工具提示 */}
          <div className="card">
            <h2 className="text-xl font-semibold mb-4">Tooltip 工具提示</h2>
            <Tooltip.Provider>
              <Tooltip.Root>
                <Tooltip.Trigger asChild>
                  <Button>悬停查看提示</Button>
                </Tooltip.Trigger>
                <Tooltip.Portal>
                  <Tooltip.Content
                    className="bg-gray-900 text-white px-3 py-2 rounded-lg text-sm shadow-lg"
                    sideOffset={5}
                  >
                    这是一个工具提示
                    <Tooltip.Arrow className="fill-gray-900" />
                  </Tooltip.Content>
                </Tooltip.Portal>
              </Tooltip.Root>
            </Tooltip.Provider>
          </div>
        </div>

        {/* Toast 通知 */}
        <Toast.Provider>
          <Toast.Root
            className="bg-white border border-gray-200 rounded-lg shadow-lg p-4 flex items-start gap-3"
            open={toastOpen}
            onOpenChange={setToastOpen}
          >
            <div className="flex-1">
              <Toast.Title className="font-medium text-gray-900">
                操作成功
              </Toast.Title>
              <Toast.Description className="text-sm text-gray-600 mt-1">
                您的操作已成功完成。
              </Toast.Description>
            </div>
            <Toast.Close className="text-gray-400 hover:text-gray-600">
              ✕
            </Toast.Close>
          </Toast.Root>
          <Toast.Viewport className="fixed bottom-4 right-4" />
        </Toast.Provider>
      </motion.div>
    </div>
  );
};

export default RadixUIDemo;
```

### 8. 创建主页面

更新 `src/app/page.tsx`：

```typescript
"use client";

import React, { useState } from "react";
import { motion } from "framer-motion";
import { useThemeStore } from "@/store/themeStore";
import TodoList from "@/components/TodoList";
import CanvasEditor from "@/components/CanvasEditor";
import RadixUIDemo from "@/components/RadixUIDemo";
import { Button } from "@/components/ui/Button";

type TabType = "todo" | "canvas" | "radix" | "about";

const HomePage: React.FC = () => {
  const [activeTab, setActiveTab] = useState<TabType>("todo");
  const { theme, toggleTheme } = useThemeStore();

  const tabs = [
    { id: "todo" as TabType, label: "待办事项", icon: "📝" },
    { id: "canvas" as TabType, label: "Canvas 画板", icon: "🎨" },
    { id: "radix" as TabType, label: "Radix UI", icon: "🧩" },
    { id: "about" as TabType, label: "关于项目", icon: "ℹ️" },
  ];

  const renderContent = () => {
    switch (activeTab) {
      case "todo":
        return <TodoList />;
      case "canvas":
        return <CanvasEditor />;
      case "radix":
        return <RadixUIDemo />;
      case "about":
        return (
          <div className="max-w-4xl mx-auto p-6">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="card"
            >
              <h1 className="text-3xl font-bold text-gray-900 mb-6">
                关于项目
              </h1>

              <div className="prose prose-lg max-w-none">
                <h2 className="text-2xl font-semibold mb-4">技术栈</h2>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4 mb-6">
                  <div className="p-4 bg-blue-50 rounded-lg">
                    <h3 className="font-semibold text-blue-900 mb-2">
                      前端框架
                    </h3>
                    <ul className="text-blue-800 space-y-1">
                      <li>• Next.js 14 (App Router)</li>
                      <li>• TypeScript 5.3</li>
                      <li>• React 18.2</li>
                    </ul>
                  </div>
                  <div className="p-4 bg-green-50 rounded-lg">
                    <h3 className="font-semibold text-green-900 mb-2">
                      样式与动画
                    </h3>
                    <ul className="text-green-800 space-y-1">
                      <li>• Tailwind CSS 3.4</li>
                      <li>• Framer Motion</li>
                      <li>• CSS 动画</li>
                    </ul>
                  </div>
                  <div className="p-4 bg-purple-50 rounded-lg">
                    <h3 className="font-semibold text-purple-900 mb-2">
                      状态管理
                    </h3>
                    <ul className="text-purple-800 space-y-1">
                      <li>• Zustand</li>
                      <li>• React Hooks</li>
                    </ul>
                  </div>
                  <div className="p-4 bg-orange-50 rounded-lg">
                    <h3 className="font-semibold text-orange-900 mb-2">
                      UI 组件
                    </h3>
                    <ul className="text-orange-800 space-y-1">
                      <li>• Radix UI</li>
                      <li>• Headless UI</li>
                      <li>• 自定义组件</li>
                    </ul>
                  </div>
                </div>

                <h2 className="text-2xl font-semibold mb-4">功能模块</h2>
                <div className="space-y-4">
                  <div className="p-4 border border-gray-200 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">
                      📝 待办事项
                    </h3>
                    <p className="text-gray-600">
                      使用 Zustand
                      进行状态管理，支持添加、编辑、删除、标记完成等操作。 包含
                      Framer Motion 动画效果和响应式设计。
                    </p>
                  </div>

                  <div className="p-4 border border-gray-200 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">
                      🎨 Canvas 画板
                    </h3>
                    <p className="text-gray-600">
                      基于 Fabric.js 的 Canvas
                      编辑器，支持绘制矩形、圆形、文字、直线等图形。
                      包含撤销/重做功能和图片导出功能。
                    </p>
                  </div>

                  <div className="p-4 border border-gray-200 rounded-lg">
                    <h3 className="font-semibold text-gray-900 mb-2">
                      🧩 Radix UI 组件
                    </h3>
                    <p className="text-gray-600">
                      展示 Radix UI
                      的各种组件，包括对话框、下拉菜单、标签页、工具提示、通知等。
                      所有组件都支持无障碍访问。
                    </p>
                  </div>
                </div>

                <h2 className="text-2xl font-semibold mb-4 mt-8">学习要点</h2>
                <ul className="space-y-2 text-gray-700">
                  <li>• Next.js 14 App Router 的使用</li>
                  <li>• TypeScript 类型定义和类型安全</li>
                  <li>• Tailwind CSS 3.x 的响应式设计</li>
                  <li>• Framer Motion 动画库的使用</li>
                  <li>• Zustand 状态管理的最佳实践</li>
                  <li>• Radix UI 和 Headless UI 的无障碍组件</li>
                  <li>• Fabric.js Canvas API 的集成</li>
                  <li>• 现代前端开发工具链的配置</li>
                </ul>
              </div>
            </motion.div>
          </div>
        );
      default:
        return <TodoList />;
    }
  };

  return (
    <div className={`min-h-screen ${theme === "dark" ? "dark" : ""}`}>
      {/* 导航栏 */}
      <nav className="bg-white shadow-sm border-b border-gray-200 sticky top-0 z-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex items-center">
              <h1 className="text-xl font-bold text-gray-900">前端学习项目</h1>
            </div>

            <div className="flex items-center space-x-4">
              <Button
                variant="ghost"
                size="sm"
                onClick={toggleTheme}
                className="flex items-center gap-2"
              >
                {theme === "dark" ? "🌞" : "🌙"}
                {theme === "dark" ? "浅色" : "深色"}
              </Button>
            </div>
          </div>
        </div>
      </nav>

      {/* 标签导航 */}
      <div className="bg-white border-b border-gray-200">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex space-x-8 overflow-x-auto">
            {tabs.map((tab) => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`py-4 px-1 border-b-2 font-medium text-sm transition-colors duration-200 whitespace-nowrap ${
                  activeTab === tab.id
                    ? "border-primary-500 text-primary-600"
                    : "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
                }`}
              >
                <span className="mr-2">{tab.icon}</span>
                {tab.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* 主内容区域 */}
      <main className="bg-gray-50 min-h-screen">{renderContent()}</main>
    </div>
  );
};

export default HomePage;
```

## 🚀 运行项目

### 开发模式

```bash
npm run dev
```

访问 `http://localhost:3000` 查看项目。

### 构建生产版本

```bash
npm run build
```

### 启动生产服务器

```bash
npm run start
```

### 代码检查

```bash
npm run lint
```

### 类型检查

```bash
npm run type-check
```

## 📚 学习要点总结

### Next.js 14

- **App Router**: 新的路由系统，基于文件系统的路由
- **服务端组件**: 默认情况下组件在服务端渲染
- **客户端组件**: 使用 `'use client'` 指令标记
- **布局系统**: 使用 `layout.tsx` 创建共享布局

### TypeScript

- **类型定义**: 为数据结构和组件属性定义类型
- **接口**: 使用 `interface` 定义对象结构
- **泛型**: 创建可重用的类型安全组件
- **类型推断**: TypeScript 自动推断类型

### Tailwind CSS

- **实用类**: 使用预定义的 CSS 类
- **响应式设计**: 使用断点前缀（sm:, md:, lg:）
- **自定义配置**: 在 `tailwind.config.js` 中扩展主题
- **组件类**: 使用 `@apply` 指令创建自定义组件

### Framer Motion

- **基础动画**: `initial`, `animate`, `exit` 属性
- **手势动画**: 支持拖拽、点击等手势
- **页面过渡**: 使用 `AnimatePresence` 组件
- **动画编排**: 使用 `variants` 定义动画序列

### Zustand

- **状态管理**: 轻量级的状态管理库
- **中间件**: 使用 `devtools` 和 `persist` 中间件
- **类型安全**: 完整的 TypeScript 支持
- **开发工具**: 与 Redux DevTools 兼容

### Radix UI

- **无障碍组件**: 符合 WAI-ARIA 标准
- **组合模式**: 使用组合组件创建复杂 UI
- **样式定制**: 完全可定制的样式
- **状态管理**: 内置的状态管理逻辑

### Fabric.js

- **Canvas 操作**: 简化 Canvas API 的使用
- **图形绘制**: 支持各种几何图形和文字
- **事件处理**: 内置的事件系统
- **序列化**: 支持画布状态的保存和恢复

## 🔧 开发工具推荐

### VS Code 扩展

- **TypeScript Importer**: 自动导入 TypeScript 模块
- **Tailwind CSS IntelliSense**: Tailwind CSS 智能提示
- **ES7+ React/Redux/React-Native snippets**: React 代码片段
- **Prettier - Code formatter**: 代码格式化
- **ESLint**: 代码质量检查

### 浏览器开发工具

- **React Developer Tools**: React 组件调试
- **Redux DevTools**: 状态管理调试（支持 Zustand）

## 📖 参考资料

- [Next.js 官方文档](https://nextjs.org/docs)
- [TypeScript 官方文档](https://www.typescriptlang.org/docs)
- [Tailwind CSS 官方文档](https://tailwindcss.com/docs)
- [Framer Motion 官方文档](https://www.framer.com/motion/)
- [Zustand 官方文档](https://github.com/pmndrs/zustand)
- [Radix UI 官方文档](https://www.radix-ui.com/)
- [Fabric.js 官方文档](http://fabricjs.com/)

## 🎯 下一步学习

完成这个项目后，你可以继续学习：

1. **高级 React 模式**: 自定义 Hooks、Context API、性能优化
2. **状态管理进阶**: Redux Toolkit、React Query
3. **测试**: Jest、React Testing Library、Cypress
4. **部署**: Vercel、Netlify、Docker
5. **后端集成**: API 路由、数据库集成、认证
6. **性能优化**: 代码分割、懒加载、缓存策略

通过这个完整的前端学习项目，你已经掌握了现代前端开发的核心技术栈，可以开始构建自己的项目了！
