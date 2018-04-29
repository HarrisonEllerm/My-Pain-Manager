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
    
    var manMesh : ObjectWrapper!
    var scene : SCNScene!
    var mesh : SCNNode!
    var scnView: SCNView!
    var camera: SCNCamera!
    var cameraNode: SCNNode!
    var wasClicked = false
    //static var skelemat = SCNMaterial()
    
    //var recognizer: UITapGestureRecognizer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.black
        createScene()
        addMeshToScene()
        createCamera()
        createGestureRecogniser()
        createLights()
        createSwapButton()
        
        //createEnvironmentLighting()
        
        
       
 
    }
    private func createSwapButton(){
        let width = 130
        let middle = Float(self.view.frame.size.width/2) - Float(width/2)
        let CentreX = Int(middle)
        
        let button = UIButton(frame: CGRect(x: CentreX, y: 670, width: width, height: 30))
        button.backgroundColor = .white
        button.setTitle("Swap", for: .normal)
       // button.titleLabel?.textColor = UIColor.yellow
       // button.setTitle("Test Button", forState: .Normal)
        button.addTarget(self, action: #selector(swapAction), for: .touchUpInside)
        button.backgroundColor = UIColor.black
        button.layer.cornerRadius = 8
        self.view.addSubview(button)

    }
    
    @objc func swapAction(sender: UIButton){
        if(manMesh.node.isHidden){
            manMesh.node.isHidden = false
        }else{
            manMesh.node.isHidden = true
        }
    }
    
    
    
    
    private func createEnvironmentLighting(cubeMap: [String], intensity: CGFloat){
        let cubeMap = cubeMap
        let intensity = intensity
        
        func setLightingEnviromentFor(scene: SCNScene) {
            scene.lightingEnvironment.contents = cubeMap
            scene.lightingEnvironment.intensity = intensity
            scene.background.contents = cubeMap
        }
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

        let translation = recognizer.translation(in: recognizer.view!)      // let panResults = scnView
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
            print(wasClicked)
            print("HIT")
            let result = hitResults[0] //as! SCNHitTestResult
            let node = result.node
            
            if(wasClicked){
               
                node.geometry?.firstMaterial = MaterialWrapper(
                    diffuse: UIColor.red,
                    roughness: NSNumber(value: 0.3),
                    metalness: "tex.jpg",
                    normal: "tex.jpg"
                    ).material
                
                wasClicked = false
            //node.removeFromParentNode()
            }else{
               
                node.geometry?.firstMaterial = MaterialWrapper(
                    diffuse: UIColor.white,
                    roughness: NSNumber(value: 0.3),
                    metalness: "tex.jpg",
                    normal: "tex.jpg"
                    ).material
                wasClicked = true;
            }
            
        
        //else{
        // scnView.allowsCameraControl = true
        //}
            node.geometry?.firstMaterial?.transparency = 0.5
        }
    }
    
    
    
    //Sets up the scene view
    private func createScene(){
        scnView = SCNView(frame: view.frame)
        view.addSubview(scnView)
        scene = SCNScene()
        scene.background.contents = UIImage(named: "bg.jpg")
        scnView.scene = scene;
        
       // scnView.backgroundColor = UIColor.black//.contents = UIImage(named: "earth.jpg")
        
        
        //scnView.
    }
    
    private func createLights(){
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 50, y: 1.5, z: 1.5)
        light.intensity = CGFloat(300)
        scene.rootNode.addChildNode(lightNode)

        let light2 = SCNLight()
        let light2Node = SCNNode()
        light2.type = SCNLight.LightType.omni
        light2Node.position = SCNVector3(x: 1.5, y: 50, z: 1.5)
        light2.intensity = CGFloat(700)
        light2Node.light = light2
        scene.rootNode.addChildNode(light2Node)

        let light3 = SCNLight()
        let light3Node = SCNNode()
        light3.type = SCNLight.LightType.omni
        light3Node.position = SCNVector3(x: 1.5, y: 1.5, z: 50)
        light3.intensity = CGFloat(400)
        light3Node.light = light3
        scene.rootNode.addChildNode(light3Node)

        let light4 = SCNLight()
        let light4Node = SCNNode()
        light4.type = SCNLight.LightType.omni
        light4Node.position = SCNVector3(x: 1.5, y: 1.5, z: -50)
        light4.intensity = CGFloat(400)
        light4Node.light = light4
        scene.rootNode.addChildNode(light4Node)
        
        
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
       // let coinflip = Int(arc4random_uniform(2))
       // if(coinflip == 0){
            addMale()
            addMaleSkele()
       // }else{
        //    addFemale()
       // }
        
    }
    

    private func addMale() {
        let myMesh = ObjectWrapper(
            // mesh: asset.object(at: 0),   //childObjects(of: MDLObject)[0],//manGeo.geometry!,   //mesh: MeshLoader.loadMeshWith(name: "basicmangeometry", ofType: "obj"),
            mesh: MeshLoader.loadMeshWith(name: "ManReady1", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor.white,//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
                
            ),
            
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
            )
        myMesh.node.geometry?.firstMaterial?.transparency = 0.5
        //myMesh.node.geometry?.firstMaterial?.transparency
        //myMesh.node.geometry?.firstMaterial?.fresnelExponent = CGFloat(0.1)
        //myMesh.node.geometry?.firstMaterial?.emission.intensity = 0.8
        myMesh.node.scale = SCNVector3(2.5,2.5,2.5)
        //myMesh.node.isHidden = true
        
      //  let nodeMaterial = myMesh.node.geometry?.firstMaterial
       // nodeMaterial?.emission.contents = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
      //  nodeMaterial?.transparencyMode = .rgbZero
       // nodeMaterial?.transparent.contents = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.4)
        
        
        scene.rootNode.addChildNode(myMesh.node)
        
        myMesh.node.geometry?.firstMaterial = MaterialWrapper(
            diffuse: UIColor.white,
            roughness: NSNumber(value: 0.3),
            metalness: "tex.jpg",
            normal: "tex.jpg"
            ).material
        myMesh.node.geometry?.firstMaterial?.transparency = 0.5
        
        manMesh = myMesh
    }
    
    
    
    private func addMaleSkele() {
        let myMesh = ObjectWrapper(
            // mesh: asset.object(at: 0),   //childObjects(of: MDLObject)[0],//manGeo.geometry!,   //mesh: MeshLoader.loadMeshWith(name: "basicmangeometry", ofType: "obj"),
            mesh: MeshLoader.loadMeshWith(name: "skeleready1", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor.white,//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "skin.png",
                normal: "skin.png"
                
            ),
            
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        myMesh.node.scale = SCNVector3(2.5,2.5,2.5)
        scene.rootNode.addChildNode(myMesh.node)
    }
    
    
    
    
    
    
    private func addFemale() {
        
        let myMesh = ObjectWrapper(
            // mesh: asset.object(at: 0),   //childObjects(of: MDLObject)[0],//manGeo.geometry!,   //mesh: MeshLoader.loadMeshWith(name: "basicmangeometry", ofType: "obj"),
            mesh: MeshLoader.loadMeshWith(name: "femalemesh", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor.white,//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "skin.png",
                normal: "skin.png"),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0, GLKMathDegreesToRadians(20))
            
        )
        
        myMesh.node.scale = SCNVector3(10,10,10)
        
        let nodeMaterial = myMesh.node.geometry?.firstMaterial
        nodeMaterial?.emission.contents = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        
        nodeMaterial?.transparencyMode = .rgbZero
        
        scene.rootNode.addChildNode(myMesh.node)
        
    }
    
    

    //A Node which holds A mesh and a position
    
    class Object {
        let node: SCNNode
        
        init(position: SCNVector3, rotation: SCNVector4) {
            node = SCNNode()
            //node.castsShadow = true
            set(position: position, rotation: rotation)
        }
        
        init(mesh: MDLObject, position: SCNVector3, rotation: SCNVector4) {
            node = SCNNode(mdlObject: mesh)
            //node.castsShadow = true
            set(position: position, rotation: rotation)
        }
        
        private func set(position: SCNVector3, rotation: SCNVector4) {
            node.position = position
            node.rotation = rotation
        }
    }
    
    
    class ObjectWrapper: Object {
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
    
  
    
    
    class MeshLoader {
        static func loadMeshWith(name: String, ofType type: String) -> MDLObject {
            let path = Bundle.main.path(forResource: name, ofType: type)!
            let asset = MDLAsset(url: URL(fileURLWithPath: path))
            return asset[0]!
        }
    }
        
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
    
    
    
}




