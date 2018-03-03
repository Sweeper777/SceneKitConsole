import SceneKit

class SceneKitConsole {
    let sceneView: SCNView
    let commandProvider: CommandProvider
    
    init(attachTo sceneView: SCNView, commandProvider: CommandProvider) {
        self.sceneView = sceneView
        self.commandProvider = commandProvider
    }
    
    func run(command: String) -> CommandResult {
        guard let _ = sceneView.scene else { return .error("Scene has not been initialized!") }
        
        let components = command.split(separator: " ").map { String($0) }
        var commandToRun: Command?
        for component in components {
            let commandsToSearch = commandToRun?.subcommands ?? commandProvider.commands
            if let i = commandsToSearch.index(where: { $0.name == component }) {
                commandToRun = commandsToSearch[i]
            } else {
                break
            }
        }
        guard let cmd = commandToRun else { return .error(Command.invalidCommand) }
        guard let argsCount = cmd.argumentCount else { return .error(Command.invalidCommand) }
        if components.count - 1 < argsCount {
            return .error(Command.missingArguments)
        }
        return cmd.action(sceneView, Array(components.suffix(argsCount)))
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
            let spawnBox = Command(name: "box", argumentCount: 5, subcommands: []){ (view, args) -> CommandResult in
                guard
                    let w = Double(args[0]),
                    let h = Double(args[1]),
                    let l = Double(args[2]),
                    let r = Double(args[3]),
                    let name = args.last else
                    { return .error(Command.invalidArguments)}
                let node = SCNNode(geometry: SCNBox(width: CGFloat(w), height: CGFloat(h), length: CGFloat(l), chamferRadius: CGFloat(r)))
                node.name = name
                view.scene!.rootNode.addChildNode(node)
                return .ok
            }
            
            let spawnSphere = Command(name: "sphere", argumentCount: 2, subcommands: []) { (view, args) -> CommandResult in
                guard let r = Double(args[0]),
                      let name = args.last else { return .error(Command.invalidArguments)}
                let node = SCNNode(geometry: SCNSphere(radius: CGFloat(r)))
                node.name = name
                view.scene!.rootNode.addChildNode(node)
                return .ok
            }
            
            let spawn = Command(name: "spawn", argumentCount: nil, subcommands: [spawnBox, spawnSphere], action:
                {(_,_) in return .error(Command.missingArguments)})
            
            let remove = Command(name: "remove", argumentCount: 1, subcommands: []) { (view, args) -> CommandResult in
                guard let name = args.first else { return .error(Command.invalidArguments) }
                guard let node = view.scene?.rootNode.childNode(withName: name, recursively: true) else { return .error(Command.cannotFindNode) }
                node.removeFromParentNode()
                return .ok
            }
            
            let setPosition = Command(name: "set", argumentCount: 4, subcommands: []) { (view, args) -> CommandResult in
                guard
                    let x = Float(args[1]),
                    let y = Float(args[2]),
                    let z = Float(args[3]),
                    let name = args.first else
                { return .error(Command.invalidArguments)}
                guard let node = view.scene?.rootNode.childNode(withName: name, recursively: true) else { return .error(Command.cannotFindNode) }
                node.position.x = x
                node.position.y = y
                node.position.z = z
                return .ok
            }
            let changePosition = Command(name: "change", argumentCount: 4, subcommands: []) { (view, args) -> CommandResult in
                guard
                    let x = Float(args[1]),
                    let y = Float(args[2]),
                    let z = Float(args[3]),
                    let name = args.first else
                { return .error(Command.invalidArguments)}
                guard let node = view.scene?.rootNode.childNode(withName: name, recursively: true) else { return .error(Command.cannotFindNode) }
                node.position.x += x
                node.position.y += y
                node.position.z += z
                return .ok
            }
            
            let position = Command(name: "position", argumentCount: 1, subcommands: [changePosition, setPosition]) { (view, args) -> CommandResult in
                guard let node = view.scene!.rootNode.childNode(withName: args[0], recursively: true) else { return .error(Command.cannotFindNode) }
                return .output("\(node.position)")
            }
            
            let color = Command(name: "color", argumentCount: 4, subcommands: []) { (view, args) -> CommandResult in
                guard let node = view.scene?.rootNode.childNode(withName: args[0], recursively: true) else { return .error(Command.cannotFindNode) }
                guard
                    let r = Float(args[1]),
                    let g = Float(args[2]),
                    let b = Float(args[3]) else
                { return .error(Command.invalidArguments)}
                let chosenColor = UIColor(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
                node.geometry?.firstMaterial?.diffuse.contents = chosenColor
                return .ok
            }
            
            let lightRemove = Command(name: "remove", argumentCount: 1, subcommands: []) { (view, args) -> CommandResult in
                guard let name = args.first else { return .error(Command.invalidArguments) }
                guard let node = view.scene?.rootNode.childNode(withName: name, recursively: true) else { return .error(Command.cannotFindNode) }
                node.light = nil
                return .ok
            }
            
            let light = Command(name: "light", argumentCount: 2, subcommands: [lightRemove]) { (view, args) -> CommandResult in
                guard let node = view.scene?.rootNode.childNode(withName: args[0], recursively: true) else { return .error(Command.cannotFindNode) }
                let lightObj = node.light ?? SCNLight()
                let lightType = SCNLight.LightType(rawValue: args[1])
                lightObj.type = lightType
                node.light = lightObj
                return .ok
            }
            
            let physicsType = Command(name: "type", argumentCount: 2, subcommands: []) { (view, args) -> CommandResult in
                guard let node = view.scene?.rootNode.childNode(withName: args[0], recursively: true) else { return .error(Command.cannotFindNode) }
                func setNodePhysicsType(_ node: SCNNode, _ type: SCNPhysicsBodyType) {
                    if let physics = node.physicsBody {
                        physics.type = type
                    } else {
                        node.physicsBody = SCNPhysicsBody(type: type, shape: nil)
                    }
                }
                switch args[1] {
                case "static":
                    setNodePhysicsType(node, .static)
                case "dynamic":
                    setNodePhysicsType(node, .dynamic)
                case "kinematic":
                    setNodePhysicsType(node, .kinematic)
                default:
                    return .error(Command.invalidArguments)
                }
                return .ok
            }
            
            let physcisRemove = Command(name: "remove", argumentCount: 1, subcommands: []) { (view, args) -> CommandResult in
                guard let name = args.first else { return .error(Command.invalidArguments) }
                guard let node = view.scene?.rootNode.childNode(withName: name, recursively: true) else { return .error(Command.cannotFindNode) }
                node.physicsBody = nil
                return .ok
            }
            
            let physics = Command(name: "physics", argumentCount: nil, subcommands: [physicsType, physcisRemove]) { (_, _) -> CommandResult in
                return .error(Command.missingArguments)
            }
            
            let force = Command(name: "force", argumentCount: 5, subcommands: []) { (view, args) -> CommandResult in
                guard
                    let name = args.first,
                    let x = Double(args[1]),
                    let y = Double(args[2]),
                    let z = Double(args[3]),
                    let asImpulse = args.last
                    else { return .error(Command.invalidArguments) }
                guard let node = view.scene?.rootNode.childNode(withName: name, recursively: true) else { return .error(Command.cannotFindNode) }
                switch asImpulse {
                case "impulse":
                    node.physicsBody?.applyForce(SCNVector3(x,y,z), asImpulse: true)
                case "continuous":
                    node.physicsBody?.applyForce(SCNVector3(x,y,z), asImpulse: false)
                default:
                    return .error(Command.invalidArguments)
                }
                return .ok
            }
            return self
                .addCommand(spawn)
                .addCommand(remove)
                .addCommand(position)
                .addCommand(color)
                .addCommand(light)
                .addCommand(physics)
        }
        
        func build() -> CommandProvider {
            return CommandProvider(commands: commands)
        }
    }
}
