//
//  Util.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/5/27.
//  Copyright © 2019 Antelis. All rights reserved.
//
import Foundation
import UIKit

// MARK: - CustomError
public protocol CustomErrorProtocol : LocalizedError {
    var title : String? { get }
    var code : Int { get }
}
public struct CustomError : CustomErrorProtocol {
    public var title: String?
    public var code: Int
    
    public var errorDescription : String? { return _description }
    
    private var _description : String
    
    public init(_ title : String?,_ description : String,_ code:Int) {
        self.title = title ?? "Error"
        self._description = description
        self.code = code
    }
}

extension URLSession {
    static public let cellSession = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: OperationQueue())
}

extension UICollectionView : BatchUpdateView {
    public func perform(_ update: ModelUpdate, modelUpdates: () -> Void, completion: ((Bool) -> Void)?) {
        modelUpdates()
        DispatchQueue.main.async {
            if update.diffItems.count > 0 {
                self.insertItems(at: update.diffItems)
            } else {
                self.reloadData()
            }
        }
        completion?(true)
    }
}

extension UIScrollView {
    func isNearBottom(edgeOffset : CGFloat = 200.0) -> Bool {
        return (self.contentSize.height - self.contentOffset.y) < (edgeOffset + self.frame.height)
    }
}
