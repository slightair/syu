import Cocoa

class ContentListViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var contentListView: NSOutlineView!

    var documentation: APIDocumentation! {
        didSet {
            documentation.test()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - NSOutlineViewDataSource

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 10
        } else {
            return 0
        }
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return 1
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    // MARK: - NSOutlineViewDelegate

    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let view = outlineView.make(withIdentifier: "ContentCell", owner: self) as? NSTableCellView
        if let textField = view?.textField {
            textField.stringValue = "hoge"
            textField.sizeToFit()
        }

        return view
    }
}
