//
//  FlickrGridViewController.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/5/27.
//  Copyright © 2019 Antelis. All rights reserved.
//

import Foundation
import UIKit
import Masonry

class FlickrGridViewController: GridViewController {
    
//    override func registerCell () {
//
//        let bundle = Bundle(for: GridCollectionViewCell.self)
//        if let c = self.collectionView {
//                let nib = UINib(nibName: "GridCollectionViewCell", bundle: bundle )
//                c.register(nib, forCellWithReuseIdentifier: "GridCollectionViewCell")
//        }
//
//    }
    override func setupViewModel(){
    
        self.viewModel = FlickrListDataSource(view: self.collectionView!, newModel: [])
        
        self.viewModel?.retrieveList()
        if let layout = self.collectionView?.collectionViewLayout as? GridVCFlowLayout {
            layout.delegate = self.viewModel
            layout.columnCount = 5
        }
    }
}
