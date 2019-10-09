//
//  WeatherCollectionViewLayout.swift
//  Yellow
//
//  Created by Lyle on 30/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit


protocol WeatherCollectionViewLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, fractionInteraction fraction: CGFloat, forItemAt indexPath: IndexPath)
    func collectionView(_ collectionView: UICollectionView, currentPage: Int)
}

class WeatherCollectionViewLayout: UICollectionViewFlowLayout {
    
    public weak var layoutDelegate: WeatherCollectionViewLayoutDelegate?
    
    public var numberOfPages: Int = 0
    public var currentPage: Int = 0
    
    private var layoutAttributes = [UICollectionViewLayoutAttributes]()
    
    private var contentInset: UIEdgeInsets {
        guard let collectionView = self.collectionView else { return UIEdgeInsets.zero }
        return collectionView.contentInset
    }
    
    private var contentWidth: CGFloat = 0
    private var contentHeight: CGFloat {
        guard let collectionView = self.collectionView else { return 0 }
        let contentInset = self.contentInset
        return collectionView.bounds.height - (contentInset.top + contentInset.bottom)
    }
    
    private var cellSize: CGSize {
        guard let collectionView = self.collectionView else { return .zero }
        let collectionViewSize = collectionView.bounds.size
        return CGSize(width: collectionViewSize.width, height: contentHeight)
    }
    private var pageWidth: CGFloat {
        return itemSize.width + minimumInteritemSpacing
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
        
        scrollDirection = .horizontal
        itemSize = cellSize
        minimumInteritemSpacing = 30
        collectionView.decelerationRate = .fast
        
        let collectionWidth = collectionView.bounds.width
        let marginLeft = collectionWidth - itemSize.width
        let contentInset = UIEdgeInsets(top: 0, left: marginLeft * 0.5, bottom: 0, right: marginLeft * 0.5)
        collectionView.contentInset = contentInset
        
        defer {
            if collectionView.contentOffset.x + itemSize.width > contentWidth {
                collectionView.contentOffset.x = contentWidth - itemSize.width
            }
            // 기기 회전시 paging 처리
            let targetOffset: CGPoint
            let contentOffset: CGPoint
            contentOffset = CGPoint(x: layoutAttributes[currentPage].frame.minX, y: collectionView.contentOffset.y)
            if collectionView.isPagingEnabled {
                targetOffset = CGPoint(x: ceil(contentOffset.x / itemSize.width) * itemSize.width, y: contentOffset.y)
            } else {
                targetOffset = targetContentOffset(forProposedContentOffset: contentOffset, withScrollingVelocity: .zero)
            }
            collectionView.setContentOffset(targetOffset, animated: false)
        }
        
        contentWidth = 0
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let frame = CGRect(x: CGFloat(item) * (pageWidth), y: 0, width: itemSize.width, height: itemSize.height)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            layoutAttributes.append(attributes)
            
            contentWidth = max(contentWidth, frame.maxX)
        }
        numberOfPages = layoutAttributes.count
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView else { return nil }
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        layoutAttributes.forEach { attributes in
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        let collectionViewWidth = collectionView.bounds.width
        let activeDistance = cellSize.width
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)
        for attributes in visibleLayoutAttributes {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance
            
            if distance.magnitude < collectionViewWidth {
                let fraction = normalizedDistance //max(-1, min(1, normalizedDistance))
                let alpha = max(0.6, 1 - (normalizedDistance.magnitude * 0.4))
                attributes.alpha = alpha
                
                layoutDelegate?.collectionView(collectionView, fractionInteraction: fraction, forItemAt: attributes.indexPath)
            }
        }
        
        return visibleLayoutAttributes
    }
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributes[indexPath.item]
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard layoutAttributes.count > 0, let collectionView = self.collectionView else { return .zero }
        
        var normalizedProposedOffset = proposedContentOffset

        let currentPageX = pageWidth * CGFloat(currentPage)
        let proposedDistanceX = proposedContentOffset.x.magnitude - currentPageX.magnitude
        
        if proposedDistanceX.magnitude > pageWidth {
            if velocity.x < 0 {
                normalizedProposedOffset.x = (normalizedProposedOffset.x < currentPageX - pageWidth) ? currentPageX - pageWidth : normalizedProposedOffset.x
            } else if velocity.x > 0 {
                normalizedProposedOffset.x = (normalizedProposedOffset.x > currentPageX + pageWidth) ? currentPageX + pageWidth : normalizedProposedOffset.x
            }
        }
        let targetRect = CGRect(x: normalizedProposedOffset.x - (contentInset.left), y: 0, width: itemSize.width, height: collectionView.frame.height)
        guard let attributesForElements = layoutAttributesForElements(in: targetRect) else { return .zero }
        
        
        var adjustOffset = CGFloat.greatestFiniteMagnitude
        let centerOffset = normalizedProposedOffset.x + collectionView.frame.width / 2
        for layoutAttributes in attributesForElements {
            let itemCenter = layoutAttributes.center.x
            if (itemCenter - centerOffset).magnitude < adjustOffset.magnitude {
                adjustOffset = itemCenter - centerOffset
            }
        }
        var targetOffset = CGPoint(x: normalizedProposedOffset.x + adjustOffset, y: normalizedProposedOffset.y)
        
        if (targetOffset.x - normalizedProposedOffset.x).magnitude < pageWidth {
            if targetOffset.x > normalizedProposedOffset.x, velocity.x < 0 {
                targetOffset.x -= pageWidth
            } else if targetOffset.x < normalizedProposedOffset.x, velocity.x > 0 {
                targetOffset.x += pageWidth
            }
        }
        
        updateCurrentPage(offset: targetOffset)
        return targetOffset
    }
    
    private func updateCurrentPage(offset: CGPoint) {
        guard layoutAttributes.count > 0, let collectionView = self.collectionView else {
            currentPage = 0
            return
        }
        currentPage = Int((offset.x + collectionView.contentInset.left) / pageWidth)
        layoutDelegate?.collectionView(collectionView, currentPage: currentPage)
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
