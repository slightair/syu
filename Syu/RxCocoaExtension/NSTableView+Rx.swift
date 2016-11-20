import Foundation
import Cocoa
import RxSwift
import RxCocoa

public typealias WillDisplayCellEvent = (cell: Any, tableColumn: NSTableColumn?, row: Int)

extension Reactive where Base: NSTableView {
    func items<S: Sequence, O: ObservableType>
        (_ source: O)
        -> Disposable
        where O.E == S {
            let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S>()
            return self.items(dataSource: dataSource)(source)
    }

    func items<
        DataSource: RxTableViewDataSourceType & NSTableViewDataSource,
        O: ObservableType>
        (dataSource: DataSource)
        -> (_ source: O)
        -> Disposable
        where DataSource.Element == O.E {
            return { source in
                return source.subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource, retainDataSource: true) { [weak tableView = self.base] (_: RxTableViewDataSourceProxy, event) -> Void in
                    guard let tableView = tableView else {
                        return
                    }
                    dataSource.tableView(tableView, observedEvent: event)
                }
            }
    }
}

extension NSTableView {
    func createRxDataSourceProxy() -> RxTableViewDataSourceProxy {
        return RxTableViewDataSourceProxy(parentObject: self)
    }

    func createRxDelegateProxy() -> RxTableViewDelegateProxy {
        return RxTableViewDelegateProxy(parentObject: self)
    }
}

extension Reactive where Base: NSTableView {
    var dataSource: DelegateProxy {
        return RxTableViewDataSourceProxy.proxyForObject(base)
    }

    func setDataSource(_ dataSource: NSTableViewDataSource) -> Disposable {
        return RxTableViewDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self.base)
    }

    var delegate: DelegateProxy {
        return RxTableViewDelegateProxy.proxyForObject(base)
    }

    func setDelegate(_ delegate: NSTableViewDelegate) -> Disposable {
        return RxTableViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}
