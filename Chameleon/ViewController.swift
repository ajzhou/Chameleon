//
//  ViewController.swift
//  Chameleon
//
//  Created by Andrew Jay Zhou on 7/2/17.
//  Copyright © 2017 Andrew Jay Zhou. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var picture: Picture!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupScene()
        restartPlaneDetection()
        
        // Set tap Gesture using handleTap()
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(ViewController.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer){
        guard let currentFrame = sceneView.session.currentFrame else{
            return
        }
        var targetAnchor: ARAnchor?
        //createPicture(fileName: "sample", width: sceneView.bounds.width / 7000, height: sceneView.bounds.height / 7000)
        
        // Set transform of node to be 10cm in front of the camera, for now;
        // later change this to the plane directly in front of the camera
//       var translation = matrix_identity_float4x4
//        translation.columns.3.z = -0.1
//        picture.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        // perform hit test based on tap
        let point = gestureRecognize.location(in: sceneView)
        let results = currentFrame.hitTest(point, types: [.existingPlane, .estimatedHorizontalPlane])
        if let closestResult = results.first {
            let anchor = ARAnchor(transform: closestResult.worldTransform)
            session.add(anchor: anchor)
            targetAnchor = anchor
            print("found anchor!!!!!!!!")
            
        }
        //createPicture(fileName: "sample", width: sceneView.bounds.width / 7000, height: sceneView.bounds.height / 7000)
        createPicture(fileName: "sample", width: 0.2, height: 0.2)
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        picture.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        picture.rotation = SCNVector4.init(1, 0, 0, CGFloat.pi * 3/2)
        // drop picture onto plane if anchor exists
        if targetAnchor != nil {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            picture.position.y = targetAnchor!.transform.columns.3.y
            SCNTransaction.commit()
        }
        
    }
    
    func setupScene() {
        // set up sceneView
        sceneView.delegate = self
        sceneView.session = session
        sceneView.antialiasingMode = .multisampling4X
        sceneView.automaticallyUpdatesLighting = false
        
        sceneView.preferredFramesPerSecond = 60
        sceneView.contentScaleFactor = 1.3
        //sceneView.showsStatistics = true
        
//        enableEnvironmentMapWithIntensity(25.0)
        
//        DispatchQueue.main.async {
//            self.screenCenter = self.sceneView.bounds.mid
//        }
        
        if let camera = sceneView.pointOfView?.camera {
            camera.wantsHDR = true
            camera.wantsExposureAdaptation = true
            camera.exposureOffset = -1
            camera.minimumExposure = -1
        }
    }
    
//    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
//        if sceneView.scene.lightingEnvironment.contents == nil {
//            if let environmentMap = UIImage(named: "Models.scnassets/sharedImages/environment_blur.exr") {
//                sceneView.scene.lightingEnvironment.contents = environmentMap
//            }
//        }
//        sceneView.scene.lightingEnvironment.intensity = intensity
//    }
    
    func createPicture(fileName: String, width: CGFloat, height: CGFloat){
        picture = Picture(fileName: fileName, width: width, height: height)
        sceneView.scene.rootNode.addChildNode(picture)
    }
    
    
    let session = ARSession()
    var sessionConfig: ARSessionConfiguration = ARWorldTrackingSessionConfiguration()
    var screenCenter: CGPoint?
    
    func restartPlaneDetection() {
        
        // configure session
        if let worldSessionConfig = sessionConfig as? ARWorldTrackingSessionConfiguration {
            worldSessionConfig.planeDetection = .horizontal
            session.run(worldSessionConfig, options: [.resetTracking, .removeExistingAnchors])
        }
        // *code below is copied from ARKitExample - do not know what to do with it*
//        // reset timer
//        if trackingFallbackTimer != nil {
//            trackingFallbackTimer!.invalidate()
//            trackingFallbackTimer = nil
//        }
        
//        textManager.scheduleMessage("FIND A SURFACE TO PLACE AN OBJECT",
//                                    inSeconds: 7.5,
//                                    messageType: .planeEstimation)
    }
    
    // *do not need this code at the moment*
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        // Create a session configuration
//        let configuration = ARWorldTrackingSessionConfiguration()
//
//        // Run the view's session
//        sceneView.session.run(configuration)
//    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
