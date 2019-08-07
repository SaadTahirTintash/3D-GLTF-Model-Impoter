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
    
    var sceneView: SCNView!
    var scene = SCNScene()
    
    var cameraNode: SCNNode!
    var cameraOrbit: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createSceneView()
        downloadModelFile()
        
    }
    
    func createSceneView() {
        sceneView = SCNView(frame: self.view.frame)
        self.view.addSubview(sceneView)
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
    
    func configureScene(modelNode: SCNNode) {
        
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.gray
        
//        cameraNode = createCamera()
        cameraNode = createOrthographicCamera()
        let lightNode  = createLight()
//        let planeNode  = createPlane()
        
//        addConstraint(to: cameraNode,target: modelNode)
        addConstraint(to: lightNode, target: modelNode)
        addAmbientLight(to: cameraNode)
        addCameraOrbit(to: cameraNode)
        
//        scene.rootNode.addChildNode(cameraNode)
        scene.rootNode.addChildNode(cameraOrbit)
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(modelNode)
//        scene.rootNode.addChildNode(planeNode)
    }
    
    func createOrthographicCamera() -> SCNNode {
        
        let camera = SCNCamera()
        camera.usesOrthographicProjection = true
        camera.orthographicScale = 1
        
        cameraNode = SCNNode()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 50)
        cameraNode.camera = camera
        
        return cameraNode
    }
    
    func addCameraOrbit(to cameraNode: SCNNode) {
        
        cameraOrbit = SCNNode()
        cameraOrbit.eulerAngles.x -= 30
        cameraOrbit.eulerAngles.y -= 30
        
        cameraOrbit.addChildNode(cameraNode)
    }
    
    func createCamera() -> SCNNode {
        
        let camera          = SCNCamera()
        let cameraNode      = SCNNode()        
        
        cameraNode.camera   = camera
        cameraNode.position = SCNVector3(0.5, 1, 1)
        
        return cameraNode
    }
    
    func createLight() -> SCNNode {
        let light            = SCNLight()
        light.type           = SCNLight.LightType.spot
        light.spotInnerAngle = 20
        light.spotOuterAngle = 50
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
        addMaterial(to: plane, color: .gray)
        
        let planeNode           = SCNNode(geometry: plane)
        planeNode.position      = SCNVector3(0,-0.05,0)
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
    
    private var lastPosition : (Float,Float) = (0,0)
    private var speed : Float = 0.01
    
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: self.view)
        print("Translation: \(translation)")
        print("LastPos:     \(lastPosition)")
        print("CameraRot:   \(cameraOrbit.eulerAngles)")
        print("----------------")
        
        cameraOrbit.eulerAngles.y = lastPosition.0 + -Float(translation.x) * speed
        cameraOrbit.eulerAngles.x = lastPosition.1 + -Float(translation.y) * speed
        
        if sender.numberOfTouches < 1 {
            print("Touches Ended at translation: \(translation)")
            lastPosition = (cameraOrbit.eulerAngles.y,cameraOrbit.eulerAngles.x)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch Began")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("Touch Ended")
    }
    
}

