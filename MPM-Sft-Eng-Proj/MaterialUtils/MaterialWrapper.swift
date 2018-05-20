import SceneKit

class MaterialWrapper {
    let material: SCNMaterial
    init(diffuse: Any, roughness: Any, metalness: Any, normal: Any, ambientOcclusion: Any? = nil) {
        material = SCNMaterial()
        material.lightingModel = .phong //.physicallyBased
        material.diffuse.contents = diffuse//diffuse
        //material.roughness.contents = roughness
        //material.metalness.contents = metalness
        //material.normal.contents = normal
        //material.ambientOcclusion.contents = ambientOcclusion
        
        //material.fresnelExponent = CGFloat(500)
        // material.transparency = 0.5
        
    }
}

