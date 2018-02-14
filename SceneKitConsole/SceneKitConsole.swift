import SceneKit

class SceneKitConsole {
    let sceneView: SCNView
    let commandProvider: CommandProvider
    
    init(attachTo sceneView: SCNView, commandProvider: CommandProvider) {
        self.sceneView = sceneView
        self.commandProvider = commandProvider
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
