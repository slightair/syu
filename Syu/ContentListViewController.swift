import Cocoa
import RxSwift
import RxCocoa

class ContentListViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate {
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var contentListView: NSOutlineView!

    var documentation: APIDocumentation!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSubscriptions()
    }

    private func setUpSubscriptions() {
        searchField.rx.text.throttle(0.3, scheduler: MainScheduler.instance)
            .distinctUntilChanged { lhs, rhs in
                lhs == rhs
            }
            .flatMapLatest { keyword -> Observable<[Content]> in
                guard let keyword = keyword, !keyword.isEmpty else {
                    return .just([])
                }
                return self.documentation.searchContents(keyword: keyword).catchErrorJustReturn([])
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { contents in
                print(contents)
            }).addDisposableTo(disposeBag)
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
