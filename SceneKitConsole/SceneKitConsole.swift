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
    case output(String)
}

struct Command {
    let name: String
    let argumentCount: Int?
    let subcommands: [Command]
    let action: (SCNView, [String]) -> CommandResult
    
    fileprivate static let invalidArguments = "Aguments are invalid!"
    fileprivate static let missingArguments = "Arguments expected!"
    fileprivate static let cannotFindNode = "Cannot find the node specified!"
    fileprivate static let invalidCommand = "Unknown command!"
}

class CommandProvider {
    let commands: [Command]
    private init(commands: [Command]) {
        self.commands = commands
    }
    
    class Builder {
        var commands: [Command] = []
        
        func addCommand(_ command: Command) -> Builder {
            commands.append(command)
            return self
        }
        
        func addStandardCommands() -> Builder {
            return self
        }
        
        func build() -> CommandProvider {
            return CommandProvider(commands: commands)
        }
    }
}
