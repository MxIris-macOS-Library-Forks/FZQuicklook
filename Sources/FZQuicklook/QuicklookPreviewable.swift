//
//  QuicklookPreviewable.swift
//
//
//  Created by Florian Zand on 06.03.23.
//

import AppKit
import AVKit
import Foundation
import FZSwiftUtils
import Quartz

/**
 A type that can be previewed  by ``QuicklookPanel`` and ``QuicklookView``.

 `URL`, `NSURL` and `AVURLAsset` conform to `QuicklookPreviewable`.

 Example:

 ```swift
 struct GalleryItem: Hashable, QuicklookPreviewable {
     let title: String
     let imageURL: URL

     // The file url for quicklook preview.
     let previewItemURL: URL? {
        return imageURL
     }

    // The title for quicklook preview.
     let previewItemTitle: String? {
        return title
     }
 }

 QuicklookPanel.shared.preset(aGalleryItem)
 ```
 */
public protocol QuicklookPreviewable {
    /**
     The URL of the item to preview.

     ``QuicklookPanel`` and ``QuicklookView`` use this property to get an item’s URL.

     The value of this property must be a file URL.

     If the item isn’t available for preview return `nil`. In this case, the ``QuicklookPanel`` and ``QuicklookView`` displays a “loading” view. Use ``QuicklookPanel/refreshCurrentItem()`` to reload the item once the content is available.
     */
    var previewItemURL: URL? { get }
    /**
     The item frame on the screen.

     The system invokes this optional property when the preview panel opens or closes to provide a zoom effect.

     [NSView](https://developer.apple.com/documentation/appkit/nsview) and [NSCollectionViewItem](https://developer.apple.com/documentation/appkit/nscollectionviewitem) conforming to `QuicklookPreviewable` provide their frame as default value.
     */
    var previewItemFrame: CGRect? { get }
    /**
     The transition image for the item.

     The system invokes this optional property when the preview panel opens or closes to provide a transition image.

     [NSView](https://developer.apple.com/documentation/appkit/nsview) and [NSCollectionViewItem](https://developer.apple.com/documentation/appkit/nscollectionviewitem) conforming to `QuicklookPreviewable` provide a rendered image representation as default value.
     */
    var previewItemTransitionImage: NSImage? { get }
    /**
     The title to display for the preview item.

     If you don’t implement this property, ``QuicklookPanel`` examines the URL or content of the previewed item to determine an appropriate title.
     */
    var previewItemTitle: String? { get }
}

public extension QuicklookPreviewable {
    var previewItemFrame: CGRect? {
        nil
    }

    var previewItemTransitionImage: NSImage? {
        nil
    }

    var previewItemTitle: String? {
        previewItemURL?.deletingPathExtension().lastPathComponent
    }
}

extension Optional: QuicklookPreviewable where Wrapped: QuicklookPreviewable {
    public var previewItemURL: URL? {
        optional?.previewItemURL
    }

    public var previewItemFrame: CGRect? {
        optional?.previewItemFrame
    }

    public var previewItemTitle: String? {
        optional?.previewItemTitle
    }

    public var previewItemTransitionImage: NSImage? {
        optional?.previewItemTransitionImage
    }
}

extension URL: QuicklookPreviewable {
    public var previewItemURL: URL? {
        self
    }
}

extension NSURL: QuicklookPreviewable {
    public var previewItemURL: URL? {
        self as URL
    }
}

extension AVURLAsset: QuicklookPreviewable {
    public var previewItemURL: URL? {
        url
    }

    public var previewItemTitle: String? {
        url.deletingPathExtension().lastPathComponent
    }
}

public extension QuicklookPreviewable where Self: NSCollectionViewItem {
    var previewItemFrame: CGRect? {
        view.frameOnScreen
    }

    var previewItemTransitionImage: NSImage? {
        view.renderedImage
    }
}

public extension QuicklookPreviewable where Self: NSView {
    var previewItemFrame: CGRect? {
        frameOnScreen
    }

    var previewItemTransitionImage: NSImage? {
        renderedImage
    }
}

public extension QuicklookPreviewable where Self: NSImageView {
    var previewItemFrame: CGRect? {
        return image != nil ? window?.convertToScreen(convert(imageBounds, to: nil)) : frameOnScreen
    }
    
    var previewItemTransitionImage: NSImage? {
        image
    }
}
