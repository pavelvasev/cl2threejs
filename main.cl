import three="https://unpkg.com/three@0.157.0/build/three.module.js" 
       dom="dom"

obj "scene" {
  print "scene"
  
  output: cell // threejs scene
}

obj "view" {
  output := dom.element "canvas"
}

obj "renderer" {
  in {
    view: cell   // объект dom куды рисовать. или dom или view?
    camera: cell // камера которой рисовать
    scene: cell  // сцена которую рисовать
  }
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