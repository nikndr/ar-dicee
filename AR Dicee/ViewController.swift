//
//  ViewController.swift
//  AR Dicee
//
//  Created by Nikandr Margal on 2/14/19.
//  Copyright © 2019 Nikandr Margal. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!

	var dices = [SCNNode]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.showsStatistics = true
		sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
		configuration.planeDetection = .horizontal

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let touch = touches.first {
			let touchLocation = touch.location(in: sceneView)
			let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
			if let hitResult = results.first {
				addDice(at: hitResult)
			}
		}
	}

	func addDice(at location: ARHitTestResult) {
		let scene = SCNScene(named: "art.scnassets/diceCollada.scn")!
		if let diceNode = scene.rootNode.childNode(withName: "Dice", recursively: true) {
			diceNode.position = SCNVector3(
				location.worldTransform.columns.3.x,
				location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
				location.worldTransform.columns.3.z
			)
			dices.append(diceNode)
			sceneView.scene.rootNode.addChildNode(diceNode)
			diceNode.roll()
		}
	}

	func removeAll() {
		dices.forEach { $0.removeFromParentNode() }
	}

	func rollAll() {
		dices.forEach { $0.roll() }
	}

	func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
		guard let anchor = anchor as? ARPlaneAnchor else { return }
		let planeNode = createPlane(withAnchor: anchor)
		node.addChildNode(planeNode)
	}

	func createPlane(withAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
		let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
		let planeNode = SCNNode()
		planeNode.position = SCNVector3(planeAnchor.center.x, 0, planeAnchor.center.z)
		planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
		let gridMaterial = SCNMaterial()
		gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
		plane.materials = [gridMaterial]
		planeNode.geometry = plane
		return planeNode
	}

	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		rollAll()
	}

	@IBAction func rollAgain(_ sender: UIBarButtonItem) {
		rollAll()
	}
	
	@IBAction func removeAllDice(_ sender: UIBarButtonItem) {
		removeAll()
	}
}

extension SCNNode {
	func roll() {
		let randomX = Float(arc4random_uniform(4)+1) * Float.pi/2
		let randomZ = Float(arc4random_uniform(4)+1) * Float.pi/2
		runAction(
			SCNAction.rotateBy(
				x: CGFloat(randomX),
				y: 0,
				z: CGFloat(randomZ),
				duration: 0.5)
		)
	}
}
