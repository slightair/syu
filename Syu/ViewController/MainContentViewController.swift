import Cocoa
import WebKit
import Mustache

class MainContentViewController: NSViewController {
    @IBOutlet weak var webView: WebView!

    var content: Content? {
        didSet {
            updateContentView()
        }
    }

    let contentBaseURL = Bundle.main.resourceURL!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateContentView() {
        webView.mainFrame.loadHTMLString(makeHTMLString(), baseURL: contentBaseURL)
    }

    func makeHTMLString() -> String {
        guard let content = content else {
            return "<h1>No content</h1>"
        }

        do {
            let template = try Template(named: "document")
            return try template.render(content)
        } catch let error as MustacheError {
            let template = try! Template(string: "<h1>Rendering error</h1><p>{{description}}</p>")
            let rendering = try? template.render([
                "description": error.description,
            ])
            return rendering ?? "<h1>Rendering error</h1>"
        } catch {
            return "<h1>Unknown error</h1>"
        }
    }
}
