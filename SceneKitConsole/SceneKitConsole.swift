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

enum CommandResult {
    case ok
    case error(String)
}

struct Command {
    let name: String
    let argumentCount: Int?
    let subcommands: [Command]
    let action: (SCNView, [String]) -> CommandResult
}

class CommandProvider {
    
}
