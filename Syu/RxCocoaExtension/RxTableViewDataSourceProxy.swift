import Foundation
import Cocoa
import RxCocoa

let tableViewDataSourceNotSet = TableViewDataSourceNotSet()

class TableViewDataSourceNotSet
    : NSObject
    , NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return 0
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return nil
    }
}

/// For more information take a look at `DelegateProxyType`.
public class RxTableViewDataSourceProxy
    : DelegateProxy
    , NSTableViewDataSource
    , DelegateProxyType {

    /// Typed parent object.
    public weak private(set) var tableView: NSTableView?

    fileprivate weak var _requiredMethodsDataSource: NSTableViewDataSource? = tableViewDataSourceNotSet

    public required init(parentObject: AnyObject) {
        self.tableView = (parentObject as! NSTableView)
        super.init(parentObject: parentObject)
    }

    // MARK: delegate

    /// Required delegate method implementation.
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).numberOfRows!(in: tableView)
    }

    /// Required delegate method implementation.
    public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return (_requiredMethodsDataSource ?? tableViewDataSourceNotSet).tableView!(tableView, objectValueFor: tableColumn, row: row)
    }

    // MARK: delegate proxy

    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let tableView = (object as! NSTableView)
        return castOrFatalError(tableView.createRxDataSourceProxy())
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tableView: NSTableView = castOrFatalError(object)
        tableView.dataSource = castOptionalOrFatalError(delegate)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tableView: NSTableView = castOrFatalError(object)
        return tableView.dataSource
    }

    /// For more information take a look at `DelegateProxyType`.
    public override func setForwardToDelegate(_ forwardToDelegate: AnyObject?, retainDelegate: Bool) {
        let requiredMethodsDataSource: NSTableViewDataSource? = castOptionalOrFatalError(forwardToDelegate)
        _requiredMethodsDataSource = requiredMethodsDataSource ?? tableViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}
