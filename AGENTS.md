# AGENTS.md - AI 助手指南

## 项目概述

这是一个纯静态 PWA 启动器集合，用于把第三方网站做成可安装到手机桌面的入口。

当前架构刻意不使用 iframe 嵌入第三方站点。每个应用目录只提供本地 PWA 安装壳、离线页和目标网站跳转入口。

## 核心结构

```text
pwa-apps/
├── index.html          # 导航主页
├── add-app.sh          # 添加新应用
└── [应用目录]/
    ├── index.html      # PWA 启动页
    ├── manifest.json   # PWA 配置
    ├── sw.js           # Service Worker
    ├── offline.html    # 离线页
    ├── icon.svg        # SVG 图标
    ├── icon-192.png    # 安装图标
    └── icon-512.png    # 安装图标
```

## 添加新应用

运行：

```bash
./add-app.sh <应用名> <网站URL> [图标文字]
```

然后手动在根目录 `index.html` 的应用列表中添加卡片。

## 关键约定

- 不要新增 iframe WebView 壳，第三方站点常通过响应头或 CSP 禁止嵌入。
- 不要在 manifest 中使用远程图标，优先使用本地 `icon.svg`。
- 每个应用都应包含 `index.html`、`manifest.json`、`sw.js`、`offline.html`、`icon.svg`、`icon-192.png`、`icon-512.png`。
- Service Worker 只缓存本应用壳文件，不尝试缓存第三方目标站点。
- manifest 需要声明 PNG 图标；只声明 SVG 会降低 Android Chrome 安装兼容性。

## 常见任务

- 修改应用名称：同步修改应用目录下的 `index.html` 和 `manifest.json`。
- 修改目标 URL：同步修改应用目录下的 `index.html`。
- 修改图标：编辑对应应用目录下的 `icon.svg`。
- 删除应用：删除对应目录，并从根目录 `index.html` 移除卡片。
