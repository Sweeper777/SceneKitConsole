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
        let image = UIImage(named: "my_image")!
        scene.background.contents = image
        sceneView.scene = scene
        sceneView.autoenablesDefaultLighting = true
        sceneView.backgroundColor = .black
        sceneView.showsStatistics = true
        sceneView.backgroundColor = .black
        sceneView.pointOfView = scene.cameraNode
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        switch console.run(command: textField.text!) {
        case .ok:
            break
        case .error(let msg):
            let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        case .output(let msg):
            let alert = UIAlertController(title: "Output", message: msg, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        return true
    }
}

