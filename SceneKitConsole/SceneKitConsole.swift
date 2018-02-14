import SceneKit

class SceneKitConsole {
    let sceneView: SCNView
    
    init(attachTo sceneView: SCNView) {
        self.sceneView = sceneView
    }
    
    func run(command: String) {
        
    }
}

struct Command {
    let name: String
    let subcommands: [Command] = []
    let action: (SCNView, String...) -> Void
}

class CommandProvider {
    
}
