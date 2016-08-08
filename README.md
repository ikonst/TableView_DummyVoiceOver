This project demonstrates a strange behavior of UITableViewCell.
When a cell is subclassed, VoiceOver will stop over it when enumerating screen elements,
even when the cell is empty (i.e. no subviews in the content view).

Screencap:
https://youtu.be/dwyCeS52H_o

The underlying reason seems to be:
```swift
cell.accessibilityElementCount() == 1 &&
cell.accessibilityElementAtIndex(0)?.accessibilityLabel == " "
```

For cells with `UILabel`s, `UITableViewCell` creates a `UITableTextAccessibilityElement` (private class)
which joins the labels, e.g. for a cell with label "Meow" and label "Woof", a single element is created
with `accessibilityLabel == "Meow, Woof"`. This behavior seems desired.

Enable VoiceOver, launch the demo and enumerate cells by swiping:

1. First cell (not subclassed, empty) is skipped since it is not subclassed.
1. Second cell (subclassed, empty) is enumerated.
1. Third cell (subclassed, not empty) is enumerated, and it's OK.
