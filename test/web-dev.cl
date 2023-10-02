#!/usr/bin/env -S clon run

print "starting web dev"

import os="std/os.cl"

// запускаем лайв-сервер который обновляет веб-страницу при изменении файлов
// проект https://github.com/tapio/live-server
os.spawn "npx" "--yes" "live-server" stdio="inherit"
// другой вариант: https://vitejs.dev/guide/
// os.spawn "npx" "--yes" "vite" "--open" stdio="inherit"

// запускаем перекомпиляцию при изменении файлов
//os.spawn "clon" "watch" stdio="inherit"

os.spawn "clon" "compile" stdio="inherit"

import std="std"
react (os.watch "..") { val |
     if (apply {: return val.filename.endsWith(".cl") :}) {
        print "detected change in .cl file -> recompile! " @val
       k: os.spawn "clon" "compile" stdio="inherit"
       exit @k.exitcode
     } else { exit 0 }
}
