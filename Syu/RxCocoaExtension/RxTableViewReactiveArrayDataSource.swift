import Foundation
import Cocoa
import RxSwift
import RxCocoa

class _RxTableViewReactiveArrayDataSource
    : NSObject
    , NSTableViewDataSource {

    func _numberOfRows(in tableView: NSTableView) -> Int {
        return 0
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return _numberOfRows(in: tableView)
    }
}

class RxTableViewReactiveArrayDataSourceSequenceWrapper<S: Sequence>
    : RxTableViewReactiveArrayDataSource<S.Iterator.Element>
    , RxTableViewDataSourceType {
    typealias Element = S

    func tableView(_ tableView: NSTableView, observedEvent: Event<S>) {
        UIBindingObserver(UIElement: self) { tableViewDataSource, models in
            tableViewDataSource.tableView(tableView, observedElements: Array(models))
        }.on(observedEvent)
    }
}

class RxTableViewReactiveArrayDataSource<Element>
    : _RxTableViewReactiveArrayDataSource {

    var itemModels: [Element]? = nil

    override func _numberOfRows(in tableView: NSTableView) -> Int {
        return itemModels?.count ?? 0
    }

    // reactive

    func tableView(_ tableView: NSTableView, observedElements: [Element]) {
        self.itemModels = observedElements
        tableView.reloadData()
    }
}
