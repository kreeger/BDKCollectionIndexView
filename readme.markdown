# BDKCollectionIndexView

An index-title-scrubber-bar, for use with a `UICollectionView` or as a replacement for the one provided by a `UITableView`. Gives a collection/table view the index title bar for `-sectionIndexTitles` that a `UITableView` gets for (almost) free. A huge thank you to @Yang from [this Stack Overflow post][so], which saved my bacon here.

![gif](http://g.recordit.co/9vLag8rpPS.gif)

## Usage

To install it via [CocoaPods](http://cocoapods.org), just drop this line in your `Podfile`:

```ruby
pod 'BDKCollectionIndexView'
```

And then run `pod install`, naturally. After that, create an instance of `BDKCollectionIndexView`, and add it as a subview of whatever `view` contains your `tableView` or `collectionView` (but not the `tableView` or `collectionView` itself). Then assign it a `width` value of 28 (or `height`, if you're using it as a horizontal index view). Attach whatever other layout constraints you see fit!

```swift
override func viewDidLoad() {
    super.viewDidLoad()

    let indexWidth = 28
    let frame = CGRect(x: collectionView.frame.size.width - indexWidth,
        y: collectionView.frame.size.height,
        width: indexWidth,
        height: collectionView.frame.size.height)
    var indexView = BDKCollectionIndexView(frame: frame, indexTitles: nil)
    indexView.autoresizingMask = .FlexibleHeight | .FlexibleLeftMargin
    indexView.addTarget(self, action: "indexViewValueChanged:", forControlEvents: .ValueChanged)
    view.addSubview(indexView)
}

func indexViewValueChanged(sender: BDKCollectionIndexView) {
    let path = NSIndexPath(forItem: 0, inSection: sender.currentIndex)
    collectionView.scrollToItemAtIndexPath(path, atScrollPosition: .Top, animated: false)
    // If you're using a collection view, bump the y-offset by a certain number of points
    // because it won't otherwise account for any section headers you may have.
    collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x,
        y: collectionView.contentOffset.y - 45.0)
}
```

Then, when you have the section index titles (rather, the label values that you want to appear on the index bar), assign that array to the index bar instance's `indexTitles` value.

```swift
self.indexView.indexTitles = self.resultsController.sectionIndexTitles
```

You can modify `backgroundColor` and `touchStatusBackgroundColor` property to change the background color of the "touch status view" that appears when the view is touched. Use `tintColor` of `BDKCollectionIndexView` instance to change the color of text labels.

Again, big thanks to @Yang for [the solution on which this is based][so].

## Please...

If you use this in your project, drop me a line and let me know! I'd love to hear about it. You can hit me up [via email](mailto:benjaminkreeger@gmail.com), on [Twitter](https://twitter.com/kreeger), or [carrier pigeon](http://www.phonemag.com/blog/wp-content/uploads/2009/04/pigeon_camera2.jpg).

[so]:      http://stackoverflow.com/a/14443540/194869
[pst]:     https://github.com/steipete/PSTCollectionView
[ya]:      http://stackoverflow.com/users/45018/yang
[gst]:     https://gist.github.com/kreeger/4755877

## Contact

- [Ben Kreeger](https://github.com/kreeger)

## Contributors

- [Adrian Maurer](https://github.com/VerticodeLabs)
- [hipwelljo](https://github.com/hipwelljo)
- [Alex Skorulis](https://github.com/skorulis)
- [Rinat Khanov](https://github.com/rinatkhanov)
- [huperniketes](https://github.com/huperniketes)
