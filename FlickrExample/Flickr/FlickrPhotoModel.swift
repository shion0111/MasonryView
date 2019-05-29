//
//  FlickrPhotoModel.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/5/27.
//  Copyright © 2019 Antelis. All rights reserved.
//

import Foundation
import UIKit
import Masonry

// MARK: - Model
class FlickrPhotoModel : NSObject {
    fileprivate var piid : String?
    var title : String?
    fileprivate var date: String?
    
    var thumbPath : String?
    var thumbSize : CGSize = CGSize.zero
    
    var coverPath : String?
    var coverSize : CGSize = CGSize.zero
    
    convenience init(_ photoData: Dictionary<String,Any>?) {
        self.init()
        guard let data = photoData,
            let p = data["id"] as? String,
            let thumb = data["url_m"] as? String else { return }
        
        self.piid = p
        
        if let t = data["title"] as? String {
            self.title = t
        }
        if let date = data["dateadded"] as? String {
            self.date = date
        }
        
        self.thumbPath = thumb
        if let mw = data["width_m"] as? String, let mh = data["height_m"] as? String, let fw = Float(mw), let fh = Float(mh)  {
            
            self.thumbSize = CGSize(width: CGFloat(fw), height: CGFloat(fh))
        }
        
        //  some photos may not have 1024x1024 file
        if let lpath = data["url_l"] as? String {
            self.coverPath = lpath
            if let mw = data["width_l"] as? String, let mh = data["height_l"] as? String, let fw = Float(mw), let fh = Float(mh)  {
                
                self.coverSize = CGSize(width: CGFloat(fw), height: CGFloat(fh))
            }
        } else if let zpath = data["url_z"] as? String {
            self.coverPath = zpath
            if let mw = data["width_z"] as? String, let mh = data["height_z"] as? String, let fw = Float(mw), let fh = Float(mh)  {
                
                self.coverSize = CGSize(width: CGFloat(fw), height: CGFloat(fh))
            }
        }
        
        
        
    }
}

//  Cell setup
extension FlickrPhotoModel : ItemViewModel {
    
    var imageRemotePath: String? {
        get {
            return self.coverPath
        }
    }
    var caption : String? {
        get{
        return self.title
        }
    }
    var pid : String? {
        get{
            return self.piid
        }
    }
    
    func setup(_ view: UIView, _ container: UIView, indexPath: IndexPath) {
        if let c = view as? GridCollectionViewCell, let phid = self.pid {
            
            self.piid = phid
            if let t = thumbPath, let url = URL(string: t) {
                let dataTask = URLSession.cellSession.dataTask(with: url) { (data: Data?, response: URLResponse?, error :Error?) in
                    if let e = error {
                        print("load thumb error \(e.localizedDescription)")
                    } else if let imagedata = data {
                        DispatchQueue.main.async {
                            let image = UIImage(data: imagedata)
                            if let p = c.photo, let ii = image {
                                p.contentMode = .scaleAspectFill
                                p.image = ii
                            }
                        }
                    } else {
                        
                    }
                }
                dataTask.resume()
            }
            DispatchQueue.main.async {
                c.caption?.text = ""
                if let tt = self.title {
                    c.caption?.text = tt
                }
                c.layer.borderColor = UIColor(red: 0.8, green: 0.7, blue: 0.9, alpha: 0.8).cgColor
                c.layer.borderWidth = 0.5
            }
        }
    }
}

//  Flickr Section model for VC
struct FlickrListSectionModel : SectionModel {
    
    var header: ItemViewModel?
    var items: Array<ItemViewModel> = []
    var footer: ItemViewModel?
    
}
