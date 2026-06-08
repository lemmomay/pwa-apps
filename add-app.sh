#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
    printf '用法: %s <应用名称> <网站URL> [图标文字]\n' "$0"
    printf '示例: %s youtube https://youtube.com Y\n' "$0"
    exit 1
fi

APP_NAME="$1"
WEBSITE_URL="$2"
ICON_TEXT="${3:-${APP_NAME:0:1}}"
APP_DIR="$(printf '%s' "$APP_NAME" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-' | sed 's/^-//;s/-$//')"
DOMAIN="$(printf '%s' "$WEBSITE_URL" | sed -E 's|^https?://||;s|/.*||')"
CACHE_ID="$(printf '%s' "$APP_DIR" | tr -cs 'a-z0-9' '-')"

if [ -z "$APP_DIR" ] || [ -z "$DOMAIN" ]; then
    printf '错误: 应用名称或 URL 无效\n' >&2
    exit 1
fi

if [ -d "$APP_DIR" ]; then
    printf "错误: 目录 '%s' 已存在\n" "$APP_DIR" >&2
    exit 1
fi

mkdir -p "$APP_DIR"

cat > "$APP_DIR/index.html" <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
    <meta name="theme-color" content="#0f172a">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="apple-mobile-web-app-title" content="$APP_NAME">
    <meta name="mobile-web-app-capable" content="yes">
    <title>$APP_NAME</title>
    <link rel="manifest" href="manifest.json">
    <link rel="icon" href="icon.svg" type="image/svg+xml">
    <style>
        :root { color-scheme: dark; --bg: #07111f; --card: rgba(255,255,255,.08); --line: rgba(255,255,255,.14); --text: #f8fafc; --muted: #94a3b8; --accent: #38bdf8; }
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: radial-gradient(circle at 80% 8%, rgba(56,189,248,.28), transparent 30rem), var(--bg); color: var(--text); display: grid; place-items: center; padding: max(22px, env(safe-area-inset-top)) 18px max(22px, env(safe-area-inset-bottom)); }
        main { width: min(480px, 100%); }
        .card { border: 1px solid var(--line); border-radius: 32px; padding: 28px; background: linear-gradient(180deg, var(--card), rgba(255,255,255,.045)); box-shadow: 0 28px 90px rgba(0,0,0,.34); }
        .icon { width: 88px; height: 88px; border-radius: 25px; display: grid; place-items: center; background: linear-gradient(135deg, #38bdf8, #818cf8); color: #07111f; font-size: 44px; font-weight: 900; box-shadow: 0 18px 44px rgba(56,189,248,.28); }
        h1 { margin: 24px 0 8px; font-size: 44px; line-height: .95; letter-spacing: -.07em; }
        .domain { color: var(--accent); font-size: 15px; word-break: break-all; }
        p { color: var(--muted); line-height: 1.7; margin: 22px 0 0; }
        .actions { display: grid; gap: 12px; margin-top: 28px; }
        button, a.button { border: 0; border-radius: 18px; padding: 16px 18px; font: inherit; font-weight: 750; text-decoration: none; text-align: center; cursor: pointer; }
        .primary { background: var(--accent); color: #07111f; }
        .secondary { background: rgba(255,255,255,.1); color: var(--text); border: 1px solid var(--line); }
        .install-hint { margin-top: 16px; border-radius: 20px; padding: 15px; border: 1px solid var(--line); background: rgba(255,255,255,.055); color: var(--muted); font-size: 14px; line-height: 1.65; }
        .hidden { display: none; }
        .back { display: inline-block; margin-top: 18px; color: var(--muted); text-decoration: none; font-size: 14px; }
    </style>
</head>
<body>
    <main>
        <section class="card" aria-labelledby="app-title">
            <div class="icon">$ICON_TEXT</div>
            <h1 id="app-title">$APP_NAME</h1>
            <div class="domain">$DOMAIN</div>
            <p>这是一个稳定的 PWA 启动壳。安装后从桌面打开，再进入目标网站；不使用跨域 iframe，也不依赖远程 favicon。</p>
            <div class="actions">
                <button class="primary hidden" id="install-btn" type="button">安装到桌面</button>
                <a class="button secondary" href="$WEBSITE_URL" rel="noopener">打开目标网站</a>
            </div>
            <div class="install-hint" id="hint">如果没有看到安装按钮，请使用浏览器菜单中的“添加到主屏幕”或“安装应用”。</div>
        </section>
        <a class="back" href="../">返回应用列表</a>
    </main>
    <script>
        const targetUrl = '$WEBSITE_URL';
        let deferredPrompt;
        const installButton = document.getElementById('install-btn');
        const hint = document.getElementById('hint');
        const standalone = window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone === true;

        if (standalone) {
            hint.textContent = '已从桌面模式启动，正在进入目标网站。';
            setTimeout(() => { window.location.href = targetUrl; }, 450);
        }

        window.addEventListener('beforeinstallprompt', event => {
            event.preventDefault();
            deferredPrompt = event;
            installButton.classList.remove('hidden');
            hint.textContent = '当前浏览器支持一键安装。安装后可从桌面图标启动。';
        });

        installButton.addEventListener('click', async () => {
            if (!deferredPrompt) return;
            deferredPrompt.prompt();
            await deferredPrompt.userChoice;
            deferredPrompt = undefined;
            installButton.classList.add('hidden');
        });

        if ('serviceWorker' in navigator) {
            window.addEventListener('load', () => navigator.serviceWorker.register('./sw.js').catch(console.warn));
        }
    </script>
</body>
</html>
EOF

cat > "$APP_DIR/manifest.json" <<EOF
{
  "name": "$APP_NAME",
  "short_name": "$APP_NAME",
  "description": "$APP_NAME desktop launcher",
  "start_url": "./",
  "scope": "./",
  "display": "standalone",
  "orientation": "any",
  "background_color": "#07111f",
  "theme_color": "#0f172a",
  "icons": [
    {
      "src": "icon.svg",
      "sizes": "512x512",
      "type": "image/svg+xml",
      "purpose": "any maskable"
    }
  ],
  "categories": ["utilities"],
  "lang": "zh-CN",
  "prefer_related_applications": false
}
EOF

cat > "$APP_DIR/sw.js" <<EOF
const CACHE_NAME = '$CACHE_ID-launcher-v1';
const APP_SHELL = ['./', './index.html', './manifest.json', './icon.svg', './offline.html'];

self.addEventListener('install', event => {
    event.waitUntil((async () => {
        const cache = await caches.open(CACHE_NAME);
        await cache.addAll(APP_SHELL);
        await self.skipWaiting();
    })());
});

self.addEventListener('activate', event => {
    event.waitUntil((async () => {
        const names = await caches.keys();
        await Promise.all(names.filter(name => name !== CACHE_NAME).map(name => caches.delete(name)));
        await self.clients.claim();
    })());
});

self.addEventListener('fetch', event => {
    if (event.request.method !== 'GET') return;

    if (event.request.mode === 'navigate') {
        event.respondWith((async () => {
            try {
                return await fetch(event.request);
            } catch {
                return (await caches.open(CACHE_NAME)).match('./offline.html');
            }
        })());
        return;
    }

    event.respondWith((async () => {
        const cached = await caches.match(event.request);
        if (cached) return cached;
        const response = await fetch(event.request);
        if (response.ok && new URL(event.request.url).origin === self.location.origin) {
            const cache = await caches.open(CACHE_NAME);
            cache.put(event.request, response.clone());
        }
        return response;
    })());
});
EOF

cat > "$APP_DIR/offline.html" <<EOF
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="theme-color" content="#0f172a">
    <title>$APP_NAME 离线</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; min-height: 100vh; display: grid; place-items: center; padding: 24px; font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; background: #07111f; color: #f8fafc; }
        main { width: min(420px, 100%); padding: 28px; border-radius: 28px; border: 1px solid rgba(255,255,255,.14); background: rgba(255,255,255,.08); text-align: center; }
        .mark { width: 72px; height: 72px; margin: 0 auto 20px; border-radius: 22px; display: grid; place-items: center; background: #38bdf8; color: #07111f; font-size: 36px; font-weight: 900; }
        h1 { margin: 0; font-size: 28px; letter-spacing: -.04em; }
        p { color: #94a3b8; line-height: 1.7; }
        button { border: 0; border-radius: 16px; padding: 14px 18px; background: #38bdf8; color: #07111f; font: inherit; font-weight: 750; }
    </style>
</head>
<body>
    <main>
        <div class="mark">!</div>
        <h1>当前离线</h1>
        <p>启动页已缓存，但目标网站需要网络连接。恢复网络后重试。</p>
        <button type="button" onclick="window.location.reload()">重新尝试</button>
    </main>
</body>
</html>
EOF

cat > "$APP_DIR/icon.svg" <<EOF
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
    <rect width="512" height="512" rx="110" fill="#07111f"/>
    <circle cx="376" cy="116" r="160" fill="#38bdf8" opacity="0.25"/>
    <rect x="126" y="92" width="260" height="328" rx="72" fill="#38bdf8"/>
    <text x="256" y="334" text-anchor="middle" font-family="Arial Black, Arial, sans-serif" font-size="250" font-weight="900" fill="#07111f">$ICON_TEXT</text>
</svg>
EOF

printf '已创建 %s\n' "$APP_DIR"
printf '请在 index.html 中添加对应应用卡片。\n'
