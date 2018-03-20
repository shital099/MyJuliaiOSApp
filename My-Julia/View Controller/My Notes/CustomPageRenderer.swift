//
//  CustomPageRenderer.swift
//  (c) 2016 Vineeth Vijayan, licensed under the MIT License
//  Inspired by https://gist.github.com/mattt/bd5e48ae461848cdbd1e#file-recipepagerenderer-swift

import UIKit
import AVFoundation

/// Units for printing content insets
let POINTS_PER_INCH: CGFloat = 72

/// The alignment for drawing an NSString inside a bounding rectangle.
enum NCStringAlignment {
	case LeftTop
	case CenterTop
	case RightTop
	case LeftCenter
	case Center
	case RightCenter
	case LeftBottom
	case CenterBottom
	case RightBottom
}

extension NSString {

	/// Draw the `NSString` inside the bounding rectangle with a given alignment.
	func drawAtPointInRect(rect: CGRect, withAttributes attributes: [NSAttributedStringKey: AnyObject]?, andAlignment alignment: NCStringAlignment) {
		let size = self.size(withAttributes: attributes)
		var x, y: CGFloat

		switch alignment {
		case .LeftTop, .LeftCenter, .LeftBottom:
			x = rect.minX
		case .CenterTop, .Center, .CenterBottom:
			x = rect.midX - size.width / 2
		case .RightTop, .RightCenter, .RightBottom:
			x = rect.maxX - size.width
		}

		switch alignment {
		case .LeftTop, .CenterTop, .RightTop:
			y = rect.minY
		case .LeftCenter, .Center, .RightCenter:
			y = rect.midY - size.height / 2
		case .LeftBottom, .CenterBottom, .RightBottom:
			y = rect.maxY - size.height
		}

		self.draw(at: CGPoint(x: x, y: y), withAttributes: attributes)
	}
}

class CustomPrintPageRenderer: UIPrintPageRenderer {
	let authorName: NSString

	let pageNumberAttributes = [NSAttributedStringKey.font: UIFont(name: "Georgia-Italic", size: 11)!]
	let nameAttributes = [NSAttributedStringKey.font: UIFont(name: "Georgia", size: 11)!]

	init(authorName: String, html: String) {
		self.authorName = "Vineeth" // authorName
		super.init()

		self.headerHeight = 0.5 * POINTS_PER_INCH
		self.footerHeight = POINTS_PER_INCH * 1.5
	}

    override func drawFooterForPage(at pageIndex: Int, in headerRect: CGRect) {
        
        var headerRect = headerRect

		let headerInsets = UIEdgeInsets(top: headerRect.minY, left: POINTS_PER_INCH * 2, bottom: 20, right: POINTS_PER_INCH)
		headerRect = UIEdgeInsetsInsetRect(paperRect, headerInsets)

		// Image left
		let img = UIImage(named: "flag")
		img?.draw(at: CGPoint(x: 70, y: 760))
		authorName.drawAtPointInRect(rect: headerRect, withAttributes: nameAttributes, andAlignment: .LeftCenter)

		// page number on right
		let pageNumberString: NSString = "\(pageIndex + 1)" as NSString
		pageNumberString.drawAtPointInRect(rect: headerRect, withAttributes: pageNumberAttributes, andAlignment: .RightCenter)
	}

    func drawImages(images: [UIImage], inRect sourceRect: CGRect) {
        // we'll use 1/8 of an inch of vertical padding between each image
        var sourceRect = sourceRect
        let imagePadding = UIEdgeInsets(top: POINTS_PER_INCH / 8, left: 0, bottom: 0, right: 0)

		for image in images {
			// get the aspect-fit size of the image
			let sizedRect = AVMakeRect(aspectRatio: image.size, insideRect: sourceRect)

			// if the new width of the image doesn't match the source rect, there wasn't enough vertical room: bail
			if sizedRect.width != sourceRect.width {
				return
			}

			// use divide to separate the image rect from the rest of the column
			//CGRectDivide(sourceRect, &sizedRect, &sourceRect, sizedRect.height, .minYEdge)
          sizedRect.divided(atDistance: sizedRect.height, from: .minYEdge)
            
			// draw the image
			image.draw(in: sizedRect)

			// inset the source rect to make a little padding before the next image
			sourceRect = UIEdgeInsetsInsetRect(sourceRect, imagePadding)
		}
	}
}
