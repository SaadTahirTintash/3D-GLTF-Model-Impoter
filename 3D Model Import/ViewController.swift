//
//  ViewController.swift
//  3D Model Import
//
//  Created by Tintash on 06/08/2019.
//  Copyright © 2019 Tintash. All rights reserved.
//

import UIKit
import SSZipArchive
import GLTFSceneKit
import SceneKit

/*
 1. Download the model zip file from server using the specified link at a destination folder
 2. Unzip the downloaded Folder in a new folder using Filemanager
 3. Find the contents of the unzipped folder and find gltf from there
 4. Now you have the folder with gltf in it, you can create a scene model
    using the gltf and put that in a scene
 */


fileprivate let modelPath = "http://storage.3dconfigurator.net.s3.amazonaws.com/staging_bbby_google_ar/bbby_automation_backend/items/bbby-gltf-uncompressed-assets/1011861466_11861466_GLTF.zip"

class ViewController: UIViewController, ModelDownloading {
    
    var scene = SCNScene()
    var sceneView: SCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSceneView()
//
//        do {
//            let sceneSource = try GLTFSceneSource(named: "1011861466_11861466_GLTF/1011861466_11861466")
//            scene     = try sceneSource.scene()
//
//            configureScene()
//
//        } catch {
//            print("\(error.localizedDescription)")
//            return
//        }
        
        downloadModelFile()
        
    }
    
    func downloadModelFile() {
        
        downloadModel(fileName: modelPath, success: { [weak self] (modelUrl) in
            
            do {
                let sceneSource = try GLTFSceneSource(path: modelUrl.path)
                self?.configureScene(modelNode: try sceneSource.scene().rootNode)
                
            } catch {
                print("\(error.localizedDescription)")
                return
            }
            
        }) { (errorMsg) in
            print(errorMsg)
        }
    }
    
    func createSceneView() {
        sceneView = SCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
    }
    
    func configureScene(modelNode: SCNNode) {
        sceneView.scene = scene
        
        let cameraNode = createCamera()
        let lightNode  = createLight()
        let planeNode  = createPlane()
        
        addConstraint(to: cameraNode,target: modelNode)
        addConstraint(to: lightNode, target: modelNode)
        addAmbientLight(to: cameraNode)
        
        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(modelNode)
        scene.rootNode.addChildNode(planeNode)
    }
    
    func createCamera() -> SCNNode {
        let camera          = SCNCamera()
        let cameraNode      = SCNNode()
        cameraNode.camera   = camera
        cameraNode.position = SCNVector3(-1, 1, 1)
        return cameraNode
    }
    
    func createLight() -> SCNNode {
        let light            = SCNLight()
        light.type           = SCNLight.LightType.spot
        light.spotInnerAngle = 30
        light.spotOuterAngle = 80
        light.castsShadow    = true
        
        let lightNode       = SCNNode()
        lightNode.light     = light
        lightNode.position  = SCNVector3(1.5, 1.5, 1.5)
        return lightNode
    }
    
    func createCube() -> SCNNode {
        let cube        = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        addMaterial(to: cube, color: .red)
        
        let cubeNode    = SCNNode(geometry: cube)
        return cubeNode
    }
    
    func createPlane() -> SCNNode {
        let plane       = SCNPlane(width: 50, height: 50)
        addMaterial(to: plane, color: .green)
        
        let planeNode           = SCNNode(geometry: plane)
        planeNode.position      = SCNVector3(0,-0.5,0)
        planeNode.eulerAngles   = SCNVector3(GLKMathDegreesToRadians(-90), 0, 0)
        return planeNode
    }
    
    func addConstraint(to: SCNNode, target: SCNNode) {
        let constraint = SCNLookAtConstraint(target: target)
        constraint.isGimbalLockEnabled = true
        to.constraints = [constraint]
    }
    
    func addMaterial(to: SCNGeometry, color: UIColor) {
        let material = SCNMaterial()
        material.diffuse.contents = color
        to.materials = [material]
    }
    
    func addAmbientLight(to: SCNNode) {
        let ambientLight    = SCNLight()
        ambientLight.type   = SCNLight.LightType.ambient
        ambientLight.color  = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        to.light            = ambientLight
    }
}

