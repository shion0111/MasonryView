//
//  ListViewModel.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/4/18.
//  Copyright © 2019 Antelis. All rights reserved.
//



import Foundation
import UIKit

public protocol ItemViewModel {
    var imageRemotePath: String? { get }
    var caption : String? { get }
    var pid : String? { get }
    func setup(_ view : UIView, _ container: UIView, indexPath: IndexPath)
}
public protocol SectionModel {
    var header : ItemViewModel? { get set }
    var items : Array<ItemViewModel> { get set }
    var footer : ItemViewModel? { get set }
    
}


/*
class ItemListDataSource : BinderCollectionViewDataSource, GridVCLayoutDelegate  {
    
    override init(view: UICollectionView, newModel models: Array<SectionModel>) {
        super.init(view: view, newModel: [])
        self.cellReuseIdentifier = "GridCollectionViewCell"
        view.dataSource = self
    }
    
    //  Query Flickr Group photo list
    func retrieveList(page:Int = 1) {
        
    }
    
    //  Calculating cell height for SampleVCFlowLayout //
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        return 48.0
    }
    
    override func itemAtIndex(_ indexPath: IndexPath) -> ItemViewModel? {
        return nil
    }
    
    
}
*/


