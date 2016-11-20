import Cocoa
import RxSwift
import RxCocoa

class ContentListViewController: NSViewController, NSTableViewDelegate {
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var contentListView: NSTableView!

    var documentation: APIDocumentation!
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpSubscriptions()
    }

    private func setUpSubscriptions() {
        contentListView.rx.setDelegate(self)
            .addDisposableTo(disposeBag)

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
            .bindTo(contentListView.rx.items)
            .addDisposableTo(disposeBag)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = contentListView.make(withIdentifier: "ContentCell", owner: self) as? NSTableCellView

        guard let content = tableView.dataSource?.tableView!(tableView, objectValueFor: tableColumn, row: row) as? Content else {
            return nil
        }

        if let textField = view?.textField {
            textField.stringValue = content.referencePath
            textField.sizeToFit()
        }
        return view
    }
}
