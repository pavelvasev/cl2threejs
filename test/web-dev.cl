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
// так далеко чтобы видеть изменения в clon
// но вообще надо взять clon-dir и в режиме any работать.
react (os.watch "../../..") { val |
     print "os watch reaction" @val
     return (if (apply {: return val.filename.indexOf(".cl.") >= 0 :}) // результат компиляции
       { return 0 }
     else {
        print "detected change in .cl file -> recompile! " @val
       k: os.spawn "clon" "compile" stdio="inherit"
       return @k.exitcode
     })
}
