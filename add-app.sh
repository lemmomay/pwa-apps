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

# 创建 index.html（跳转模式）
cat > "$APP_DIR/index.html" << EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
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
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }
        .splash {
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
            transition: opacity 0.5s, transform 0.5s;
        }
        .splash.hide {
            opacity: 0;
            transform: scale(1.1);
        }
        .app-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 48px;
            margin-bottom: 24px;
            box-shadow: 0 20px 40px rgba(102, 126, 234, 0.4);
            animation: float 3s ease-in-out infinite;
        }
        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-10px); }
        }
        .app-name {
            font-size: 28px;
            font-weight: 700;
            color: #fff;
            margin-bottom: 8px;
        }
        .app-desc {
            font-size: 14px;
            color: rgba(255, 255, 255, 0.6);
            margin-bottom: 40px;
        }
        .launch-btn {
            padding: 16px 48px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            border: none;
            border-radius: 50px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            box-shadow: 0 10px 30px rgba(102, 126, 234, 0.4);
        }
        .launch-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 15px 40px rgba(102, 126, 234, 0.5);
        }
        .launch-btn:active {
            transform: translateY(0);
        }
        .countdown {
            margin-top: 20px;
            font-size: 13px;
            color: rgba(255, 255, 255, 0.4);
        }
        .progress-bar {
            position: absolute;
            bottom: 0;
            left: 0;
            height: 3px;
            background: linear-gradient(90deg, #667eea, #764ba2);
            transition: width 0.1s linear;
        }
    </style>
</head>
<body>
    <div class="splash" id="splash">
        <div class="app-icon">${ICON_TEXT:0:1}</div>
        <div class="app-name">${APP_NAME}</div>
        <div class="app-desc">正在启动...</div>
        <button class="launch-btn" onclick="launch()">立即打开</button>
        <div class="countdown" id="countdown">3 秒后自动跳转</div>
        <div class="progress-bar" id="progress"></div>
    </div>

    <script>
        const TARGET_URL = '${WEBSITE_URL}';
        let countdown = 3;
        let launched = false;

        function launch() {
            if (launched) return;
            launched = true;
            
            const splash = document.getElementById('splash');
            splash.classList.add('hide');
            
            setTimeout(() => {
                window.location.href = TARGET_URL;
            }, 500);
        }

        const timer = setInterval(() => {
            countdown--;
            document.getElementById('countdown').textContent = countdown + ' 秒后自动跳转';
            document.getElementById('progress').style.width = ((3 - countdown) / 3 * 100) + '%';
            
            if (countdown <= 0) {
                clearInterval(timer);
                launch();
            }
        }, 1000);
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