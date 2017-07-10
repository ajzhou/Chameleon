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
import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // The handler for the auth state listener, to allow cancelling later.
    var handle: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Set tap Gesture using handleTap()
        let tapGesture = UITapGestureRecognizer(target: self, action:
            #selector(ViewController.handleTap(gestureRecognize:)))
        view.addGestureRecognizer(tapGesture)
        
        print("I got here")
        
        // Sign in User with Firebase Auth
        if Auth.auth().currentUser != nil {
            print("User is already logged in anonymously with uid:" + Auth.auth().currentUser!.uid)
        } else {
            Auth.auth().signInAnonymously() { (user, error) in
                if error != nil {
                    print("This is the error msg:")
                    print(error!)
                    print("Here ends the error msg.")
                    return
                }
                
                // let isAnonymous = user!.isAnonymous  // true
                // let uid = user!.uid
                
                if user!.isAnonymous {
                    print("User has logged in anonymously with uid:" + user!.uid)
                }
                
            }
            
            
            // Code to set the user's displayName
//            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//            let displayName = "adias"
//            changeRequest?.displayName = displayName
//            changeRequest?.commitChanges { (error) in
//                if error != nil {
//                    print(error!)
//                    return
//                }
//                 print("The user's displayName has been added")
//            }
        }
        
        
        
    }
    
    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer){
        guard let currentFrame = sceneView.session.currentFrame else{
            return
        }
        
        // Create an image plane using a pre-selected picture
        let picture = UIImage(named: "sample")
        let imagePlane = SCNPlane(width: sceneView.bounds.width / 6000,
                                  height: sceneView.bounds.height / 6000)
        imagePlane.firstMaterial?.diffuse.contents = picture
        imagePlane.firstMaterial?.lightingModel = .constant
        
        // Create plane node to place image
        let planeNode = SCNNode(geometry: imagePlane)
        sceneView.scene.rootNode.addChildNode(planeNode)
        
        // Set transform of node to be 10cm in front of the camera, for now;
        // later change this to the plane directly in front of the camera
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        planeNode.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        
        
        // MARK: Andreas's Code
        
        var data = Data()
        data = UIImageJPEGRepresentation(picture!, 0.8)!
        
        var databaseRef: DatabaseReference!
        databaseRef = Database.database().reference()
        
        let storageRef = Storage.storage().reference()
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        let userID = Auth.auth().currentUser!.uid
        let picID = databaseRef.child("/pictures/\(userID)/").childByAutoId().key
        
        let picturesRef = storageRef.child("/pictures/\(userID)/\(picID)")
        
        let uploadTask = picturesRef.putData(data, metadata: metaData) { (metadata, error) in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error)
                return
            } else {
                // Metadata contains file metadata such as size, content-type, and download URL.
                let downloadURL = metadata!.downloadURL()!.absoluteString
                // format date type to string
                let date = metadata!.timeCreated!
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
                dateFormatter.locale = Locale(identifier: "en_US")
                let timeCreated = dateFormatter.string(from:date as Date)
                
                //store downloadURL at database
                let picture = ["downloadURL": downloadURL, "timeCreated": timeCreated]
                //            “location”:
                let childUpdates: [String: Any] = ["/pictures/\(userID)/\(picID)": picture, "/users/\(userID)/lastPicture": picID]
                databaseRef.updateChildValues(childUpdates)
            }
        }
        
        //-------------
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add Auth Listener for User Sign in State
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            // self.setTitleDisplay(user)
            // self.tableView.reloadData()
        }
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove Auth Listener for User Sign in State
        Auth.auth().removeStateDidChangeListener(handle!)
        
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
