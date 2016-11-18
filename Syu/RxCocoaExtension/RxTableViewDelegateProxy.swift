import Foundation
import Cocoa
import RxCocoa

/// For more information take a look at `DelegateProxyType`.
public class RxTableViewDelegateProxy
    : DelegateProxy
    , NSTableViewDelegate {

    /// Typed parent object.
    public weak private(set) var tableView: NSTableView?

    public required init(parentObject: AnyObject) {
        self.tableView = (parentObject as! NSTableView)
        super.init(parentObject: parentObject)
    }
}
