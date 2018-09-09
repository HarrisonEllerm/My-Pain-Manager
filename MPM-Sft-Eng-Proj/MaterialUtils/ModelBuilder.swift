//
//  ModelBuilder.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 9/9/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.
//

import Foundation
import SceneKit
import SceneKit.ModelIO
import UIKit

class ModelBuilder{

    public func addMaleSkin(hc : HomeController){
        let manMesh = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "Man_Skin2", ofType: "obj"),
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
        manMesh.node.scale = SCNVector3(2.5,2.5,2.5)
        manMesh.node.name = "Man_Skin2"
        hc.scene.rootNode.addChildNode(manMesh.node)
        
        manMesh.node.geometry?.firstMaterial = MaterialWrapper(
            diffuse: UIColor(red: 51/255, green: 153/255, blue: 255/255, alpha: 1), //UIColor.white,
            roughness: NSNumber(value: 0.3),
            metalness: "tex.jpg",
            normal: "tex.jpg"
            ).material
        manMesh.node.geometry?.firstMaterial?.transparency = 0.3
        hc.manMesh = manMesh
        
    }

    public func addMaleSkeleton(hc : HomeController){
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
        hc.scene.rootNode.addChildNode(man_skele.node)
    }

    /**
     Function that imports all the muscles. The reason this is not in
     a for loop is so we have individual control over each object as
     we import it.
     */
    public func addMuscles(hc : HomeController){
        
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
        absL.node.name = "Rectus abdominus right"
        hc.scene.rootNode.addChildNode(absL.node)
        
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
        absR.node.name = "Rectus abdominus left"
        hc.scene.rootNode.addChildNode(absR.node)
        
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
        bicept2L.node.name = "Inner bicep brachii right"
        hc.scene.rootNode.addChildNode(bicept2L.node)
        
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
        biceptR.node.name = "Bicep brachii left"
        hc.scene.rootNode.addChildNode(biceptR.node)
        
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
        biceptR2.node.name = "Brachialis left"
        hc.scene.rootNode.addChildNode(biceptR2.node)
        
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
        biceptR3.node.name = "Inner bicep brachii left"
        hc.scene.rootNode.addChildNode(biceptR3.node)
        
        
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
        bicepttopL.node.name = "Bicep brachii right"
        hc.scene.rootNode.addChildNode(bicepttopL.node)
        
        
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
        bumL.node.name = "Gluteus maximus right"
        hc.scene.rootNode.addChildNode(bumL.node)
        
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
        bumR.node.name = "Gluteus maximus left"
        hc.scene.rootNode.addChildNode(bumR.node)
        
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
        calfL.node.name = "Gastrocnemius medial right"
        hc.scene.rootNode.addChildNode(calfL.node)
        
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
        calfL2.node.name = "Gastrocnemius lateral right"
        hc.scene.rootNode.addChildNode(calfL2.node)
        
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
        calfL3.node.name = "soleus right"
        hc.scene.rootNode.addChildNode(calfL3.node)
        
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
        calfL4.node.name = "Peroneus longus right"
        hc.scene.rootNode.addChildNode(calfL4.node)
        
        
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
        calfL5.node.name = "Tibialis anterior muscle right"
        hc.scene.rootNode.addChildNode(calfL5.node)
        
        
        
        
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
        calfL6.node.name = "Medial surface of the tibia right"
        hc.scene.rootNode.addChildNode(calfL6.node)
        
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
        calfR.node.name = "Gastrocnemius lateral left"
        hc.scene.rootNode.addChildNode(calfR.node)
        
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
        calfR2.node.name = "Gastrocnemius medial left"
        hc.scene.rootNode.addChildNode(calfR2.node)
        
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
        calfR3.node.name = "Soleus left"
        hc.scene.rootNode.addChildNode(calfR3.node)
        
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
        calfR4.node.name = "Peroneus longus left"
        hc.scene.rootNode.addChildNode(calfR4.node)
        
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
        calfR6.node.name = "Medial surface of the tibia left"
        hc.scene.rootNode.addChildNode(calfR6.node)
        
        
        
        let  calfR5 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "calfR5", ofType: "obj"),
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
        
        calfR5.node.scale = SCNVector3(2.5,2.5,2.5)
        calfR5.node.name = "Tibialis anterior muscle left"
        hc.scene.rootNode.addChildNode(calfR5.node)
        
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
        chestL.node.name = "Pectoralis major right"
        hc.scene.rootNode.addChildNode(chestL.node)
        
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
        chestR.node.name = "Pectoralis major left"
        hc.scene.rootNode.addChildNode(chestR.node)
        
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
        deltoidtopl.node.name = "Middle deltoid right"
        hc.scene.rootNode.addChildNode(deltoidtopl.node)
        
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
        deltoidbackl.node.name = "Back deltoid right"
        hc.scene.rootNode.addChildNode(deltoidbackl.node)
        
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
        deltoidfront.node.name = "Front deltoid right"
        hc.scene.rootNode.addChildNode(deltoidfront.node)
        
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
        forearmR.node.name = "Brachioradialis left"
        hc.scene.rootNode.addChildNode(forearmR.node)
        
        
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
        forearm1L.node.name = "Brachioradialus right"
        hc.scene.rootNode.addChildNode(forearm1L.node)
        
        
        
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
        forearm2L.node.name = "Flexor pollicis longus right"
        hc.scene.rootNode.addChildNode(forearm2L.node)
        
        
        
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
        forearm3L.node.name = "Flexor carpi radialis right"
        hc.scene.rootNode.addChildNode(forearm3L.node)
        
        
        
        
        
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
        forearm4L.node.name = "Extendor digitorum right"
        hc.scene.rootNode.addChildNode(forearm4L.node)
        
        
        
        
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
        forearm5L.node.name = "Flexor superficialis right"
        hc.scene.rootNode.addChildNode(forearm5L.node)
        
        
        
        
        
        //forearm6L
        let  forearm6L = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "Flexorcarpiulnarisright", ofType: "obj"),
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
        forearm6L.node.name = "Flexor carpi ulnaris right"
        hc.scene.rootNode.addChildNode(forearm6L.node)
        
        
        
        
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
        forearm7L.node.name = "Flexor digitorum profundus right"
        hc.scene.rootNode.addChildNode(forearm7L.node)
        
        
        
        
        let  forearmR2 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearmR2", ofType: "obj"),
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
        
        forearmR2.node.scale = SCNVector3(2.5,2.5,2.5)
        forearmR2.node.name = "Flexor pollicis longus left"
        hc.scene.rootNode.addChildNode(forearmR2.node)
        
        
        let  forearmR3 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearmR3", ofType: "obj"),
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
        
        forearmR3.node.scale = SCNVector3(2.5,2.5,2.5)
        forearmR3.node.name = "Flexor carpi radialis left"
        hc.scene.rootNode.addChildNode(forearmR3.node)
        
        
        let  forearmR4 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearmR4", ofType: "obj"),
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
        
        forearmR4.node.scale = SCNVector3(2.5,2.5,2.5)
        forearmR4.node.name = "Extensor digitorum left"
        hc.scene.rootNode.addChildNode(forearmR4.node)
        
        
        let  forearmR5 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearmR5", ofType: "obj"),
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
        
        forearmR5.node.scale = SCNVector3(2.5,2.5,2.5)
        forearmR5.node.name = "Flexor superficialis left"
        hc.scene.rootNode.addChildNode(forearmR5.node)
        
        
        //forearmR6
        let  forearmR6 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "Flexorcarpiulnarisleft", ofType: "obj"),
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
        
        forearmR6.node.scale = SCNVector3(2.5,2.5,2.5)
        forearmR6.node.name = "Flexor carpi ulnaris left"
        hc.scene.rootNode.addChildNode(forearmR6.node)
        
        
        let  forearmR7 = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "forearmR7", ofType: "obj"),
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
        
        forearmR7.node.scale = SCNVector3(2.5,2.5,2.5)
        forearmR7.node.name = "Flexor digitorum profundus left"
        hc.scene.rootNode.addChildNode(forearmR7.node)
        
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
        frontshoulderR.node.name = "Front deltoid left"
        hc.scene.rootNode.addChildNode(frontshoulderR.node)
        
        
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
        hipL.node.name = "Tensor fasciae latae right"
        hc.scene.rootNode.addChildNode(hipL.node)
        
        
        let hipR = ObjectWrapper(
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
        hipR.node.name = "Tensor fasciae latae left"
        hc.scene.rootNode.addChildNode(hipR.node)
        
        
        
        let innerShoulder_L = ObjectWrapper(
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
        innerShoulder_L.node.name = "Teres minor right"
        hc.scene.rootNode.addChildNode(innerShoulder_L.node)
        
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
        innerShoulder_R.node.name = "Teres minor left"
        hc.scene.rootNode.addChildNode(innerShoulder_R.node)
        
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
        LegThighL.node.name = "Vastus lateralis right"
        hc.scene.rootNode.addChildNode(LegThighL.node)
        
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
        Lowerback_L.node.name = "Iliocostalis Lumborum right"
        hc.scene.rootNode.addChildNode(Lowerback_L.node)
        
        
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
        Lowerback_R.node.name = "Iliocostalis Lumborum left"
        hc.scene.rootNode.addChildNode(Lowerback_R.node)
        
        
        
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
        midback_L.node.name = "Latissimus dorsi right"
        hc.scene.rootNode.addChildNode(midback_L.node)
        
        
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
        midback_R.node.name = "Latissimus dorsi left"
        hc.scene.rootNode.addChildNode(midback_R.node)
        
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
        neck_L.node.name = "splenius capitis right"
        hc.scene.rootNode.addChildNode(neck_L.node)
        
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
        neck_R.node.name = "splenius capitis left"
        hc.scene.rootNode.addChildNode(neck_R.node)
        
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
        outershoulder_L.node.name = "Teres major right"
        hc.scene.rootNode.addChildNode(outershoulder_L.node)
        
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
        outershoulder_R.node.name = "Teres major left"
        hc.scene.rootNode.addChildNode(outershoulder_R.node)
        
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
        ribmuscles_L.node.name = "External intercostals right"
        hc.scene.rootNode.addChildNode(ribmuscles_L.node)
        
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
        ribmuscles_R.node.name = "External intercostals left"
        hc.scene.rootNode.addChildNode(ribmuscles_R.node)
        
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
        shoulderR.node.name = "Middle deltoid left"
        hc.scene.rootNode.addChildNode(shoulderR.node)
        
        
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
        shoulderR2.node.name = "Back deltoid left"
        hc.scene.rootNode.addChildNode(shoulderR2.node)
        
        
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
        thigh_L3.node.name = "Vastus medialis right"
        hc.scene.rootNode.addChildNode(thigh_L3.node)
        
        
        
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
        thighR_5.node.name = "Semitendinosus left"
        hc.scene.rootNode.addChildNode(thighR_5.node)
        
        
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
        thighR_6.node.name = "Vastus lateralis left"
        hc.scene.rootNode.addChildNode(thighR_6.node)
        
        
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
        thighR_7.node.name = "Vastus medialis left"
        hc.scene.rootNode.addChildNode(thighR_7.node)
        
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
        thighR1.node.name = "Bicep femoris Left"
        hc.scene.rootNode.addChildNode(thighR1.node)
        
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
        thighR2.node.name = "Iliotibial tract left"
        hc.scene.rootNode.addChildNode(thighR2.node)
        
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
        thighR3.node.name = "Rectus Femoris left"
        hc.scene.rootNode.addChildNode(thighR3.node)
        
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
        thighR4.node.name = "Sartorius left"
        hc.scene.rootNode.addChildNode(thighR4.node)
        
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
        thighR5.node.name = "Adductor magnus Left"
        hc.scene.rootNode.addChildNode(thighR5.node)
        
        let throat_R = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "throat_R", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        throat_R .node.scale = SCNVector3(2.5,2.5,2.5)
        throat_R.node.name = "Platysma Left"
        hc.scene.rootNode.addChildNode(throat_R .node)
        
        let throatL = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "throatL", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        throatL .node.scale = SCNVector3(2.5,2.5,2.5)
        throatL.node.name = "Platysma right"
        hc.scene.rootNode.addChildNode(throatL .node)
        
        let topback_L  = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "topback_L", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor(red: 119/255, green: 49/255, blue: 41/255, alpha: 1),
                roughness: NSNumber(value: 0.3),
                metalness: "tex.png",
                normal: "tex.png"
            ),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0,
                                     GLKMathDegreesToRadians(20))
        )
        
        topback_L .node.scale = SCNVector3(2.5,2.5,2.5)
        topback_L.node.name = "Upper trapezius right"//topback_L" //Upper trapezius right
        hc.scene.rootNode.addChildNode(topback_L .node)
        
        
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
        topback_R.node.name = "Upper trapezius left"//topback_R" // Upper trapezius left
        hc.scene.rootNode.addChildNode(topback_R .node)
        
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
        tricept2L.node.name = "Inner tricept right"//tricept2L" //Inner tricept right
        hc.scene.rootNode.addChildNode(tricept2L .node)
        
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
        triceptR.node.name = "Outer tricep left"//triceptR" //Tricepts Left
        hc.scene.rootNode.addChildNode(triceptR .node)
        
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
        triceptR2.node.name = "Inner tricept left"//triceptR2" //Inner Tricepts Left
        hc.scene.rootNode.addChildNode(triceptR2 .node)
        
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
        triceptsL.node.name = "Outer tricept right"//"triceptsL" // Tricepts right
        hc.scene.rootNode.addChildNode(triceptsL.node)
        
        
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
        upperarm_outerL.node.name = "Brachialis right"//"upperarm_outerL" // brachio radialis right
        hc.scene.rootNode.addChildNode(upperarm_outerL.node)
        
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
        upperback_L.node.name = "lower trapezius right"//"upperback_L" // lower trapezius right
        hc.scene.rootNode.addChildNode(upperback_L.node)
        
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
        upperback_R.node.name = "lower trapezius left"//"upperback_R" //lower trapezius left
        hc.scene.rootNode.addChildNode(upperback_R.node)
        
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
        upperbum_L.node.name = "Gluteus medius Left"//"upperbum_L" //Gluteus maximus Left
        hc.scene.rootNode.addChildNode(upperbum_L.node)
        
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
        upperbumR.node.name = "Gluteus medius right"//"upperbumR" //Gluteus maximus right
        hc.scene.rootNode.addChildNode(upperbumR.node)
        
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
        upperleg2Inner.node.name = "Adductor magnus right"//"upperleg2InnerL" //adductor magnus right
        hc.scene.rootNode.addChildNode(upperleg2Inner.node)
        
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
        upperlegBack.node.name = "biceps femoris right"//"upperlegBackL" //biceps femoris, long head Right
        hc.scene.rootNode.addChildNode(upperlegBack.node)
        
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
        upperLegbackL2.node.name = "Semitendinosus right"//"upperlegbackL2" //Semitendinosus right
        hc.scene.rootNode.addChildNode(upperLegbackL2.node)
        
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
        upperLegFrontL.node.name = "Rectus femoris right"
        hc.scene.rootNode.addChildNode(upperLegFrontL.node)
        
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
        upperLegFrontL2.node.name = "Sartorius right"    //"upperlegFrontL2"
        hc.scene.rootNode.addChildNode(upperLegFrontL2.node)
        
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
        upperlegLside.node.name = "Iliotibial tract right" //"upperlegLside"
        hc.scene.rootNode.addChildNode(upperlegLside.node)
        
    }

  //TODO
    public func addFemale(hc : HomeController) {
        let myMesh = ObjectWrapper(
            mesh: MeshLoader.loadMeshWith(name: "femalemesh", ofType: "obj"),
            material: MaterialWrapper(
                diffuse: UIColor.white,
                roughness: NSNumber(value: 0.3),
                metalness: "skin.png",
                normal: "skin.png"),
            position: SCNVector3Make(0, -8, 0),
            rotation: SCNVector4Make(0, 1, 0, GLKMathDegreesToRadians(20))
            
        )
        myMesh.node.scale = SCNVector3(10,10,10);
        let nodeMaterial = myMesh.node.geometry?.firstMaterial
        nodeMaterial?.emission.contents = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        nodeMaterial?.transparencyMode = .rgbZero
        hc.scene.rootNode.addChildNode(myMesh.node)
    }
}
