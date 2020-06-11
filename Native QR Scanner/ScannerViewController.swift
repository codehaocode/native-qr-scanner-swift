//
//  ViewController.swift
//  Native QR Scanner
//
//  Created by Yuhao Zhong on 11.06.20.
//  Copyright © 2020 Yuhao Zhong. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ScannerViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
 
    weak var focusFrameView: FocusFrameView!
    
    @IBOutlet var instructionLabel: UILabel!
    
    
    var qrCodeDetected = false
    var qrCodeValue: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        sceneView.autoenablesDefaultLighting = true

        addFocusFrame()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    func addFocusFrame() {

        let focusFrameView = FocusFrameView(frame: view.bounds)
        view.addSubview(focusFrameView)
        self.focusFrameView = focusFrameView
        focusFrameView.show()
        
    }

    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        if qrCodeDetected {
            let floor = createFloor(planeAnchor: planeAnchor)
            node.addChildNode(floor)
            if qrCodeValue == "sphere" {
                let sphere = createSphere()
                floor.addChildNode(sphere)
            } else if qrCodeValue == "cube" {
                let cube = createCube()
                floor.addChildNode(cube)
            } else {
                print("Nothing")
            }
            qrCodeDetected = false
        }
    }
    
    
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let node = SCNNode()
        
        let geometry = SCNPlane(width: 0.1, height: 0.1)
        node.geometry = geometry
        node.eulerAngles.x = -Float.pi / 2
        
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func createCube() -> SCNNode {
        let box = SCNBox(width: 0.2, height: 0.2, length: 0.2, chamferRadius: 0.0)
        box.firstMaterial?.diffuse.contents = UIColor.green
        let node = SCNNode(geometry: box)
        return node
    }

    func createSphere() -> SCNNode {
        let sphere = SCNSphere(radius: 0.2)
        sphere.firstMaterial?.diffuse.contents = UIColor.blue
        let node = SCNNode(geometry: sphere)
        return node
    }
}




extension ScannerViewController {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {


    guard let currentFrame = sceneView.session.currentFrame else { return }

    DispatchQueue.global(qos: .background).async {
      do {
        let request = VNDetectBarcodesRequest { (request, error) in

          guard let results = request.results?.compactMap({ $0 as? VNBarcodeObservation }), let result = results.first else {
            print ("[Vision] VNRequest produced no result")
            return
          }
            self.qrCodeDetected = true
            self.qrCodeValue = result.payloadStringValue ?? "Nothing"

            print(self.qrCodeValue ?? "nothing")

          DispatchQueue.main.async {
            self.instructionLabel.text = "A \(result.payloadStringValue ?? "new object") detected, find a floor to place it"
            self.instructionLabel.isHighlighted.toggle()

            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage)
        try handler.perform([request])
      } catch(let error) {
        print("An error occurred during qr code detection: \(error)")
      }
    }
  }
}

    
