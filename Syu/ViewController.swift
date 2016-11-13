import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let doc = APIDocumentation() else {
            print("API Documentation not found")
            return
        }
        print(doc.resourcesPath)

        doc.test()
    }
}
