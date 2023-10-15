import THREE="js:three" 
       dom="dom"
       CONTROLS="js:three/addons/controls/OrbitControls.js"

/*
import THREE="https://unpkg.com/three@0.157.0/build/three.module.js" 
       dom="dom"
       CONTROLS="https://unpkg.com/three@0.157.0/examples/jsm/controls/OrbitControls.js"
*/       

paste "
function somethingToColor( theColorData )
  {
    return theColorData?.length >= 3 ? new THREE.Color( theColorData[0], theColorData[1], theColorData[2] ) : new THREE.Color(theColorData);
  }
"

/* вопрос апи - что потребляют сущности на вход. объекты threejs или сущности.
   рацио наблюдается и в том и в другом случае.
   в случае threejs-объектов - что можно свободно ими пользоваться.
   в случае lib3d-объектов - логическая замкнутость + возможность доступа к их каналам.
*/

mixin "tree_node" {

  obj "element" {
    in {
        tag: cell "Object3D" // todo: param
        // это cl-объект с output в котором dom
        rest*: cell // todo: тоже бы param?
        position: cell
        cf&: cell // дети
    }
    
    output: cell // threejs object3d 
    apply_children @cf

    /*
        init {:
          self.is_lib3d_element = true
        :}
    */

    react (list @rest @tag) {: vals|
      if (self.output.is_set)
        console.warn("lib3d element: already constructed",vals)
      else {
        let tag = self.tag.get()
        console.log("using tag=",tag)
        self.output.set( new THREE[ tag ]( ...self.rest.get() ) )
      }
    :}

    react (list @output @position) {: 
      self.output.get().position.set( ...self.position.get() )
    :}

      func "sync_children" {: children |
          //console.log("sync_children", self+'')
          let parent = self
          let parent_obj = parent.output.get()        
          for (let child_obj of children) {
              if (!(child_obj instanceof THREE.Object3D)) continue
              parent_obj.add( child_obj )
          }
      :}

      react @xx.output @sync_children
      xx: xtract @child_elem_outputs
      //react @child_elem_outputs { v| print "oooxxx=" @v }

      child_elem_outputs := apply {: children |
          let res = []
          for (let ch of children) {
              // решено убрать т.к. там и так потом проверка есть.
              // а писать ради этого is_lib3d_element..
              // хотя можно и миксинами теперь. ну ладно, уберу пока.
              // if (!ch.is_lib3d_element) continue              
              res.push( ch.output )
          }
          return res
        :} @self.children
  }

  obj "point_light" {
    in {
      position: cell
      cf&: cell
    }
    output := element "PointLight" 0xffffff 1.5 position=@position cf=@cf
    /*init {:
      self.is_lib3d_element = true  
    :}*/  
  }

  obj "scene" {
    in {
      cf&: cell
    }
    output := element "Scene" cf=@cf
  }

  obj "view" {
    in {
      style: cell
    }
    output := dom.element "canvas" style=@style
  }

} // mixin "tree_node"

obj "render" {
  in {
    input: cell  // сцена которую рисовать
    view_dom: cell   // объект dom куды рисовать. или dom или view?
    camera: cell // камера которой рисовать    
    subrenderers: cell
  }

  renderer: cell
  canvas: cell
  private_camera: cell
  installed_w: cell 1 
  installed_h: cell 1

  react @camera {: cam |
    // внешняя камера рулит встроенной
    if (!private_camera.is_set)
      console.error("lib3d render: private_camera still not set!")
    cam.add( private_camera.get() );
  :}

  react @view_dom {: dom |
    if (self.renderer.is_set)
      self.renderer.get().dispose()

    let r = new THREE.WebGLRenderer( 
        {//canvas: dom, 
         preserveDrawingBuffer : true // надо для скриншотов
         ,logarithmicDepthBuffer: true  // без этого наши точки глючат.. да и поверхности глючат..
         // Early Fragment Test
        }); // alpha: true

      // надо для renderstats с учетом subrenderers
      r.info.autoReset = false;
      r.autoClear = false;

      dom.appendChild( r.domElement )
      canvas.submit( r.domElement )

    self.renderer.submit( r )
  :}

  func "animate" {:

    requestAnimationFrame( animate );
    //console.log(self.renderer.is_set, self.input.is_set)
    if (!self.renderer.is_set) return; // нечего рисовать то    
    if (!self.input.is_set) return; // нечего рисовать то    

    let renderer = self.renderer.get()
    let scene = self.input.get()
    let cam = self.private_camera.get()
    //let de = self.renderer.get().domElement;
    let de = self.view_dom.get()

    if (de.clientWidth != installed_w.get() || de.clientHeight != installed_h.get()) {
      //console.log("mismatch. client=",de.clientWidth,de.clientHeight)
    //if (Math.abs(de.clientWidth - installed_w) + Math.abs(de.clientHeight-installed_h) > 100) {
      installed_w.set( de.clientWidth );
      installed_h.set( de.clientHeight );

      // вот тут криминал - мы пишем в камеру которую могут использовать и другие рендереры
      // но можно конечно переписывать каждый раз мы не гордые

      if (installed_h.get() > 0) {
        cam.aspect = installed_w.get() / installed_h.get();
        // console.log("updated cam aspect", cam.aspect)
        cam.updateProjectionMatrix();  
      }

      //console.log("renderer setsize",installed_w.get(),installed_h.get())
      renderer.setSize( installed_w.get(),installed_h.get(), false );
      //renderer.setViewport( 0, 0, installed_w.get(),installed_h.get() );

    }  

    cam.updateWorldMatrix(true);

    renderer.info.reset();
    renderer.clear(); // вручную чистим - чтобы subrender-еры не чистили

    //console.log("animate!",cam)

    renderer.render( scene, cam );

    if (self.subrenderers.is_set) {
      for (let r of env.params.subrenderers)
        r.subrender( env.renderer );
    }
      
  :}

  init {:
    self.private_camera.set(
      new THREE.PerspectiveCamera( 75, window.innerWidth / window.innerHeight, 0.01, 10000000 )
    )
    requestAnimationFrame( animate )
  :}

  react @self.release {:
    if (self.renderer.is_set) {
      self.renderer.get().dispose()    
      self.renderer.set( CL2.NOVALUE )
    }
  :}

}

obj "camera" {

  in {
    position: cell [0,0,0]  // положение
    lookat: cell [0,0,0]    // куда смотрит
    theta: 0 // угол поворота
  }

  imixin { tree_node }
  
  output: cell // threejs camera

  init {:
    let width = 100
    let height = 100
    let camin = 0.00001
    self.output.set( new THREE.PerspectiveCamera( 75, width/height, camin, 1000*1000 ))
    //console.log("cam created")
  :}

  react @position {: pos | self.output.get().position.set( ...pos ) :}
  react @lookat {: pos | 
    let camera = self.output.get()
    //console.log("cam use",camera)
    camera.lookAt( new THREE.Vector3( ...pos ) ) 
  :}
}

// todo вопросы.. camera это threejs объект или наш?
// ну и хочется нашему - передавать положение и т.п.
obj "camera_control" {
  in {
    camera: cell // объект threejs
    dom: cell // dom-объект
    type: cell "OrbitControls"
  }

  output: cell

  react (list @camera @dom @type) {:
    let t = self.type.get()

    let camera = self.camera.get()
    
    let cc = new CONTROLS[ t ]( camera, self.dom.get() )

    if (self.output.is_set)
      self.output.get().dispose()

    self.output.set( cc )
    //console.log("control configured",cc,self.dom.get())

    camera.position.set( 0, 20, 100 );
    cc.update();
  :}

}

func "buffer" {: arr items_per_elem |
  return new THREE.BufferAttribute( new Float32Array(arr), items_per_elem || 3 ) 
:}

// вообще говоря надо на вход не позиции брать а буфер
// ну потому что буфер это уже что-то что можно рисовать. и главное использовать в разных графических элементах
obj "points" {
  in {
    position: cell 
    // positions и colors
    // тут бы сделать канал, чтобы ссылку не держать
    // но делая канал мы не получаем уведомления если устанавливается константа
    // следовательно это вопрос к модели так-то. к порядку ее работы.
    positions: channel
    colors: channel
    radiuses: channel
    color: cell 0xffffff
    radius: cell 1
    ch&: cell
  }

  imixin { tree_node }
  output: cell

  init {:
    //self.is_lib3d_element = true
    self.geometry = new THREE.BufferGeometry();
    self.material = new THREE.PointsMaterial( {alphaTest: 0.5} );
    let sceneObject = new THREE.Points( self.geometry, self.material );

    self.output.set( sceneObject )
  :}

  // ну вот и вопрос, это же и линиям надо.. и в element уже есть..
  react (list @output @position) {: 
    self.output.get().position.set( ...self.position.get() )
  :}

  react @positions {: v |
    //console.log("pts positions!",v)
    self.geometry.setAttribute( 'position', v );
    self.geometry.needsUpdate = true;    
  :}
  react @radiuses {: v |
    self.geometry.setAttribute( 'radiuses', v );
    self.geometry.needsUpdate = true;    
  :}  
  react @colors {: v |
    if (v) {
      self.geometry.setAttribute( 'color', v );
      self.material.vertexColors = true;
    } else {
      self.geometry.deleteAttribute( 'color' );
      self.material.vertexColors = false; 
    }
    self.geometry.needsUpdate = true;    
  :}
  react @color {: v |
    //console.log("pts color!",v)
    self.material.color = somethingToColor(v);
    self.material.needsUpdate = true
  :}
  react @radius {: v |
    self.material.size = v;
    self.material.needsUpdate = true
  :}  

  //output := element "Points" @geometry @material position=@position ch=@ch
}

//func "rgb"