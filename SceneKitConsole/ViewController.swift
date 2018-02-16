import UIKit
import SceneKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var sceneView: SCNView!
    
    var console: SceneKitConsole!
    let scene = MyScene()

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        console = SceneKitConsole(attachTo: sceneView, commandProvider: CommandProvider.Builder().addStandardCommands().build())
        scene.setup()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        console.run(command: textField.text!)
        return true
    }
}

