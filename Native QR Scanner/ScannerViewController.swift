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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addFocusFrame()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .camera

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func addFocusFrame(){

        let focusFrameView = FocusFrameView(frame: view.bounds)
        view.addSubview(focusFrameView)
        self.focusFrameView = focusFrameView
        focusFrameView.show()
        
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

            print(result.payloadStringValue)

          let coordinates: [matrix_float4x4] = [result.topLeft, result.topRight, result.bottomRight, result.bottomLeft].compactMap {
            guard let hitFeature = currentFrame.hitTest($0, types: .featurePoint).first else { return nil }
            return hitFeature.worldTransform
          }
          
          guard coordinates.count == 4 else { return }
          
          DispatchQueue.main.async {
            
            for coordinate in coordinates {
              let box = SCNBox(width: 0.01, height: 0.01, length: 0.001, chamferRadius: 0.0)
              let node = SCNNode(geometry: box)
              node.transform = SCNMatrix4(coordinate)
              self.sceneView.scene.rootNode.addChildNode(node)
            }
            
          }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage)
        try handler.perform([request])
      } catch(let error) {
        print("An error occurred during rectangle detection: \(error)")
      }
    }
  }
}
//}
//}
    
