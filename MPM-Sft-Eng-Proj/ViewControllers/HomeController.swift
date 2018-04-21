//
//  HomeController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Harrison Ellerm on 17/04/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import UIKit
import Firebase
import SceneKit

class HomeController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //cubeData = CubeData()
        
        
        navigationItem.title = "Home"
        let scnView = SCNView(frame: view.frame)
        view.addSubview(scnView)
        
        let scene = SCNScene()
        scnView.scene = scene
        
        let camera = SCNCamera()
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0.0, y: 0.0, z: 3.0)
        
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        scnView.allowsCameraControl = true
        
        let sphereGeometry = SCNSphere(radius: 0.5)
        let sphereNode = SCNNode(geometry: sphereGeometry)
        
        //let cubeGeometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
        //let cubeNode = SCNNode(geometry: cubeGeometry)
        
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(sphereNode)
        
        //frame.addChildNode(sphereNode)
        //let scnView = self.view as! SCNView
        //scnView.scene = PrimitiveScene()
        //scnView.backgroundColor = UIColor.black
        
        
        //view.backgroundColor = .white
        
        
        
        
    }
    
    
    //TODO create page
    
}
