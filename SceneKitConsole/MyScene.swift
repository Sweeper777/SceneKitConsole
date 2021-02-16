import SceneKit

class MyScene: SCNScene {
    var cameraNode: SCNNode!
    
    func setup() {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
    }
}
