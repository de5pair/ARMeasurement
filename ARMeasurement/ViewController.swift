//
//  ViewController.swift
//  ARMeasurement
//
//  Created by Boris Alexis Gonzalez Macias on 11/25/17.
//  Copyright © 2017 Boris Alexis Gonzalez Macias. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    let configuration = ARWorldTrackingConfiguration()
    var startingPosition : SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
        self.sceneView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let startingPosition = self.startingPosition else { return }
        guard let pointOfView = self.sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        DispatchQueue.main.async {
            self.xLabel.text = String(format: "%.2f", xDistance) + " m"
            self.yLabel.text = String(format: "%.2f", yDistance) + " m"
            self.zLabel.text = String(format: "%.2f", zDistance) + " m"
            self.distanceLabel.text = String(format: "%.2f", self.distance(x: xDistance, y: yDistance, z: zDistance)) + " m"
        }
    }

    
    @objc func handleTap(sender: UITapGestureRecognizer){
        guard let sceneView = sender.view as? ARSCNView else { return }
        guard let currentFrame = sceneView.session.currentFrame else { return }
        if self.startingPosition != nil {
            self.startingPosition?.removeFromParentNode()
            self.startingPosition = nil
            return
        }
        let camera = currentFrame.camera
        let transform = camera.transform
        let sphere = SCNNode(geometry: SCNSphere(radius: 0.005))
        sphere.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        sphere.simdTransform = transform
        self.sceneView.scene.rootNode.addChildNode(sphere)
        self.startingPosition = sphere
    }
    
    func distance(x: Float, y: Float, z: Float) -> Float {
        
        return (sqrtf(x*x + y*y + z*z))
    }
}

