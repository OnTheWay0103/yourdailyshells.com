# GitSite 路径问题解决总结

## 问题回顾

在 GitHub Pages 部署过程中，遇到了以下问题：

- 静态资源 404 错误
- 同样的路径在`site.yml`中正常，在`README.md`中出错
- 资源访问路径不一致

## 解决过程

1. **问题分析**

   - 分析 GitSite 源码
   - 理解路径处理机制
   - 发现不同文件类型的处理差异

2. **关键发现**

   - 配置文件使用模板变量处理
   - Markdown 文件直接渲染为 HTML
   - 路径处理方式不同导致问题

3. **解决方案**
   - 使用相对路径`./`替代绝对路径
   - 在 JavaScript 中动态处理路径
   - 确保资源路径的一致性

## 关键经验

1. **路径处理机制**

   - 配置文件（如`site.yml`）会被模板引擎处理
   - Markdown 文件（如`README.md`）会被直接渲染为 HTML
   - 同样的路径写法可能产生不同的结果

2. **最佳实践**
   - 在 Markdown 文件中优先使用相对路径
   - 避免使用绝对路径
   - 在 JavaScript 中动态处理路径

## 为什么相对路径更好

- 不依赖部署环境
- 不依赖配置变量
- 更简单可靠
- 更容易维护

## 经验总结

1. **技术层面**

   - 深入理解工具的工作原理
   - 不要被表面现象迷惑
   - 选择最简单的解决方案

2. **实践建议**
   - 优先使用相对路径
   - 保持路径处理的一致性
   - 考虑不同环境的兼容性

## 代码示例

```markdown
<!-- 不推荐：使用绝对路径 -->
<img src="/static/cover/makefile.jpg" />

<!-- 推荐：使用相对路径 -->
<img src="./static/cover/makefile.jpg" />
```

```javascript
// 不推荐：使用硬编码路径
const resp = await fetch("/blogs/all/index.json");

// 推荐：使用动态路径
const resp = await fetch(`${window.location.pathname}/blogs/all/index.json`);
```

## 结论

这个问题的解决过程告诉我们：

1. 遇到问题要深入理解工具的工作原理
2. 不要被表面现象迷惑
3. 有时候最简单的解决方案就是最好的
4. 相对路径是一个通用的最佳实践

## 联系我

<img src="../../../static/cover/my_qrcode.png" style="max-width: 30%; min-width: 10%; height: auto; object-fit: cover; border-radius: 8px;">

<!-- ![我的微信二维码](../../../static/cover/my_qrcode.png){width=20% height=50px} -->
