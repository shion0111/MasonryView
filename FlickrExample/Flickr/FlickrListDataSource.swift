//
//  FlickrListDataSource.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/5/27.
//  Copyright © 2019 Antelis. All rights reserved.
//

import Foundation
import UIKit
import Masonry

class FlickrListDataSource : BinderCollectionViewDataSource {
    
    // retrieve & parse Flickr JSON
    private let photoDataManager : FlickrDataManager = FlickrDataManager()
    
    override init(view: UICollectionView, newModel models: Array<SectionModel>) {
        super.init(view: view, newModel: [])
        self.cellReuseIdentifier = "GridCollectionViewCell"
        view.dataSource = self
    }
    
    //  Query Flickr Group photo list
    override func retrieveList(page:Int = 1) {
        photoDataManager.retrievePhotoData(page, { (sectionModel : FlickrListSectionModel? ,err: CustomError?) in
            if let e = err {
                print("Error occurred: \(e.errorDescription ?? "")")
            } else if let list = sectionModel {
                DispatchQueue.main.async {
                    self.update(newModel: [list], reload: true )
                    self.curPage = page
                    
                }
            }
        })
        //  ONE piece of linkage is missed : Invalid the layout //
    }

    override func itemAtIndex(_ indexPath: IndexPath) -> ItemViewModel? {
        guard indexPath.item < photoDataManager.photoCount else { return nil }
        let photo = photoDataManager.photoAtIndex(indexPath.item)
        return photo
    }
    
    //  Calculating cell height for GridVCFlowLayout //
    override func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        
        if let layout = collectionView.collectionViewLayout as? GridVCFlowLayout,
            let photo = photoDataManager.photoAtIndex(indexPath.item) {
            let cw = layout.columnWidth
            
            let thumbsize = photo.thumbSize
            if thumbsize.width > 0.0 {
                return (thumbsize.height*cw / thumbsize.width)+48;
            }
        }
        
        return 48.0
    }
    
//    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//        guard indexPath.section < self.models.count, let cellid =  cellReuseIdentifier else { return UICollectionViewCell.init() }
//
//        let sectionmodel = self.models[indexPath.section]
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath)
//        let model = sectionmodel.items[indexPath.row]
//        model.setup(cell, collectionView, indexPath: indexPath)
//
//        return cell
//    }
//
}
