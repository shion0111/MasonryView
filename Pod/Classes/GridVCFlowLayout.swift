//
//  GridVCFlowLayout.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/1/23.
//  Copyright © 2019 Antelis. All rights reserved.
//

import UIKit
public protocol GridVCLayoutDelegate {
    func collectionView(_ collectionView:UICollectionView, heightForPhotoAtIndexPath indexPath:IndexPath) -> CGFloat
}

open class GridVCFlowLayout: UICollectionViewFlowLayout {
    
    public var columnCount : NSInteger = 2
    
    public var delegate: GridVCLayoutDelegate?
    
    fileprivate var cellpadding: CGFloat = 6
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override open var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    public var columnWidth : CGFloat {
        return contentWidth / CGFloat(columnCount)
    }
    override open func prepare() {
        super.prepare()
        guard  cache.isEmpty == true, let collectionView = collectionView  else {
            return
        }
        cache.removeAll()
        let columnWidth = self.columnWidth
        var xOffset = [CGFloat]()
        for x in 0 ..< columnCount {
            xOffset.append(CGFloat(x)*columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: columnCount)
        
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoHeight = (delegate != nil) ? delegate!.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath) : CGFloat(20)
            let height = cellpadding + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellpadding, dy: cellpadding)
            
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (columnCount - 1) ? (column + 1) : 0
        }
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    public func appendLayoutAttributes(withCount: Int) {
        if withCount > 0, let c = collectionView {
            
            let c0 = c.numberOfItems(inSection: 0)
            let columnWidth = self.columnWidth
            var xOffset = [CGFloat]()
            for x in 0 ..< columnCount {
                xOffset.append(CGFloat(x)*columnWidth)
            }
            var column = 0
            
            var yOffset = [CGFloat](repeating: 0, count: columnCount)
            let l0 = cache.count-5
            for i in l0..<cache.count{
                let ay = cache[i].frame.height + cache[i].frame.minY
                let ax = cache[i].frame.minX
                let c = Int(floor(ax / columnWidth))
                if c < columnCount {
                    yOffset[c] = ay
                } else {
                    yOffset[i-l0] = ay
                }
            }
            
            for item in 0 ..< withCount {
                let indexPath = IndexPath(item: item+c0, section: 0)
                
                let photoHeight = (delegate != nil) ? delegate!.collectionView(c, heightForPhotoAtIndexPath: indexPath) : CGFloat(20)
                let height = cellpadding + photoHeight
                let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
                let insetFrame = frame.insetBy(dx: cellpadding, dy: cellpadding)
                
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = insetFrame
                cache.append(attributes)
                
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                column = column < (columnCount - 1) ? (column + 1) : 0
            }
        }
    }
    
}
