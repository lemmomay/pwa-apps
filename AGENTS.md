# AGENTS.md - AI 助手指南

本文件帮助 AI 助手（如 Copilot、Cursor、Windsurf 等）快速理解项目结构和工作流程。

## 项目概述

这是一个 PWA 应用集合仓库，用于将第三方网站打包成 PWA 安装到手机桌面。

## 核心架构

```
pwa-apps/
├── index.html          # 导航主页（展示所有应用）
├── generate-icons.html # 图标生成器工具
├── add-app.sh          # 添加新应用的脚本
└── [网站域名]/         # 每个应用独立目录
    ├── index.html      # PWA 入口（iframe 嵌入）
    ├── manifest.json   # PWA 配置
    ├── sw.js           # Service Worker
    └── icon-*.png      # 应用图标
```

## 添加新应用的步骤

1. **运行脚本**：
   ```bash
   ./add-app.sh <应用名> <网站URL> [图标文字]
   ```

2. **生成图标**：
   - 打开 `generate-icons.html`
   - 输入图标文字
   - 保存 PNG 到应用目录

3. **更新导航页**：
   在 `index.html` 的 `.apps-grid` 中添加：
   ```html
   <a href="./新应用名/" class="app-card">
       <div class="app-icon">图标</div>
       <div class="app-name">应用名</div>
       <div class="app-url">网站域名</div>
   </a>
   ```

## 关键文件说明

### manifest.json
- `name`: 应用全名
- `short_name`: 桌面显示名称
- `display: "standalone"`: 全屏无地址栏
- `icons`: 应用图标数组

### index.html（应用入口）
- 使用 iframe 嵌入目标网站
- 包含加载动画
- 设置 `viewport-fit=cover` 适配刘海屏

### sw.js
- Service Worker 缓存静态资源
- 离线时仍可打开应用

## 部署

推送到 GitHub 后，在仓库 Settings → Pages 启用 GitHub Pages。

## 已知限制

- 某些网站阻止 iframe 嵌入（X-Frame-Options）
- iOS Safari PWA 支持有限

## 常见任务

**修改应用图标**：编辑 `generate-icons.html` 中的颜色值

**修改主题色**：编辑 `manifest.json` 和 `index.html` 中的 `theme_color`

**删除应用**：删除对应目录 + 从 `index.html` 移除卡片