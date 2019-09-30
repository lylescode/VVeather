//
//  WeatherCellLayout.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

protocol WeatherCellLayoutDelegate: AnyObject{
    func collectionView(_ collectionView: UICollectionView, shouldFloatSectionAt section: Int) -> Bool
    func collectionView(_ collectionView: UICollectionView, heightForItemAt indexPath: IndexPath) -> CGFloat
    
}

class WeatherCellLayout: UICollectionViewFlowLayout {
    
    public weak var layoutDelegate: WeatherCellLayoutDelegate?
    
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    private var contentWidth: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        return collectionView.bounds.width - (collectionView.contentInset.left + collectionView.contentInset.right)
    }
    private var contentHeight: CGFloat = 0
    
    private var cellSize: CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        let collectionViewSize = collectionView.bounds.size
        return CGSize(width: collectionViewSize.width, height: contentHeight)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func reloadLayout() {
        invalidateLayout()
        layoutAttributes.removeAll()
    }
    
    override func prepare() {
        super.prepare()
        guard layoutAttributes.isEmpty, let collectionView = self.collectionView else {
            return
        }
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .vertical
        
        contentHeight = 0
        let columnWidth = contentWidth / 2
        
        let numberOfSections = collectionView.numberOfSections
        for section in 0 ..< numberOfSections {
            
            //isFloating = layoutDelegate?.collectionView(collectionView, shouldFloatSectionAt: section) ?? false
            
            let numberOfItems = collectionView.numberOfItems(inSection: section)
            let numberOfColumns = 2
            let isColumnsSection = 1 < numberOfItems

            var xOffset = [CGFloat]()
            for column in 0 ..< numberOfColumns {
                xOffset.append(CGFloat(column) * columnWidth)
            }
            
            var column = 0
            var height: CGFloat = 0
            for item in 0 ..< numberOfItems {
                let indexPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                height = max(height, layoutDelegate?.collectionView(collectionView, heightForItemAt: indexPath) ?? 0)
                if isColumnsSection {
                    attributes.frame = CGRect(x: xOffset[column], y: contentHeight, width: columnWidth, height: height)
                    column = column < (numberOfColumns - 1) ? (column + 1) : 0
                } else {
                    attributes.frame = CGRect(x: xOffset[0], y: contentHeight, width: cellSize.width, height: height)
                }
                layoutAttributes.append(attributes)
            }
            contentHeight += height
        }
        //print(#function, layoutAttributes)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        layoutAttributes.forEach { attributes in
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
