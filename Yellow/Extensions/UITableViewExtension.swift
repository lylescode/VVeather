//
//  UITableViewExtension.swift
//  Yellow
//
//  Created by Lyle on 29/09/2019.
//  Copyright © 2019 Yellow. All rights reserved.
//

import UIKit

extension UITableView {
    func snapshotForRow(at indexPath: IndexPath) -> UIImage? {
        guard let cell = cellForRow(at: indexPath) else { return nil }
        
        let rect = rectForRow(at: indexPath)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.nativeScale)
        cell.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func customSnapshotForRow(at indexPath: IndexPath) -> UIImageView? {
        guard let snapshotImage = snapshotForRow(at: indexPath) else { return nil }
        let snapshot = UIImageView(image: snapshotImage)
        snapshot.layer.masksToBounds = false
        snapshot.layer.shadowOffset = CGSize(width: 0, height: 0.2)
        snapshot.layer.shadowRadius = 10
        snapshot.layer.shadowOpacity = 0.45
        
        return snapshot
    }
}
