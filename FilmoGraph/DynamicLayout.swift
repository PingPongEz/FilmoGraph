//
//  DynamicLayout.swift
//  FilmoGraph
//
//  Created by Сергей Веретенников on 29/06/2022.
//

import UIKit

struct Standarts {
    
    static var standartSize = CGSize(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.3)
    static var goalSize = CGSize(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.height * 0.19)
    
}

class DynamicLayout: UICollectionViewLayout {

    var dragOffsetY: CGFloat {
        Standarts.standartSize.height
    }

    var dragOffsetX: CGFloat {
        Standarts.standartSize.width - Standarts.goalSize.width
    }
    
    var featuredItemIndex: Int {
        max(0,(Int((collectionView!.contentOffset.y + 198) / dragOffsetY)))
    }
    
//    var currentPlace: CGFloat {
//
//    }
    
    var percentageOffset: CGFloat {
        collectionView!.contentOffset.y / dragOffsetY - CGFloat(featuredItemIndex)
    }
    
    var width: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.width
    }
    
    var height: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.bounds.height * 0.95
    }
    
    var numberOfItems: Int {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.numberOfItems(inSection: 0)
    }
    
    var cachedAttributes = [UICollectionViewLayoutAttributes]()
}

extension DynamicLayout {

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }

    override var collectionViewContentSize: CGSize {
        CGSize(
            width: width,
            height: CGFloat(numberOfItems) * dragOffsetY + (dragOffsetY * 2)
        )
    }
    
    override func prepare() {
        cachedAttributes.removeAll()

        var frame: CGRect = .zero
        var y: CGFloat = dragOffsetY
        
        var size = Standarts.standartSize
        
        for index in 0..<numberOfItems {
            let path = IndexPath(item: index, section: 0)
            let attr = UICollectionViewLayoutAttributes(forCellWith: path)
            
            
            if path.item != featuredItemIndex {
                size.height = max(Standarts.goalSize.height, round(((max(0 ,collectionView!.contentOffset.y)) / size.height)))
                y = (collectionView!.contentOffset.y + 198) - size.height * percentageOffset
            } else {
                
            }
            
            frame = CGRect(x: 0, y: y, width: size.width, height: size.height)
            
            attr.frame = frame
            
            cachedAttributes.append(attr)
            
//            print(collectionView!.contentOffset)
            y = frame.maxY
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var resultAttr = [UICollectionViewLayoutAttributes]()

        for attr in cachedAttributes {
            if attr.frame.intersects(rect) {
                resultAttr.append(attr)
            }
        }

        return resultAttr
    }

//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//        let index = round(proposedContentOffset.y / dragOffsetY)
//        let offset = index * dragOffsetY
//        return CGPoint(x: 0, y: offset)
//    }
}


class CollViewFlowLayout: UICollectionViewFlowLayout {
    
}
