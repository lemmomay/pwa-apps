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

# 检查目录是否已存在
if [ -d "$APP_DIR" ]; then
    echo "错误: 目录 '$APP_DIR' 已存在"
    exit 1
fi

echo "创建 PWA 应用: $APP_NAME"
echo "网站 URL: $WEBSITE_URL"
echo "图标文字: $ICON_TEXT"

# 创建目录
mkdir -p "$APP_DIR"

# 创建 index.html
cat > "$APP_DIR/index.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover, user-scalable=no">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="theme-color" content="#1a1a2e">
    <title>${APP_NAME}</title>
    <link rel="manifest" href="manifest.json">
    <link rel="apple-touch-icon" href="icon-192.png">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        html, body {
            width: 100%;
            height: 100%;
            overflow: hidden;
            background: #1a1a2e;
        }
        #loading {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 1000;
            transition: opacity 0.3s;
        }
        #loading.hidden {
            opacity: 0;
            pointer-events: none;
        }
        .loader-icon {
            width: 80px;
            height: 80px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 36px;
            margin-bottom: 20px;
            animation: pulse 2s infinite;
        }
        @keyframes pulse {
            0%, 100% { transform: scale(1); }
            50% { transform: scale(1.05); }
        }
        .loader-text {
            color: #fff;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            font-size: 16px;
            opacity: 0.8;
        }
        .loader-bar {
            width: 200px;
            height: 3px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 2px;
            margin-top: 16px;
            overflow: hidden;
        }
        .loader-bar::after {
            content: '';
            display: block;
            width: 50%;
            height: 100%;
            background: linear-gradient(90deg, #00d2ff, #3a7bd5);
            border-radius: 2px;
            animation: loading 1.5s infinite;
        }
        @keyframes loading {
            0% { transform: translateX(-100%); }
            100% { transform: translateX(300%); }
        }
        #main-frame {
            width: 100%;
            height: 100%;
            border: none;
        }
    </style>
</head>
<body>
    <div id="loading">
        <div class="loader-icon">${ICON_TEXT:0:1}</div>
        <div class="loader-text">正在加载 ${APP_NAME}...</div>
        <div class="loader-bar"></div>
    </div>
    <iframe id="main-frame" src="${WEBSITE_URL}" allow="autoplay; fullscreen; picture-in-picture"></iframe>

    <script>
        const frame = document.getElementById('main-frame');
        const loading = document.getElementById('loading');

        frame.onload = function() {
            setTimeout(() => {
                loading.classList.add('hidden');
                setTimeout(() => loading.remove(), 300);
            }, 500);
        };

        setTimeout(() => {
            if (!loading.classList.contains('hidden')) {
                loading.classList.add('hidden');
                setTimeout(() => loading.remove(), 300);
            }
        }, 10000);
    </script>
</body>
</html>
EOF

# 创建 manifest.json
cat > "$APP_DIR/manifest.json" << EOF
{
    "name": "${APP_NAME}",
    "short_name": "${APP_NAME}",
    "description": "${APP_NAME} - PWA 应用",
    "start_url": "./",
    "display": "standalone",
    "orientation": "any",
    "background_color": "#1a1a2e",
    "theme_color": "#1a1a2e",
    "icons": [
        {
            "src": "icon-192.png",
            "sizes": "192x192",
            "type": "image/png",
            "purpose": "any maskable"
        },
        {
            "src": "icon-512.png",
            "sizes": "512x512",
            "type": "image/png",
            "purpose": "any maskable"
        }
    ],
    "categories": ["entertainment"],
    "lang": "zh-CN",
    "dir": "ltr"
}
EOF

# 创建 service worker
cat > "$APP_DIR/sw.js" << 'EOF'
const CACHE_NAME = 'app-v1';
const STATIC_ASSETS = [
    './',
    './index.html',
    './manifest.json',
    './icon-192.png',
    './icon-512.png'
];

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(STATIC_ASSETS);
        })
    );
    self.skipWaiting();
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames
                    .filter((name) => name !== CACHE_NAME)
                    .map((name) => caches.delete(name))
            );
        })
    );
    self.clients.claim();
});

self.addEventListener('fetch', (event) => {
    if (event.request.url.startsWith(self.location.origin)) {
        event.respondWith(
            caches.match(event.request).then((response) => {
                return response || fetch(event.request).then((fetchResponse) => {
                    return caches.open(CACHE_NAME).then((cache) => {
                        cache.put(event.request, fetchResponse.clone());
                        return fetchResponse;
                    });
                });
            })
        );
    }
});
EOF

# 创建 SVG 图标
cat > "$APP_DIR/icon.svg" << EOF
<svg xmlns="http://www.w3.org/2000/svg" width="512" height="512" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="512" height="512" rx="100" fill="url(#grad)"/>
  <text x="256" y="300" font-family="Arial, sans-serif" font-size="200" font-weight="bold" fill="white" text-anchor="middle">${ICON_TEXT:0:1}</text>
</svg>
EOF

echo ""
echo "✅ PWA 应用创建成功!"
echo ""
echo "下一步:"
echo "1. 使用浏览器打开 generate-icons.html 生成 PNG 图标"
echo "2. 将图标保存到 $APP_DIR/ 目录"
echo "3. 在 index.html 中添加新应用卡片"
echo ""
echo "文件已创建:"
ls -la "$APP_DIR/"