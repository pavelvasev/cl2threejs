/* это главный файл проекта. он получает управление при его подключении к другим проектам.
здесь можно указать определения процессов, функций, выполнить разные действия.
введенные определения затем можно использовать в других проектах и на веб-странице.
*/

import std="std" dom="dom" lib3d="lib3d"

obj "box" {
  in { cf&:cell }
  output := dom.element "div" style="display: flex; flex-direction: column; border: 1px solid;" cf=@cf
}

obj "main" {
  
  output := box {
    dom.element "h3" "Scene: "
    
    s: lib3d.scene
    view: lib3d.view style="width: 100%; background: grey; height: 80vh"
    rend: lib3d.render input=@s view_dom=@view.output
    
  }

}