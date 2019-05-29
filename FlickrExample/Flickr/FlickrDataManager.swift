//
//  FlickrDataManager.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/5/27.
//  Copyright © 2019 Antelis. All rights reserved.
//

import Foundation
import UIKit
import Masonry

let FlickrAPIKey = ""

//  Flickr JSON Decoder
class FlickrDataManager : NSObject {
    
    var samplePhotos: [FlickrPhotoModel] = []
    
    var photoCount : Int {
        return samplePhotos.count
    }
    
    func photoAtIndex(_ index: Int) -> FlickrPhotoModel? {
        if index >= samplePhotos.count {
            return nil
        }
        
        return samplePhotos[index]
    }
    private func parsePhotoData(_ data: Data?, _ completionHandler:@escaping ((_ sectionModel: FlickrListSectionModel?, _ error : CustomError?) -> Void) ) {
        guard let data = data else {
            completionHandler(nil, CustomError("Empty JSON Data", "", 9998))
            return
        }
        
        do {
            let photos = try JSONSerialization.jsonObject(with: data, options: [.mutableLeaves, .allowFragments])
            if let ps = photos as? Dictionary<String, Any>, let pts = ps["photos"] as? Dictionary<String,Any>, let list = pts["photo"] as? Array<Dictionary<String, Any>> {
                
                list.forEach { (item: Dictionary<String, Any>) in
                    let photo = FlickrPhotoModel(item)
                    self.samplePhotos.append(photo)
                }
                let sectionModel = FlickrListSectionModel(header: nil, items: samplePhotos, footer: nil)
                completionHandler(sectionModel, nil)
            }
            
        } catch let error as NSError {
            let er = CustomError("JSON parse error ",error.localizedDescription, error.code)
            completionHandler(nil, er)
        }
        
        //
    }
    func retrievePhotoData(_ page: Int, _ completionHandler:@escaping ((_ sectionModel: FlickrListSectionModel?, _ error : CustomError?) -> Void) ) {
        
        let session : URLSession = URLSession.init(configuration: URLSessionConfiguration.default)
        let path = "https://api.flickr.com/services/rest/?method=flickr.groups.pools.getPhotos&api_key=\(FlickrAPIKey)&group_id=34778850%40N00&extras=o_dims,url_m,url_z,url_l&per_page=48&format=json&nojsoncallback=1&page=\(page)"
        
        if let url = URL(string: path) {
            let dataTask = session.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
                if let error = error as NSError? {
                    
                    let cerror = CustomError("Network Error", error.localizedDescription, error.code)
                    completionHandler(nil, cerror)
                    return
                } else if let data = data {
                    self.parsePhotoData(data, completionHandler)
                } else {
                    let err = CustomError("Data Error", "No data received", 9999)
                    completionHandler(nil, err)
                }
            }
            dataTask.resume()
        }
    }
    
}

