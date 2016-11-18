import Foundation
import Cocoa
import RxSwift
import RxCocoa

public typealias WillDisplayCellEvent = (cell: Any, tableColumn: NSTableColumn?, row: Int)

extension Reactive where Base: NSTableView {
    public func items<S: Sequence, O: ObservableType>
        (_ source: O)
        -> Disposable
        where O.E == S {
            return { viewFactory in
                let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S>(viewFactory: viewFactory)
                return self.items(dataSource: dataSource)(source)
            }
    }

    public func items<S: Sequence, View: NSTableCellView, O : ObservableType>
        (identifier: String, viewType: View.Type = View.self)
        -> (_ source: O)
        -> (_ configureView: @escaping (Int, S.Iterator.Element, View) -> Void)
        -> Disposable
        where O.E == S {
            return { source in
                return { configureView in
                    let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S> { (tv, i, item) in
                        tv.make(withIdentifier: identifier, owner: self) as! View
                        configureView(i, item, view)
                        return cell
                    }
                    return self.items(dataSource: dataSource)(source)
                }
            }
    }

    public func items<
        DataSource: RxTableViewDataSourceType & NSTableViewDataSource,
        O: ObservableType>
        (dataSource: DataSource)
        -> (_ source: O)
        -> Disposable
        where DataSource.Element == O.E {
            return { source in
                _ = self.delegate
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
    public func createRxDelegateProxy() -> RxTableViewDelegateProxy {
        return RxTableViewDelegateProxy(parentObject: self)
    }

    public func createRxDataSourceProxy() -> RxTableViewDataSourceProxy {
        return RxTableViewDataSourceProxy(parentObject: self)
    }
}

extension Reactive where Base: NSTableView {
    public var dataSource: DelegateProxy {
        return RxTableViewDataSourceProxy.proxyForObject(base)
    }

    public func setDataSource(_ dataSource: NSTableViewDataSource) -> Disposable {
        return RxTableViewDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self.base)
    }

    // events

//    public var itemSelected: ControlEvent<IndexPath> {
//        let source = self.delegate.methodInvoked(#selector(UITableViewDelegate.tableView(_:didSelectRowAt:)))
//            .map { a in
//                return try castOrThrow(IndexPath.self, a[1])
//        }
//
//        return ControlEvent(events: source)
//    }
//
//    public var itemDeselected: ControlEvent<IndexPath> {
//        let source = self.delegate.methodInvoked(#selector(UITableViewDelegate.tableView(_:didDeselectRowAt:)))
//            .map { a in
//                return try castOrThrow(IndexPath.self, a[1])
//        }
//
//        return ControlEvent(events: source)
//    }
//
//    public var willDisplayCell: ControlEvent<WillDisplayCellEvent> {
//        let source: Observable<WillDisplayCellEvent> = self.delegate.methodInvoked(#selector(NSTableViewDelegate.tableView(_:willDisplayCell:for:row:))
//            .map { a in
//                return (try castOrThrow(Any.self, a[1]), try castOrThrow(NSTableColumn?.self, a[2]), try castOrThrow(Int.self, a[3]))
//        }
//
//        return ControlEvent(events: source)
//    }
}
