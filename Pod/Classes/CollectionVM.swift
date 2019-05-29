//
//  CollectionVM.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/4/18.
//  Copyright © 2019 Antelis. All rights reserved.
//



import Foundation
import UIKit

// MARK: a base class for UICollectionView/UITableView ViewModel
extension DispatchQueue {
    
    static let binderUpdate = DispatchQueue(label: "BinderDataSource.queue", qos: DispatchQoS.background)
}
public struct ModelUpdate {
    var diff : Int = 0
    var diffItems : [IndexPath] = []
    init(from oldModel: [SectionModel], to newModel: [SectionModel], forceReload: Bool = false) {
        if let m = oldModel.first, let m2 = newModel.first {
            diff = m2.items.count - m.items.count
            for i in m.items.count..<m2.items.count {
                diffItems.append(IndexPath(item: i, section: 0))
            }
        }
    }
}
public protocol BatchUpdateView {
    
    func perform(_ update: ModelUpdate, modelUpdates: () -> Void, completion: ((Bool) -> Void)?)
}

open class BinderDataSource<View : UIView>: NSObject {
    
    private var _models : Array<SectionModel> = []
    public weak var view: View?
    open var models : Array<SectionModel> {
        set {
            self.update(newModel: newValue, reload: true)
        }
        get {
            return _models
        }
    }
    
    public init(view: View, newModel : Array<SectionModel> = []) {
        super.init()
        self.view = view
        self._models = models
    }
    public func update(newModel : Array<SectionModel>, reload: Bool = false) {
        
        guard let batchUpdateView = self.view as? BatchUpdateView else {
            self._models = newModel
            return
        }
        
        DispatchQueue.binderUpdate.async {
            
            let oldModel = self._models
            let updates = ModelUpdate(from: oldModel, to: newModel, forceReload: reload)
            
            self._models = newModel
            
            self.performSyncUpdate(updates, in: batchUpdateView)
        }
    }
    
    internal func performSyncUpdate(_ updates: ModelUpdate, in view: BatchUpdateView) {
        view.perform(updates, modelUpdates: {
            DispatchQueue.main.async {
                if let v = self.view as? UICollectionView, let layout = v.collectionViewLayout as? GridVCFlowLayout {
                    //layout.invalidateLayout()
                    layout.appendLayoutAttributes(withCount: updates.diff)
                    
                }
            }
        }) { (result : Bool) in
            
        }
    }
    
}

//  MARK:
open class BinderCollectionViewDataSource: BinderDataSource<UICollectionView>, UICollectionViewDataSource ,GridVCLayoutDelegate {
    
    public var cellReuseIdentifier : String? = nil
    public var supplementaryReuseIdentifier : String? = nil
    
    public var curPage : Int = 1
    
    override public init(view : UICollectionView, newModel models: Array<SectionModel>) {
        super.init(view: view, newModel: models)
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return models.count < 1 ? 1 : models.count
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < models.count {
            let s = self.models[section]
            return s.items.count
        }
        
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard indexPath.section < self.models.count, let cellid =  cellReuseIdentifier else { return UICollectionViewCell.init() }
        
        let sectionmodel = self.models[indexPath.section]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellid, for: indexPath)
        let model = sectionmodel.items[indexPath.row]
        model.setup(cell, collectionView, indexPath: indexPath)
        
        return cell
    }
    
    open func itemAtIndex(_ indexPath : IndexPath) -> ItemViewModel?  {
        guard indexPath.section < self.models.count else { return nil }
        
        let sectionmodel = self.models[indexPath.section]
        guard indexPath.row < sectionmodel.items.count else { return nil } 
        let model = sectionmodel.items[indexPath.row]
        
        return model
        
    }
    
    //  Query Flickr Group photo list
    open func retrieveList(page:Int = 1) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return 0.0
    }
    
    func dislayItemViewController(_ withIndexPath: IndexPath,_ selectedRect : CGRect,_ photo: UIImageView? ) -> ItemDisplayContainerViewController?{
    
        if let p = itemAtIndex(withIndexPath),
            let path = Bundle(for: GridViewController.self).path(forResource: "Masonry", ofType: "bundle"),
            let podBundle = Bundle(path: path) {
            
            let storybard = UIStoryboard(name: "ItemDisplay", bundle: podBundle)
            if let v = storybard.instantiateViewController(withIdentifier: "ItemDisplayContainerViewController") as? ItemDisplayContainerViewController {
                    //v.headerImagePath = p.coverPath
                    v.setPhoto(p)
                    v.sourceRect = selectedRect
                    v.sourceView = photo
                return v
            }
    
        }
        
        return nil
    }
    
}
