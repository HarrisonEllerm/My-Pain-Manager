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
    var isLoading = true
    var hasLoaded = false
    let updateQueue = DispatchQueue(label: "updateQueue")
    weak var activityIndicator: UIActivityIndicatorView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Home"
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor:UIColor.white]
        navigationController?.navigationBar.barTintColor = UIColor.black
        /*
           Activity Indicator Used to show users that the model is being loaded,
           which can take around a second since it is reading in large files to render
           the body.
         */
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.startAnimating()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        view.backgroundColor = UIColor.black
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.activityIndicator = activityIndicator
    }
    
    
    func loadScene() {
        /*
           Several of the opperations are required to be executed
           on the main thread mandatorily, this also guarantees
           that everything is executed sequentially
        */
        DispatchQueue.main.async {
            //add scene
            self.scnView = SCNView(frame: self.view.frame)
            self.view.addSubview(self.scnView)
            self.scene = SCNScene()
            self.scene.background.contents = UIImage(named: "bg.jpg")
            self.scnView.scene = self.scene;
            
            //add male
            let manMesh = ObjectWrapper(
                mesh: MeshLoader.loadMeshWith(name: "Man_Skin", ofType: "obj"),
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
            manMesh.node.geometry?.firstMaterial?.transparency = 0.5
            manMesh.node.scale = SCNVector3(2.5,2.5,2.5)
            self.scene.rootNode.addChildNode(manMesh.node)
            
            manMesh.node.geometry?.firstMaterial = MaterialWrapper(
            diffuse: UIColor.white,
            roughness: NSNumber(value: 0.3),
            metalness: "tex.jpg",
            normal: "tex.jpg"
            ).material
            manMesh.node.geometry?.firstMaterial?.transparency = 0.5
            self.manMesh = manMesh
            
            
            
            
            //add male skeleton
            let man_skele = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "man_skele", ofType: "obj"),
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
            man_skele.node.scale = SCNVector3(2.5,2.5,2.5)
            man_skele.node.name = "man_skele"
            
            let skelemat = SCNMaterial()
            skelemat.diffuse.contents = UIColor.white
            let materials = man_skele.node.geometry?.materials
            
            var materialarraysize = materials?.count ?? 0
            materialarraysize = Int(materialarraysize)
            
            for index in 0...materialarraysize-1{
                man_skele.node.geometry?.materials[index] = skelemat
            }
            
            self.scene.rootNode.addChildNode(man_skele.node)
            
            
            self.addMuscles()
            
            
            
            
            
            
            //create camera
            self.camera = SCNCamera()
            self.camera.zNear = 1
            self.cameraNode = SCNNode()
            self.cameraNode.camera = self.camera
            self.cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 25.0)
            self.scene.rootNode.addChildNode(self.cameraNode)
            self.scnView.allowsCameraControl = true
            //create gesture recogniser
            let tapRecognizer = UITapGestureRecognizer()
            tapRecognizer.numberOfTapsRequired = 1
            tapRecognizer.numberOfTouchesRequired = 1
            tapRecognizer.addTarget(self, action: #selector(self.sceneTapped))//"sceneTapped:")
            let panRecogniser = UIPanGestureRecognizer()
            panRecogniser.addTarget(self, action: #selector(self.scenePanned))
            self.scnView.gestureRecognizers = [tapRecognizer,panRecogniser]
            //create lights
            let light = SCNLight()
            light.type = SCNLight.LightType.omni
            let lightNode = SCNNode()
            lightNode.light = light
            lightNode.position = SCNVector3(x: 50, y: 1.5, z: 1.5)
            light.intensity = CGFloat(300)
            self.scene.rootNode.addChildNode(lightNode)
            let light2 = SCNLight()
            let light2Node = SCNNode()
            light2.type = SCNLight.LightType.omni
            light2Node.position = SCNVector3(x: 1.5, y: 50, z: 1.5)
            light2.intensity = CGFloat(700)
            light2Node.light = light2
            self.scene.rootNode.addChildNode(light2Node)
            let light3 = SCNLight()
            let light3Node = SCNNode()
            light3.type = SCNLight.LightType.omni
            light3Node.position = SCNVector3(x: 1.5, y: 1.5, z: 50)
            light3.intensity = CGFloat(400)
            light3Node.light = light3
            self.scene.rootNode.addChildNode(light3Node)
            let light4 = SCNLight()
            let light4Node = SCNNode()
            light4.type = SCNLight.LightType.omni
            light4Node.position = SCNVector3(x: 1.5, y: 1.5, z: -50)
            light4.intensity = CGFloat(400)
            light4Node.light = light4
            self.scene.rootNode.addChildNode(light4Node)
            //create swap button
            let width = 130
            let middle = Float(self.view.frame.size.width/2) - Float(width/2)
            let CentreX = Int(middle)
            let button = UIButton(frame: CGRect(x: CentreX, y: 670, width: width, height: 30))
            button.backgroundColor = .white
            button.setTitle("Swap", for: .normal)
            button.addTarget(self, action: #selector(self.swapAction), for: .touchUpInside)
            button.backgroundColor = UIColor.black
            button.layer.cornerRadius = 8
            self.view.addSubview(button)
            self.isLoading = false
            guard let activityIndicator = self.activityIndicator else { return }
            UIView.animate(withDuration: 0.35, animations: {
                activityIndicator.alpha = 0
                }, completion: { _ in
                    activityIndicator.removeFromSuperview()
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkStatus()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    
    func checkStatus() {
        if hasLoaded == false {
            hasLoaded = true
            updateQueue.async { [weak self] in
                self?.loadScene()
            }
        }
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
           
            print("HIT")
            let result = hitResults[0] //as! SCNHitTestResult
            let node = result.node
            let name = node.name
            
            
            if(wasClicked){
                 print(wasClicked)
                if(name != "man_skele"){
               
//                node.geometry?.firstMaterial = MaterialWrapper(
//                    diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 0.5),
//                    roughness: NSNumber(value: 0.3),
//                    metalness: "tex.jpg",
//                    normal: "tex.jpg"
//                    ).material
//
                wasClicked = false
                    
                    node.geometry?.firstMaterial?.emission.contents = UIColor(red: 150/255, green: 0.0/255, blue: 0/255, alpha: 0.5)
                }
            //node.removeFromParentNode()
            }else{
                
                if(name != "man_skele"){
               
//                node.geometry?.firstMaterial = MaterialWrapper(
//                    diffuse: UIColor.white,
//                    roughness: NSNumber(value: 0.3),
//                    metalness: "tex.jpg",
//                    normal: "tex.jpg"
//                    ).material
//
                wasClicked = true;
                    
                     node.geometry?.firstMaterial?.emission.contents = UIColor(red: 0/255, green: 0.0/255, blue: 0/255, alpha: 1)
                    
                }
            }
            
        
        //else{
        // scnView.allowsCameraControl = true
        //}
           // node.geometry?.firstMaterial?.transparency = 0.5
        }
    }
    
    private func addMuscles(){
        
        let absL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "AbsL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )

        absL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(absL.node)
        
        
        
        let absR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "AbsR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        absR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(absR.node)
        
        let  bicept2L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "bicept2L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        bicept2L .node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(bicept2L.node)
        
        let  biceptR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "biceptR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        biceptR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(biceptR.node)
        
        let  biceptR2 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "biceptR2", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        biceptR2.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(biceptR2.node)
        
        let  biceptR3 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "biceptR3", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        biceptR3.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(biceptR3.node)
        
        
        let  bicepttopL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "bicepttopL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        bicepttopL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(bicepttopL.node)
        
        
        let  bumL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "bumL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        bumL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(bumL.node)
        
        let  bumR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "bumR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        bumR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(bumR.node)
        
        let  calfL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfL.node)
        
        let  calfL2 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfL2", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfL2.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfL2.node)
        
        let  calfL3 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfL3", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfL3.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfL3.node)
        
        let  calfL4 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfL4", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfL4.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfL4.node)
        
        
        let  calfL5 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfL5", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfL5.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfL5.node)
        
        
        
        
        let  calfL6 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfL6", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfL6.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfL6.node)
        
        let  calfR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfR.node)
        
        let  calfR2 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfR2", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfR2.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfR2.node)
        
        let  calfR3 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfR3", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfR3.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfR3.node)
        
        let  calfR4 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfR4", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfR4.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfR4.node)
        
        let  calfR6 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfR6", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        calfR6.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(calfR6.node)
        
        let  chestL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "Chest_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        chestL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(chestL.node)
        
        let  chestR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "chest_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        chestR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(chestR.node)
        
        let  deltoidtopl = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "deltoid_topL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )

        deltoidtopl.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(deltoidtopl.node)

        let  deltoidbackl = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "deltoidbackL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        deltoidbackl.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(deltoidbackl.node)
        
        let  deltoidfront = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "deltoidFront", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        deltoidfront.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(deltoidfront.node)
        
        let  forearmR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forarmR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        forearmR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(forearmR.node)
        
        
        let  forearm1L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearm1L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        forearm1L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(forearm1L.node)
        
        
        
        let  forearm2L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearm2L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        forearm2L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(forearm2L.node)
        
        
        
        let  forearm3L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearm3L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        forearm3L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(forearm3L.node)
        
        
        
        
        
        let  forearm4L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearm4L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        forearm4L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(forearm4L.node)
        
        
        
        
        let  forearm5L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearm5L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        forearm5L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(forearm5L.node)
        
        
        
        
        let  forearm6L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearm6L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        forearm6L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(forearm6L.node)
        
        
        
        
        let  forearm7L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearm7L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        forearm7L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(forearm7L.node)
        
        
        let  frontshoulderR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "frontshoulderR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        frontshoulderR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(frontshoulderR.node)
        
        
        let  hipL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "hipL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        hipL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(hipL.node)
        
        
        let  hipR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "hipR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        hipR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(hipR.node)
        
        
        
        let  innerShoulder_L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "innerShoulder_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        innerShoulder_L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(innerShoulder_L.node)
        
        let innerShoulder_R = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "Innershoulder_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        innerShoulder_R.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(innerShoulder_R.node)
        
        let LegThighL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "LegthighL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        LegThighL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(LegThighL.node)
        
        let Lowerback_L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "lowerback_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        Lowerback_L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(Lowerback_L.node)
        
        
        let Lowerback_R = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "Lowerback_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        Lowerback_R.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(Lowerback_R.node)
        
        
        
        let midback_L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "midback_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        midback_L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(midback_L.node)
        
        
        let midback_R = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "midback_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        midback_R.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(midback_R.node)
        
        let neck_L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "neck_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        neck_L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(neck_L.node)
        
        let neck_R = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "neck_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        neck_R.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(neck_R.node)
        
        
        
        let outershoulder_L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "outershoulder_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        outershoulder_L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(outershoulder_L.node)
        
        let outershoulder_R = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "outerShoulder_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        outershoulder_R.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(outershoulder_R.node)
        
        let ribmuscles_L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "ribmuscles_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        ribmuscles_L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(ribmuscles_L.node)
        
        let ribmuscles_R = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "ribmuscles_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        ribmuscles_R.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(ribmuscles_R.node)
        
        let shoulderR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "shoulderR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        shoulderR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(shoulderR.node)
        
        
        let shoulderR2 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "shoulderR2", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        shoulderR2.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(shoulderR2.node)
        
        
        let thigh_L3 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "thigh_L3", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        thigh_L3.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(thigh_L3.node)
        
        
        
        let thighR_5 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "thighR_5", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        thighR_5.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(thighR_5.node)
        
        
        let thighR_6 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "thighR_6", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        thighR_6.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(thighR_6.node)
        
        
        let thighR_7 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "thighR_7", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        thighR_7.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(thighR_7.node)
        
        let thighR1 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "thighR1", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        thighR1.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(thighR1.node)
        
        let thighR2 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "thighR2", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        thighR2.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(thighR2.node)
        
        let thighR3 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "thighR3", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        thighR3.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(thighR3.node)
        
        let thighR4 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "thighR4", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        thighR4.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(thighR4.node)
        
        
        
        let thighR5 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "thighR5", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        thighR5.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(thighR5.node)
        
        let throat_R = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "throat_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        throat_R .node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(throat_R .node)
        
        let throatL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "throatL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        throatL .node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(throatL .node)
        
        let topback_L  = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "topback_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        topback_L .node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(topback_L .node)
        
        
        let topback_R  = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "topback_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        topback_R .node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(topback_R .node)
        
        
        
        
        let tricept2L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "tricept2L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        tricept2L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(tricept2L .node)
        
        
        
        let triceptR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "triceptR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        triceptR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(triceptR .node)
        
        
        
        let triceptR2 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "triceptR2", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        triceptR2.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(triceptR2 .node)
        
        
        let triceptsL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "triceptsL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        triceptsL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(triceptsL.node)
        
        
        let upperarm_outerL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperarm_outerL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperarm_outerL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(upperarm_outerL.node)
        
        
        
        
        let upperback_L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperback_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperback_L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(upperback_L.node)
        
        
        
        let upperback_R = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperback_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperback_R.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(upperback_R.node)
        
        
        let upperbum_L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperbum_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperbum_L.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(upperbum_L.node)
        
        
        
        let upperbumR = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperbumR", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperbumR.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(upperbumR.node)
        
        
        let upperleg2Inner = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperleg2InnerL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperleg2Inner.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(upperleg2Inner.node)
        
        
        let upperlegBack = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperlegBackL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperlegBack.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(upperlegBack.node)
        
        
        let upperLegbackL2 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperLegbackL2", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperLegbackL2.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(upperLegbackL2.node)
        
        let upperLegFrontL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperLegFrontL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperLegFrontL.node.scale = SCNVector3(2.5,2.5,2.5)
        self.scene.rootNode.addChildNode(upperLegFrontL.node)
        
        
        let upperLegFrontL2 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperLegFrontL2", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperLegFrontL2.node.scale = SCNVector3(2.5,2.5,2.5)
        
        self.scene.rootNode.addChildNode(upperLegFrontL2.node)
        
        let upperlegLside = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "upperlegLside", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),//"skin.png",
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        upperlegLside.node.scale = SCNVector3(2.5,2.5,2.5)
        upperlegLside.node.name = "upperlegLside"
        self.scene.rootNode.addChildNode(upperlegLside.node)
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
      
        
        
        
        
        
        
        
        
        
        
    
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
}




