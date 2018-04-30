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
            let myMesh = ObjectWrapper(
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
            myMesh.node.scale = SCNVector3(2.5,2.5,2.5)
            self.scene.rootNode.addChildNode(myMesh.node)
            myMesh.node.geometry?.firstMaterial = MaterialWrapper(
            diffuse: UIColor.white,
            roughness: NSNumber(value: 0.3),
            metalness: "tex.jpg",
            normal: "tex.jpg"
            ).material
            myMesh.node.geometry?.firstMaterial?.transparency = 0.5
            self.manMesh = myMesh
            //add male skeleton
            let myMesh2 = ObjectWrapper(
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
            myMesh2.node.scale = SCNVector3(2.5,2.5,2.5)
            self.scene.rootNode.addChildNode(myMesh2.node)
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




