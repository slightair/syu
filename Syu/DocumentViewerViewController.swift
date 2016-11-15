import Cocoa

class DocumentViewerViewController: NSSplitViewController {
    @IBOutlet weak var contentListViewItem: NSSplitViewItem!
    @IBOutlet weak var mainContentViewItem: NSSplitViewItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let documentation = APIDocumentation() else {
            print("API Documentation not found")
            return
        }
        print(documentation.resourcesPath)

        if let contentListViewController = contentListViewItem.viewController as? ContentListViewController {
            contentListViewController.documentation = documentation
        }
    }
}
