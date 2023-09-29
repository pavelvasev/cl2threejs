#!/usr/bin/env -S clon run

print "starting web dev"

import os="std/os.cl"

// запускаем лайв-сервер который обновляет веб-страницу при изменении файлов
// проект https://github.com/tapio/live-server
os.spawn "npx" "--yes" "live-server" stdio="inherit"
// другой вариант: https://vitejs.dev/guide/
// os.spawn "npx" "--yes" "vite" "--open" stdio="inherit"

// запускаем перекомпиляцию при изменении файлов
os.spawn "clon" "watch" stdio="inherit"
