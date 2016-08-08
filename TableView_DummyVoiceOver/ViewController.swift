import UIKit

var workaroundDummyVoiceOver = false

class CustomCell: UITableViewCell {
    override func accessibilityElementCount() -> Int {
        let count = super.accessibilityElementCount()

        if !workaroundDummyVoiceOver {
            return count
        }

        if count == 1 && self.accessibilityElementAtIndex(0)?.accessibilityLabel == " " {
            return 0
        }

        return count
    }
}

class ViewController: UITableViewController {

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        if workaroundDummyVoiceOver {
            return // our assertions will fail since workaround is enabled
        }

        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            assert(cell.dynamicType == UITableViewCell.self)
            // Non-subclassed UITableViews don't exhibit the dummy accessibility label behavior:
            // When they're empty, they're skipped in VO
            assert(cell.accessibilityElementCount() == 0)
        case (0, 1):
            assert(cell.dynamicType == CustomCell.self)
            // On Simulator, behavior depends on whether Accessibility Inspector is enabled, and even then,
            // it's different from device (i.e. accessibilityLabel == nil).
            #if !arch(i386) && !arch(x86_64)
                // This cell has no children, yet label is " ", making VO stop on it.
                assert(
                    cell.accessibilityElementCount() == 1 &&
                    cell.accessibilityElementAtIndex(0)?.accessibilityLabel == " "
                )
            #endif
        case (0, 2):
            assert(cell.dynamicType == CustomCell.self)
            #if !arch(i386) && !arch(x86_64)
                // This behavior is OK.
                assert(
                    cell.accessibilityElementCount() == 1 &&
                    cell.accessibilityElementAtIndex(0)?.accessibilityLabel == "Meow, Woof"
                )
            #endif
        default:
            break
        }
    }

    @IBAction func toggleWorkaroundTapped(sender: AnyObject) {
        workaroundDummyVoiceOver = !workaroundDummyVoiceOver
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil)
    }
}

