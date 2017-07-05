//
//  Picture.swift
//  Chameleon
//
//  Created by Andrew Jay Zhou on 7/5/17.
//  Copyright © 2017 Andrew Jay Zhou. All rights reserved.
//

import Foundation
import ARKit
import SceneKit

class Picture: SCNNode {
    
    var fileName: String = ""
    var width: CGFloat?
    var height: CGFloat?
    var sceneView: ARSCNView?
    
    var viewController: ViewController?
    
    override init() {
        super.init()
        self.name = "Picture root node"
    }
    
    init(fileName: String, width: CGFloat, height: CGFloat){
        super.init()
        self.name = "Picture root node"
        self.fileName = fileName
        self.width = width
        self.height = height
        
        // Create an image plane using a pre-selected picture
        let picture = UIImage(named: fileName)
        
        // Change size of image here
        // ViewController.sceneView.bounds.width / 7000
        let imagePlane = SCNPlane(width: width,height: height)
        imagePlane.firstMaterial?.diffuse.contents = picture
        imagePlane.firstMaterial?.lightingModel = .constant
        
        self.geometry = imagePlane
        
    }
    
    // do not know what this is, but I think I need to add this
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

