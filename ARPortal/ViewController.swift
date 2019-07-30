//
//  ViewController.swift
//  ARPortal
//
//  Created by JiniGuruiOS on 30/07/19.
//  Copyright © 2019 jiniguru. All rights reserved.
//

import UIKit
import ARKit
class ViewController: UIViewController {

    @IBOutlet weak var lblPlaneDetect: UILabel!
    @IBOutlet weak var scenView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configuration.planeDetection = .horizontal
        self.scenView.session.run(configuration)
        self.scenView.debugOptions = [.showFeaturePoints,.showWorldOrigin]
        self.scenView.delegate = self
        let tapguestureReco = UITapGestureRecognizer.init(target: self, action: #selector(handleTap(sender:)))
        self.scenView.addGestureRecognizer(tapguestureReco)
        // Do any additional setup after loading the view.
    }

    @objc func handleTap(sender:UITapGestureRecognizer) {
        guard let scenView = sender.view as? ARSCNView else {
            return
        }
        let location = sender.location(in: scenView)
        let hitTestResult = scenView.hitTest(location, types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            print("Add room")
            self.addPortal(hitTestResult: hitTestResult.first!)
        }else {
            print("Plane not detect")
        }
        
    }
    
    func addPortal(hitTestResult:ARHitTestResult){
        let scnPortal = SCNScene.init(named: "Portal.scnassets/portal.scn")
        let portalNode = scnPortal?.rootNode.childNode(withName: "Portal", recursively: false)
        let transform = hitTestResult.worldTransform
        let xPosition = transform.columns.3.x
        let yPosition = transform.columns.3.y
        let zPosition = transform.columns.3.z
        portalNode?.position = SCNVector3(xPosition, yPosition, zPosition)
        self.scenView.scene.rootNode.addChildNode(portalNode!)
        self.hideMask(nodeName: "DoorLeft", portalNode: portalNode!)
        self.hideMask(nodeName: "DoorRight", portalNode: portalNode!)
        self.hideMask(nodeName: "WallLeft", portalNode: portalNode!)
        self.hideMask(nodeName: "WallRight", portalNode: portalNode!)
    }
    
    func hideMask(nodeName:String, portalNode:SCNNode) {
        let childNode = portalNode.childNode(withName: nodeName, recursively: true)
        childNode?.renderingOrder = 200
        
        if let mask = childNode?.childNode(withName: "mask", recursively: true) {
            mask.geometry?.firstMaterial?.transparency = 0.00001
        }
        
    }
}

extension ViewController:ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        
        DispatchQueue.main.async {
            self.lblPlaneDetect.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.lblPlaneDetect.isHidden = true
        }
    }
}
