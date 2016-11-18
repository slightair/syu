import Cocoa
import RxSwift
import RxCocoa

class ContentListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    @IBOutlet weak var searchField: NSSearchField!
    @IBOutlet weak var contentListView: NSTableView!

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
            .bindTo(contentListView.rx.items(identifier: "ContentCell")) { (index, content: Content, view) in
                if let textField = view.textField {
                    textField.stringValue = "hoge"
                    textField.sizeToFit()
                }
            }
            .addDisposableTo(disposeBag)
    }
}
