# FZQuicklook


Create previews of files presented either in a panel similar to Finder's Quicklook or in a view.

## QuicklookPreviewable
 A protocol that defines a set of properties you implement to make a preview that can be displayed by `QuicklookPanel` and `QuicklookView`. `URL`, `NSURL` and `AVURLAsset` conform to QuicklookPreviewable.
 ```
 struct GalleryItem: QuicklookPreviewable {
 let title: String
 let imageURL: URL
 
 var previewItemURL: URL? {
    return imageURL
 }
 
 var previewItemTitle: String? {
    return title
 }
 }
 
 QuicklookPanel.shared.preset(aGalleryItem)
 ```

## QuicklookPanel
Presents previews of files in a panel simliar to Finder`s Quicklook. 
```
QuicklookPanel.shared.present(fileURLs)
```

## QuicklookView
 A preview of a file that you can embed into your view hierarchy.
 
```
let quicklookView = QuicklookView(content: URL(fileURLWithPath: imageFileURL)
```

## Quicklook for NSTableView & NSCollectionView
`isQuicklookPreviewable` enables quicklook of NSCollectionView items and NSTableView cells/rows.

There are several ways to provide quicklook previews:
- NSCollectionViewItems's & NSTableCellView's `quicklookPreview`
```
collectionViewItem.quicklookPreview = URL(fileURLWithPath: "someFile.png")
```
- NSCollectionView's datasource `collectionView(_:,  quicklookPreviewForItemAt:)` & NSTableView's datasource `tableView(_:,  quicklookPreviewForRow:)`
```
func collectionView(_ collectionView: NSCollectionView, quicklookPreviewForItemAt indexPath: IndexPath) -> QuicklookPreviewable? {
    let item = collectionItems[indexPath.item]
    return item.fileURL
}
```
- A NSCollectionViewDiffableDataSource & NSTableViewDiffableDataSource with an ItemIdentifierType conforming to `QuicklookPreviewable`
```
struct FileItem: Hashable, QuicklookPreviewable {
    let title: String
    let image: NSImage
    let previewItemURL: URL?
}
     
collectionView.dataSource = NSCollectionViewDiffableDataSource<Section, FileItem>(collectionView: collectionView) { collectionView, indexPath, fileItem in
     
let collectionViewItem = collectionView.makeItem(withIdentifier: "FileCollectionViewItem", for: indexPath)
collectionViewItem.textField?.stringValue = fileItem.title
collectionViewItem.imageView?.image = fileItem.image

return collectionViewItem
}
// …
collectionView.quicklookSelectedItems()
```
