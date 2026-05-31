#!/bin/bash

# 添加新 PWA 应用的脚本
# 用法: ./add-app.sh <app-name> <website-url> [icon-text]

if [ $# -lt 2 ]; then
    echo "用法: $0 <应用名称> <网站URL> [图标文字]"
    echo "示例: $0 youtube https://youtube.com YT"
    exit 1
fi

APP_NAME="$1"
WEBSITE_URL="$2"
ICON_TEXT="${3:-${APP_NAME:0:1}}"
APP_DIR="$APP_NAME"

# 从URL提取域名
DOMAIN=$(echo "$WEBSITE_URL" | sed -E 's|^https?://||;s|/.*||')

# 检查目录是否已存在
if [ -d "$APP_DIR" ]; then
    echo "错误: 目录 '$APP_DIR' 已存在"
    exit 1
fi

echo "创建 PWA 应用: $APP_NAME"
echo "网站 URL: $WEBSITE_URL"
echo "域名: $DOMAIN"
echo "图标文字: $ICON_TEXT"

# 创建目录
mkdir -p "$APP_DIR"

# 创建 index.html（跳转模式）
cat > "$APP_DIR/index.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="theme-color" content="#1a1a2e">
    <title>APPNAME_PLACEHOLDER</title>
    <link rel="manifest" href="manifest.json">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body {
            width: 100%;
            height: 100%;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #1a1a2e;
        }
        .container {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 20px;
            text-align: center;
        }
        .app-icon {
            width: 100px;
            height: 100px;
            border-radius: 22px;
            margin-bottom: 24px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            background: #fff;
            object-fit: contain;
        }
        .app-name {
            font-size: 28px;
            font-weight: 700;
            color: #fff;
            margin-bottom: 8px;
        }
        .app-url {
            font-size: 14px;
            color: rgba(255,255,255,0.5);
            margin-bottom: 40px;
        }
        .btn-group {
            display: flex;
            flex-direction: column;
            gap: 16px;
            width: 100%;
            max-width: 300px;
        }
        .btn {
            padding: 16px 32px;
            border: none;
            border-radius: 50px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
        }
        .btn:active { transform: scale(0.98); }
        .btn-install {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        .btn-open {
            background: rgba(255,255,255,0.1);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .btn-icon { font-size: 20px; }
        .hint {
            margin-top: 30px;
            padding: 16px;
            background: rgba(255,255,255,0.05);
            border-radius: 12px;
            max-width: 320px;
        }
        .hint-title {
            font-size: 14px;
            font-weight: 600;
            color: #667eea;
            margin-bottom: 8px;
        }
        .hint-text {
            font-size: 13px;
            color: rgba(255,255,255,0.6);
            line-height: 1.6;
        }
        .installed-badge {
            display: none;
            padding: 8px 16px;
            background: rgba(76, 175, 80, 0.2);
            border: 1px solid rgba(76, 175, 80, 0.3);
            border-radius: 20px;
            color: #4CAF50;
            font-size: 13px;
            margin-bottom: 20px;
        }
        .installed-badge.show {
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="installed-badge" id="installedBadge">
            <span>✓</span> 已安装为 PWA
        </div>
        
        <img class="app-icon" id="appIcon" src="" alt="icon">
        <div class="app-name">APPNAME_PLACEHOLDER</div>
        <div class="app-url">DOMAIN_PLACEHOLDER</div>
        
        <div class="btn-group">
            <button class="btn btn-install" id="installBtn" onclick="installPWA()">
                <span class="btn-icon">📲</span>
                安装到桌面
            </button>
            <button class="btn btn-open" onclick="openSite()">
                <span class="btn-icon">🌐</span>
                直接打开网站
            </button>
        </div>
        
        <div class="hint">
            <div class="hint-title">💡 为什么要安装？</div>
            <div class="hint-text">
                安装后可获得：<br>
                • 桌面图标，一键启动<br>
                • 全屏体验，无地址栏<br>
                • 更快的加载速度
            </div>
        </div>
    </div>

    <script>
        const SITE_URL = 'WEBSITEURL_PLACEHOLDER';
        const SITE_DOMAIN = 'DOMAIN_PLACEHOLDER';
        
        function loadFavicon() {
            const icon = document.getElementById('appIcon');
            icon.src = `https://www.google.com/s2/favicons?domain=${SITE_DOMAIN}&sz=128`;
            icon.onerror = function() {
                this.src = `https://${SITE_DOMAIN}/favicon.ico`;
                this.onerror = function() { this.style.display = 'none'; };
            };
        }
        
        function checkInstalled() {
            const isStandalone = window.matchMedia('(display-mode: standalone)').matches 
                || window.navigator.standalone === true;
            if (isStandalone) {
                document.getElementById('installedBadge').classList.add('show');
                document.getElementById('installBtn').style.display = 'none';
                setTimeout(() => window.location.href = SITE_URL, 500);
            }
        }
        
        let deferredPrompt = null;
        window.addEventListener('beforeinstallprompt', (e) => {
            e.preventDefault();
            deferredPrompt = e;
        });
        
        async function installPWA() {
            if (deferredPrompt) {
                deferredPrompt.prompt();
                const { outcome } = await deferredPrompt.userChoice;
                if (outcome === 'accepted') window.location.href = SITE_URL;
                deferredPrompt = null;
            } else {
                showInstallGuide();
            }
        }
        
        function showInstallGuide() {
            const isIOS = /iPad|iPhone|iPod/.test(navigator.userAgent);
            let guide = isIOS 
                ? `iOS 安装步骤：\n1. 点击底部「分享」按钮 ⬆️\n2. 向下滑动找到「添加到主屏幕」\n3. 点击「添加」完成安装`
                : `安装步骤：\n1. 点击浏览器菜单 ⋮\n2. 选择「安装应用」或「添加到桌面」\n3. 确认安装`;
            alert(guide);
        }
        
        function openSite() {
            window.location.href = SITE_URL;
        }
        
        loadFavicon();
        checkInstalled();
    </script>
</body>
</html>
HTMLEOF

# 替换占位符
sed -i "s|APPNAME_PLACEHOLDER|${APP_NAME}|g" "$APP_DIR/index.html"
sed -i "s|WEBSITEURL_PLACEHOLDER|${WEBSITE_URL}|g" "$APP_DIR/index.html"
sed -i "s|DOMAIN_PLACEHOLDER|${DOMAIN}|g" "$APP_DIR/index.html"

# 创建 manifest.json
cat > "$APP_DIR/manifest.json" << EOF
{
    "name": "${APP_NAME}",
    "short_name": "${APP_NAME}",
    "description": "${APP_NAME} - ${DOMAIN}",
    "start_url": "./",
    "scope": "./",
    "display": "standalone",
    "orientation": "any",
    "background_color": "#1a1a2e",
    "theme_color": "#1a1a2e",
    "icons": [
        {
            "src": "https://www.google.com/s2/favicons?domain=${DOMAIN}&sz=192",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "any"
        },
        {
            "src": "https://www.google.com/s2/favicons?domain=${DOMAIN}&sz=512",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "any"
        }
    ],
    "categories": ["entertainment"],
    "lang": "zh-CN",
    "prefer_related_applications": false
}
EOF

echo ""
echo "✅ PWA 应用创建成功!"
echo ""
echo "文件已创建:"
ls -la "$APP_DIR/"