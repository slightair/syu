import Cocoa

class DocumentViewerViewController: NSSplitViewController, ContentListViewControllerDelegate {
    @IBOutlet weak var contentListViewItem: NSSplitViewItem!
    @IBOutlet weak var mainContentViewItem: NSSplitViewItem!

    var documentation: APIDocumentation!

    var contentListViewController: ContentListViewController {
        guard let viewController = contentListViewItem.viewController as? ContentListViewController else {
            fatalError("Unexpected View Controller")
        }
        return viewController
    }

    var mainContentViewController: MainContentViewController {
        guard let viewController = mainContentViewItem.viewController as? MainContentViewController else {
            fatalError("Unexpected View Controller")
        }
        return viewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let documentation = APIDocumentation() else {
            print("API Documentation not found")
            return
        }
        self.documentation = documentation

        contentListViewController.documentation = documentation
        contentListViewController.delegate = self

        documentation.prepare {
            print("OK")
        }
    }

    // MARK: ContentListViewControllerDelegate

    func didSelectContent(requestKey: String) {
        mainContentViewController.content = documentation.responseData(of: requestKey)?.content
    }
}
