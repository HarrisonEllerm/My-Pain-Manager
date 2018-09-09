import SceneKit

class MaterialWrapper {
    let material: SCNMaterial
    init(diffuse: Any, roughness: Any, metalness: Any, normal: Any, ambientOcclusion: Any? = nil) {
        material = SCNMaterial()
        material.lightingModel = .phong
        material.diffuse.contents = diffuse  
    }
}

