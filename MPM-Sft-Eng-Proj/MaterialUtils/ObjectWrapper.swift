 import SceneKit
 
 class ObjectWrapper: Object {
    
    var wasClicked = false
    
    init(mesh: MDLObject, material: MaterialWrapper, position: SCNVector3, rotation: SCNVector4) {
        super.init(mesh: mesh, position: position, rotation: rotation)
        node.geometry?.firstMaterial = material.material
        node.geometry?.firstMaterial?.isDoubleSided = true
        
        
        // print("test")
        //print(node.geometry?)
        
        //node.geometry?.firstMaterial?.fresnelExponent = CGFloat(0.8)
        //node.geometry?.firstMaterial?.transparency = 0.5
  
    }
 }
