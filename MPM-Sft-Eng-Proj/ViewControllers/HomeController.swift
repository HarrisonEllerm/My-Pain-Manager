//
//  HomeController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 18/04/18.
//  Copyright © 2018 Sebastian Peden. All rights reserved.
//

import UIKit
import Firebase
import SceneKit
import SceneKit.ModelIO

class HomeController: UIViewController {
    
    
    var scene : SCNScene!
    var mesh : SCNNode!
    var scnView: SCNView!
    var camera: SCNCamera!
    var cameraNode: SCNNode!
    
    //var recognizer: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        createScene()
        addMeshToScene()
        
        createCamera()
        createGestureRecogniser()
        createLights()
        
        
       
 
    }
    
    private func createGestureRecogniser(){
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        tapRecognizer.addTarget(self, action: #selector(sceneTapped))//"sceneTapped:")
        
        
        let panRecogniser = UIPanGestureRecognizer()
        
        panRecogniser.addTarget(self, action: #selector(scenePanned))
        
        
        
        
        //scnView.allowsCameraControl = true
        //scnView.cameraControlConfiguration.
        
        scnView.gestureRecognizers = [tapRecognizer,panRecogniser]
        
        //#selector(ClassName.funcName)
    }
    
    
    @objc private func scenePanned(recognizer: UIPanGestureRecognizer) {
        //let location = recognizer.location(in: scnView)
        
        let translation = recognizer.translation(in: recognizer.view!)      // let panResults = scnView
        
        print("Called the handlePan method")
       // let scnView = self.view as! SCNView
        //let cameraOrbit = scnView.scene?.rootNode.childNode(withName: "cameraOrbit", recursively: true)
        let cameraOrbit = cameraNode
        //camera = SCNCamera()
        
        let currentPivot = cameraOrbit!.pivot
        let changePivot = SCNMatrix4Invert(cameraOrbit!.transform)
        cameraOrbit!.pivot = SCNMatrix4Mult(changePivot, currentPivot)
        cameraOrbit!.transform = SCNMatrix4Identity
       // let translation = sender.translation(in: sender.view!)
        
        let pan_x = Float(translation.x)
        let pan_y = Float(-translation.y)
        
        let anglePan = sqrt(pow(pan_x,2)+pow(pan_y,2))*(Float)(Double.pi)/1200  //180.0
        
        var rotationVector = SCNVector4()
        //rotationVector.x = -pan_y
        rotationVector.y = -pan_x
        rotationVector.z = 0
        rotationVector.w = anglePan
       // rotContainer.rotation = rotationVector
        cameraOrbit!.rotation = rotationVector
        
        if(recognizer.state == UIGestureRecognizerState.ended) {
            let currentPivot = cameraOrbit!.pivot
            let changePivot = SCNMatrix4Invert(cameraOrbit!.transform)
            cameraOrbit!.pivot = SCNMatrix4Mult(changePivot, currentPivot)
            cameraOrbit!.transform = SCNMatrix4Identity
        }
        
    }
    
    
    
    
    //@objc lets a private function be visible in objective c
    @objc private func sceneTapped(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: scnView)
        let hitResults = scnView.hitTest(location, options: nil)
        if hitResults.count > 0 {
            print("HIT")
            let result = hitResults[0] //as! SCNHitTestResult
            let node = result.node
            node.geometry?.firstMaterial = ObjectMaterial(
                diffuse: "tex.jpg",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.jpg",
                normal: "tex.jpg"
            ).material
            //node.removeFromParentNode()
        }
        
        //else{
        // scnView.allowsCameraControl = true
        //}
    }
    
    
    
    //Sets up the scene view
    private func createScene(){
        scnView = SCNView(frame: view.frame)
        view.addSubview(scnView)
        scene = SCNScene()
        scnView.scene = scene;
    }
    
    private func createLights(){
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 50, y: 1.5, z: 1.5)
        //light.intensity = CGFloat(50)
        scene.rootNode.addChildNode(lightNode)
        
        let light2 = SCNLight()
        let light2Node = SCNNode()
        light2.type = SCNLight.LightType.omni
        light2Node.position = SCNVector3(x: 1.5, y: 50, z: 1.5)
        // light2.intensity = CGFloat(5000)
        light2Node.light = light2
        scene.rootNode.addChildNode(light2Node)
        
        let light3 = SCNLight()
        let light3Node = SCNNode()
        light3.type = SCNLight.LightType.omni
        light3Node.position = SCNVector3(x: 1.5, y: 1.5, z: 50)
        // light3.intensity = CGFloat(5000)
        light3Node.light = light3
        scene.rootNode.addChildNode(light3Node)
    }
    
    private func createCamera(){
        camera = SCNCamera()
        camera.zNear = 1
        cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 25.0)
        scene.rootNode.addChildNode(cameraNode)
        scnView.allowsCameraControl = true
        
    }
    
 

    //Adds the male or female mesh too the scene
    private func addMeshToScene() {
        let coinflip = Int(arc4random_uniform(2))
        if(coinflip == 0){
            addMale()
            
        }else{
            addFemale()
        }
        
    }
    

    private func addMale() {
        let myMesh = ObjectWrapper(
            // mesh: asset.object(at: 0),   //childObjects(of: MDLObject)[0],//manGeo.geometry!,   //mesh: MeshLoader.loadMeshWith(name: "basicmangeometry", ofType: "obj"),
            mesh: MeshLoader.loadMeshWith(name: "malemesh2", ofType: "obj"),
            material: ObjectMaterial(
                diffuse: "skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "skin.png",
                normal: "skin.png"
            ),
            position: SCNVector3Make(0, 0, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
       myMesh.node.scale = SCNVector3(0.8,0.8,0.8)
    scene.rootNode.addChildNode(myMesh.node)
    }
    
    private func addFemale() {
        
        let myMesh = ObjectWrapper(
            // mesh: asset.object(at: 0),   //childObjects(of: MDLObject)[0],//manGeo.geometry!,   //mesh: MeshLoader.loadMeshWith(name: "basicmangeometry", ofType: "obj"),
            mesh: MeshLoader.loadMeshWith(name: "femalemesh", ofType: "obj"),
            material: ObjectMaterial(
                diffuse: UIColor.white,//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "skin.png",
                normal: "skin.png"),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0, GLKMathDegreesToRadians(20))
            
        )
        
        myMesh.node.scale = SCNVector3(10,10,10)
        scene.rootNode.addChildNode(myMesh.node)
    }
    
    

    
    
    class Object {
        let node: SCNNode
        
        init(position: SCNVector3, rotation: SCNVector4) {
            node = SCNNode()
            node.castsShadow = true
            set(position: position, rotation: rotation)
        }
        
        init(mesh: MDLObject, position: SCNVector3, rotation: SCNVector4) {
            node = SCNNode(mdlObject: mesh)
            node.castsShadow = true
            set(position: position, rotation: rotation)
        }
        
        private func set(position: SCNVector3, rotation: SCNVector4) {
            node.position = position
            node.rotation = rotation
        }
    }
    
    
    class ObjectWrapper: Object {
        init(mesh: MDLObject, material: ObjectMaterial, position: SCNVector3, rotation: SCNVector4) {
            super.init(mesh: mesh, position: position, rotation: rotation)
            node.geometry?.firstMaterial = material.material
            node.geometry?.firstMaterial?.isDoubleSided = true        }
    }
    
    class ObjectMaterial {
        let material: SCNMaterial
        init(diffuse: Any, roughness: Any, metalness: Any, normal: Any, ambientOcclusion: Any? = nil) {
            material = SCNMaterial()
            material.lightingModel = .phong //.physicallyBased
            material.diffuse.contents = diffuse
            material.roughness.contents = roughness
            material.metalness.contents = metalness
            material.normal.contents = normal
            material.ambientOcclusion.contents = ambientOcclusion
            
        }
    }
    
    
    class MeshLoader {
        static func loadMeshWith(name: String, ofType type: String) -> MDLObject {
            let path = Bundle.main.path(forResource: name, ofType: type)!
            let asset = MDLAsset(url: URL(fileURLWithPath: path))
            return asset[0]!
        }
    }
    
    
    
}




