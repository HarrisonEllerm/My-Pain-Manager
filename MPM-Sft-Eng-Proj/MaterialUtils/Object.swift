  import SceneKit
  
  //A Node which holds A mesh and a position
  class Object {
    let node: SCNNode
    
    init(position: SCNVector3, rotation: SCNVector4) {
        node = SCNNode()
        set(position: position, rotation: rotation)
    }
    
    init(mesh: MDLObject, position: SCNVector3, rotation: SCNVector4) {
        node = SCNNode(mdlObject: mesh)
        set(position: position, rotation: rotation)
    }
    
    private func set(position: SCNVector3, rotation: SCNVector4) {
        node.position = position
        node.rotation = rotation
    }
  }
