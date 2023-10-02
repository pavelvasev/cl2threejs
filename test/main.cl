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

    s: lib3d.scene {
      lib3d.point_light
      lib3d.points positions=[0,0,0, 10,10,10, 0,5,0 ]
    }

    cam: lib3d.camera
    cam_control: lib3d.camera_control camera=@cam.output dom=@view.output
    view: lib3d.view style="width: 100%; background: grey; height: 80vh"
    rend: lib3d.render input=@s.output view_dom=@view.output camera=@cam.output
    
  }

} 