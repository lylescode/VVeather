//
//  WeatherOverviewCollectionViewLayout.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

protocol WeatherOverviewCollectionViewLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, relativeHeightForItemAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat
}

class WeatherOverviewCollectionViewLayout: UICollectionViewFlowLayout {
    
    public weak var layoutDelegate: WeatherOverviewCollectionViewLayoutDelegate?
    
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    private var contentInset: UIEdgeInsets {
        guard let collectionView = collectionView else { return UIEdgeInsets.zero }
        return collectionView.contentInset
    }
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let contentInset = self.contentInset
        return collectionView.bounds.height - (contentInset.left + contentInset.right)
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
        guard layoutAttributes.isEmpty, let collectionView = collectionView else {
            return
        }
        
        scrollDirection = .vertical
        
        minimumLineSpacing = 0
        collectionView.decelerationRate = .fast
        
        let collectionWidth = collectionView.bounds.width
        let marginLeft = collectionWidth - itemSize.width
        let contentInset = UIEdgeInsets(top: 0, left: marginLeft * 0.5, bottom: 0, right: marginLeft * 0.5)
        collectionView.contentInset = contentInset

        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let itemHeight = layoutDelegate?.collectionView(collectionView, relativeHeightForItemAtIndexPath: indexPath, withWidth: contentWidth) ?? 84
            
            let frame = CGRect(x: 0, y: CGFloat(item) * (itemSize.height), width: contentWidth, height: itemHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            layoutAttributes.append(attributes)
        }
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
