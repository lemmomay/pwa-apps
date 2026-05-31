# PWA Apps Collection

个人 PWA 应用集合，将喜欢的网站打包成 PWA 安装到手机桌面，获得原生应用般的体验。

## 🎯 项目目的

解决第三方网站没有官方 PWA 支持的问题：
- ✅ 安装到手机桌面
- ✅ 全屏体验，无浏览器地址栏
- ✅ 统一管理多个网站 PWA

## 📁 目录结构

```
pwa-apps/
├── index.html              # 导航主页 - 展示所有 PWA 应用
├── .nojekyll               # GitHub Pages 配置（禁用 Jekyll）
├── generate-icons.html     # 图标生成器工具
├── add-app.sh              # 添加新应用的脚本
├── README.md               # 本文件
│
├── hanime1.me/             # 示例：第一个 PWA 应用
│   ├── index.html          # PWA 入口页面（含 iframe 嵌入）
│   ├── manifest.json       # PWA 配置文件
│   ├── sw.js               # Service Worker（缓存策略）
│   ├── icon.svg            # 矢量图标源文件
│   ├── icon-192.png        # 图标 192x192（需生成）
│   └── icon-512.png        # 图标 512x512（需生成）
│
└── [新应用目录]/            # 后续添加的应用...
```

## 🚀 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/YOUR_USERNAME/pwa-apps.git
cd pwa-apps
```

### 2. 生成图标

1. 在浏览器中打开 `generate-icons.html`
2. 输入图标文字（如应用首字母）
3. 点击「生成图标」
4. 右键保存 PNG 图标到对应目录

### 3. 部署到 GitHub Pages

```bash
git add .
git commit -m "Add PWA apps"
git push origin main
```

然后在 GitHub 仓库 Settings → Pages 中启用，选择 `main` 分支。

### 4. 访问和安装

- **导航页**: `https://YOUR_USERNAME.github.io/pwa-apps/`
- **单个应用**: `https://YOUR_USERNAME.github.io/pwa-apps/hanime1.me/`

在手机浏览器中打开，选择「添加到桌面」即可安装。

## 📱 添加新应用

### 方法一：使用脚本（推荐）

```bash
./add-app.sh <应用名称> <网站URL> [图标文字]

# 示例
./add-app.sh youtube https://youtube.com YT
./add-app.sh twitter https://twitter.com X
./add-app.sh bilibili https://bilibili.com B
```

### 方法二：手动创建

1. 复制现有应用目录：
   ```bash
   cp -r hanime1.me/ youtube/
   ```

2. 修改 `youtube/index.html`：
   - 修改 `<title>` 标签
   - 修改 iframe 的 `src` 属性
   - 修改加载提示文字
   - 修改图标文字

3. 修改 `youtube/manifest.json`：
   - 修改 `name` 和 `short_name`
   - 修改 `description`

4. 生成新图标并放入目录

5. 在 `index.html` 中添加新应用卡片：
   ```html
   <a href="./youtube/" class="app-card">
       <div class="app-icon">▶️</div>
       <div class="app-name">YouTube</div>
       <div class="app-url">youtube.com</div>
   </a>
   ```

## 🔧 技术说明

### PWA 核心文件

| 文件 | 作用 |
|------|------|
| `manifest.json` | PWA 配置，定义名称、图标、显示模式等 |
| `sw.js` | Service Worker，处理缓存和离线访问 |
| `index.html` | 入口页面，通过 iframe 嵌入目标网站 |

### 显示模式

- `display: "standalone"` - 全屏显示，无浏览器 UI
- `orientation: "any"` - 支持横竖屏切换
- `theme_color` - 状态栏颜色

### Service Worker 缓存策略

- 静态资源：缓存优先
- 动态内容：网络优先
- 自动清理旧版本缓存

## ⚠️ 注意事项

### iframe 限制

某些网站会通过以下方式阻止被嵌入：
- `X-Frame-Options: DENY` 或 `SAMEORIGIN`
- `Content-Security-Policy` 的 `frame-ancestors` 指令

如果遇到这种情况，iframe 方案将无法使用。

### 浏览器兼容性

| 浏览器 | 添加到桌面 | 全屏体验 |
|--------|-----------|---------|
| Chrome (Android) | ✅ | ✅ |
| Edge (Android) | ✅ | ✅ |
| Safari (iOS) | ✅ | ⚠️ 有限支持 |
| Firefox (Android) | ✅ | ✅ |

### iOS 限制

iOS Safari 对 PWA 的支持有限：
- 不支持完整的 Service Worker
- 添加到桌面后可能仍显示部分浏览器 UI
- 建议使用 Chrome 或 Edge 获得最佳体验

## 🎨 自定义样式

### 修改主题颜色

编辑 `index.html` 和应用的 `manifest.json`：

```json
{
    "background_color": "#1a1a2e",
    "theme_color": "#1a1a2e"
}
```

### 修改图标渐变

编辑 `icon.svg` 或 `generate-icons.html` 中的颜色：

```html
<stop offset="0%" style="stop-color:#667eea" />
<stop offset="100%" style="stop-color:#764ba2" />
```

## 📋 添加应用检查清单

添加新应用时，确保完成以下步骤：

- [ ] 创建应用目录
- [ ] 修改 `index.html` 中的 iframe src
- [ ] 修改 `manifest.json` 中的名称
- [ ] 生成并放入 PNG 图标
- [ ] 在主页 `index.html` 中添加卡片
- [ ] 测试能否正常打开
- [ ] 测试能否正常安装到桌面

## 🔗 相关链接

- [PWA 文档](https://developer.mozilla.org/zh-CN/docs/Web/Progressive_web_apps)
- [GitHub Pages 文档](https://docs.github.com/en/pages)
- [Web App Manifest](https://developer.mozilla.org/zh-CN/docs/Web/Manifest)

## 📄 许可证

MIT License