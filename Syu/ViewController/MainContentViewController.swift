import Cocoa
import WebKit

class MainContentViewController: NSViewController {
    @IBOutlet weak var webView: WebView!

    var content: ResponseData? {
        didSet {
            updateContentView()
        }
    }

    let contentBaseURL = Bundle.main.bundleURL

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func updateContentView() {
        webView.mainFrame.loadHTMLString(content?.description, baseURL: contentBaseURL)
    }
}
