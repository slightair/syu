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
            .flatMapLatest { keyword -> Observable<[SearchIndex]> in
                guard let keyword = keyword, !keyword.isEmpty else {
                    return .just([])
                }
                return self.documentation.search(keyword: keyword).catchErrorJustReturn([])
            }
            .observeOn(MainScheduler.instance)
            .bindTo(contentListView.rx.items)
            .addDisposableTo(disposeBag)
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = contentListView.make(withIdentifier: "ContentCell", owner: self) as? NSTableCellView

        guard let index = tableView.dataSource?.tableView!(tableView, objectValueFor: tableColumn, row: row) as? SearchIndex else {
            return nil
        }

        if let textField = view?.textField {
            textField.stringValue = index.name
            textField.sizeToFit()
        }
        return view
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tableView = notification.object as? NSTableView {
            guard let index = tableView.dataSource?.tableView!(tableView, objectValueFor: nil, row: tableView.selectedRow) as? SearchIndex else {
                return
            }

            if let data = documentation.responseData(from: index.requestKey) {
                print(data)
            }
        }
    }
}
