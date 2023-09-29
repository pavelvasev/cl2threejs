import three="https://unpkg.com/three@0.157.0/build/three.module.js" 
       dom="dom"

obj "scene" {
  print "scene"
  
  output: cell // threejs scene

  init {:
    self.output.set( new three.Scene() )
  :}
}

obj "view" {
  in {
    style: cell
  }
  output := dom.element "canvas" style=@style
  is_element: cell
}

obj "render" {
  in {
    input: cell  // сцена которую рисовать
    view_dom: cell   // объект dom куды рисовать. или dom или view?
    camera: cell // камера которой рисовать    
  }

  renderer: cell

  react @view_dom
}

obj "camera" {
  print "camera"
  
  output: cell // threejs camera
}

obj "camera_control" {
  in {
    camera: cell
    dom: cell
  }
}

obj "node" {
  print "node"
  
  output: cell // threejs object3d
}