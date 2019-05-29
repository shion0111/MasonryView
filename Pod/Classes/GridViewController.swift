//
//  GridViewController.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/1/23.
//  Copyright © 2019 Antelis. All rights reserved.
//

import UIKit


// MARK: - View

public class GridCollectionViewCell : UICollectionViewCell {
    // cell cover
    @IBOutlet public var photo: UIImageView?
    // photo title
    @IBOutlet public var caption: UILabel?
    // Flickr Photo id
    public var pid : String?
}

open class GridViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet public var collectionView :UICollectionView?
    public var viewModel : BinderCollectionViewDataSource?
    
    private var selected : NSInteger = -1;
    private var selectedRect : CGRect = CGRect.zero
    private var lastYOffset : CGFloat = 0.0
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.registerCell()
        self.setupViewModel()
        
    }
    open func registerCell () {
        let podBundle = Bundle(path: Bundle(for: GridViewController.self).path(forResource: "Masonry", ofType: "bundle")!)
        //let bundle = Bundle(for: GridCollectionViewCell.self)
        if let c = self.collectionView {
            
            let nib = UINib(nibName: "GridCollectionViewCell", bundle: podBundle )
            
            c.register(nib, forCellWithReuseIdentifier: "GridCollectionViewCell")
        }
    }
    open func setupViewModel(){
        
        self.viewModel = BinderCollectionViewDataSource(view: self.collectionView!, newModel: [])
        
        self.viewModel?.retrieveList()
        if let layout = self.collectionView?.collectionViewLayout as? GridVCFlowLayout {
            layout.delegate = self.viewModel
        }
    }
    @IBAction func dismissPressed(_ sender:Any?) {
        if let _ = self.navigationController {
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selected = indexPath.item
        
        
        if let cell = collectionView.cellForItem(at: indexPath) as? GridCollectionViewCell,
            let vm = self.viewModel, let photo = cell.photo {
            
            self.selectedRect = self.view.convert(cell.frame, from: collectionView)
            if let v = vm.dislayItemViewController(indexPath, selectedRect, photo) {
                if let n = self.navigationController {
                    n.delegate = v.navigationControllerDelegate()
                    n.pushViewController(v, animated: true)
                } else {
                    self.present(v, animated: true, completion: nil)
                }
            }
        }
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var edge = self.view.frame.height/2
        
        if #available(iOS 11.0, *) {
            edge = self.view.safeAreaLayoutGuide.layoutFrame.height/2
        }
        
        if scrollView.contentOffset.y - lastYOffset > edge {
            if scrollView.contentSize.height > 0 && scrollView.isNearBottom(edgeOffset: edge) {
                if let p = self.viewModel?.curPage {
                    self.viewModel?.retrieveList(page: p+1)
                    
                }
            }
            lastYOffset = scrollView.contentOffset.y
        }
        
    }
    
}
