# PWA Apps Collection

个人 PWA 启动器集合，用于把常用第三方网站做成可安装到手机桌面的入口。

这个项目现在采用“安装壳 + 跳转”的模式：PWA 页面只负责安装、桌面启动、离线提示和打开目标站点，不再尝试用 iframe 嵌入第三方网站。这样更稳定，也避开 `X-Frame-Options`、`Content-Security-Policy`、跨域导航控制等限制。

## 目录结构

```text
pwa-apps/
├── index.html              # 导航主页
├── .nojekyll               # GitHub Pages 配置
├── add-app.sh              # 新增应用脚本
├── README.md
├── hanime1.me/
│   ├── index.html          # PWA 启动页
│   ├── manifest.json       # PWA manifest
│   ├── sw.js               # Service Worker
│   ├── offline.html        # 离线页
│   ├── icon.svg            # SVG 图标
│   ├── icon-192.png        # Android/Chrome 安装图标
│   └── icon-512.png        # Android/Chrome 安装图标
└── xyz.incudal.com/
    ├── index.html
    ├── manifest.json
    ├── sw.js
    ├── offline.html
    ├── icon.svg
    ├── icon-192.png
    └── icon-512.png
```

## 使用方式

1. 部署到 GitHub Pages。
2. 在手机浏览器打开导航页或某个应用页。
3. 通过浏览器菜单选择“添加到主屏幕”或“安装应用”。
4. 从桌面图标启动后，点击“打开目标网站”进入网站。

说明：Android Chrome 通常需要页面加载完成并成功注册 Service Worker 后才会出现安装项。首次打开如果菜单里没有“安装应用”，刷新一次应用页再看浏览器菜单。

## 添加新应用

```bash
./add-app.sh <应用名称> <网站URL> [图标文字]
```

示例：

```bash
./add-app.sh youtube https://youtube.com Y
./add-app.sh bilibili https://bilibili.com B
```

脚本会创建：

- `index.html`
- `manifest.json`
- `sw.js`
- `offline.html`
- `icon.svg`
- `icon-192.png`
- `icon-512.png`

脚本不会自动修改主页。创建后需要在根目录 `index.html` 的应用列表中添加一张卡片。

## 技术说明

核心文件：

- `manifest.json`：定义应用名称、启动 URL、显示模式、主题色和本地图标。
- `sw.js`：缓存 PWA 启动壳，让应用页离线时仍可打开。
- `offline.html`：网络不可用时的本地提示页。
- `index.html`：安装入口和目标网站跳转入口。
- `icon-192.png` / `icon-512.png`：提升 Android Chrome 安装兼容性。

缓存策略：

- 预缓存当前应用的静态壳文件。
- 导航请求优先走网络，失败时返回 `offline.html`。
- 同源静态资源按需缓存。
- 激活新 Service Worker 时清理旧版本缓存。

## 重要限制

- 这个项目不能绕过第三方网站的登录、地区、内容策略或浏览器限制。
- 目标网站本身需要网络，离线时只能打开本地启动壳和离线页。
- 安装后的 PWA scope 仍属于 GitHub Pages，进入第三方网站会离开本地 scope；这是浏览器安全模型决定的。
- iOS Safari 的 PWA 支持仍有限，安装入口通常在分享菜单里。

## 部署

推送到 GitHub 后，在仓库 Settings → Pages 中启用 GitHub Pages，选择对应分支和根目录。

## License

MIT
