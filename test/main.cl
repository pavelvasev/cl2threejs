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
      p1: lib3d.points color=[1,0,1] positions=(apply @makegrid @w @d2.value)
      lib3d.points [0,0,10] color=[0,1,0] positions=@p1.positions
    }

    //dom.input type="range"
    // идея применения декоратора dom.input! здесь ! это просто визуальная отметка пока-что
    // но в целом.. хотелось бы применять декораторы и к функциям и к объектам. хотя фишка
    // что применять их к конкретным экземплярам - это тоже вариант интересный наверное.

    // ну получается dom.input интереснее тем что он добавит пропертю value и будет ее ловить.
    // это хорошо. но для этого надо тогда - задать передачу rest-значений. хотя бы в рест-значения.

    dom.element "span" "select w"
    //d1: dom.input "range" min=0 max=200 init_value=10
    d1: dom.input "range" min=0 max=15 init_value=10
    d2: dom.input "range" min=0 max=15 disabled=@do_join
        //init_value=(if @do_join { return @d1.value } else { return 10 })
        init_value=10
    //print "d2.iv=" @d2.init_value
    print "do_join = " @do_join
    do_join := 1 

    fff: if @do_join {
       bind @d1.value @d2.init_value
       //print "bind seems working, @d1.value=" @d1.value
       dom.element "h1" "HOHO"
       //print "HOHO CREATED!!!!!!!!!!!!!!!!!!!!!!!!"
    } else {
      print "do-join do nothing"
    }

    //print "fff tree=" @fff.tree.children "fff=" @fff

    dom.element "label" {
      cb: dom.checkbox init_value=@do_join //checked=true
      bind @cb.value @do_join
      dom.element "span" "объединить"
      //q := @cb.value
      //print "q=" @q
    }

    //dom.input "range"

    //dom.element "input" type="range"
    
    w := @d1.value

    //print "@d1.output" @d1.output
    //d1: dom.element "input" type="range" min=0 max=200 //value=10
    //w := react (dom.event @d1.output "input") {: event | console.log("see input",event) :}
    //w := (react (dom.event @d1.output "input") {: event | return event.target.value :}) or 10

    //w := 10
    // вот такой вариант но не очень ведь это..
    //react (dom.event @d1.output "input") {: event | w.submit( event.target.value ) :}
    //print "w=" @w

    cam: lib3d.camera
    cam_control: lib3d.camera_control camera=@cam.output dom=@view.output
    view: lib3d.view style="width: 100%; background: grey; height: 80vh"
    rend: lib3d.render input=@s.output view_dom=@view.output camera=@cam.output
    
  }

} 

