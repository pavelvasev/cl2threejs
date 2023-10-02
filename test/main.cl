/* это главный файл проекта. он получает управление при его подключении к другим проектам.
здесь можно указать определения процессов, функций, выполнить разные действия.
введенные определения затем можно использовать в других проектах и на веб-странице.
*/

import std="std" dom="dom" lib3d="lib3d"

obj "box" {
  in { cf&:cell }
  output := dom.element "div" style="display: flex; flex-direction: column; border: 1px solid;" cf=@cf
}

func "makegrid" {: w h |
  let acc = [];
  for (let i=0; i<w; i++)
  for (let j=0; j<h; j++)
    acc.push( i,j,0 )
  return acc
:}

obj "main" {
  
  output := box {
    dom.element "h3" "Scene: "

    s: lib3d.scene {
      lib3d.point_light
      //lib3d.points positions=[0,0,0, 10,10,10, 0,5,0 ] color=[1,0,1]
      p1: lib3d.points color=[1,0,1] positions=(apply @makegrid @w @w)
      lib3d.points [0,0,10] color=[0,1,0] positions=@p1.positions
    }

    //dom.input type="range"
    // идея применения декоратора dom.input! здесь ! это просто визуальная отметка пока-что
    // но в целом.. хотелось бы применять декораторы и к функциям и к объектам. хотя фишка
    // что применять их к конкретным экземплярам - это тоже вариант интересный наверное.

    // ну получается dom.input интереснее тем что он добавит пропертю value и будет ее ловить.
    // это хорошо. но для этого надо тогда - задать передачу rest-значений. хотя бы в рест-значения.

    d1: dom.element "input" type="range" min=0 max=200 //value=10
    //w := react (dom.event @d1.output "input") {: event | console.log("see input",event) :}
    //w := (react (dom.event @d1.output "input") {: event | return event.target.value :}) or 10
    w := 10
    // вот такой вариант но не очень ведь это..
    react (dom.event @d1.output "input") {: event | w.submit( event.target.value ) :}
    print "w=" @w

    cam: lib3d.camera
    cam_control: lib3d.camera_control camera=@cam.output dom=@view.output
    view: lib3d.view style="width: 100%; background: grey; height: 80vh"
    rend: lib3d.render input=@s.output view_dom=@view.output camera=@cam.output
    
  }

} 

