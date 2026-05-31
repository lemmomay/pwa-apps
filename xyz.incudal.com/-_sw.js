const CACHE_NAME = 'app-v1';
const OFFLINE_URL = './offline.html';
const PRECACHE_ASSETS = ['./', './index.html', './offline.html', './manifest.json'];

self.addEventListener('install', event => {
    event.waitUntil((async () => {
        const cache = await caches.open(CACHE_NAME);
        await cache.addAll(PRECACHE_ASSETS);
        await self.skipWaiting();
    })());
});

self.addEventListener('activate', event => {
    event.waitUntil((async () => {
        const keys = await caches.keys();
        await Promise.all(keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k)));
        await self.clients.claim();
    })());
});

self.addEventListener('fetch', event => {
    if (event.request.mode === 'navigate') {
        event.respondWith((async () => {
            try { return await fetch(event.request); }
            catch { return (await caches.open(CACHE_NAME)).match(OFFLINE_URL); }
        })());
        return;
    }
    event.respondWith((async () => {
        const cached = await caches.match(event.request);
        if (cached) return cached;
        try {
            const response = await fetch(event.request);
            if (response.ok && event.request.method === 'GET') {
                const cache = await caches.open(CACHE_NAME);
                cache.put(event.request, response.clone());
            }
            return response;
        } catch { return new Response('Network error', { status: 408 }); }
    })());
});