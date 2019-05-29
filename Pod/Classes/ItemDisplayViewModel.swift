//
//  ItemDisplayViewModel.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/5/27.
//  Copyright © 2019 Antelis. All rights reserved.
//

import Foundation
import UIKit

public class ItemDisplayViewModel : NSObject {
    
    var headerImagePath : String?
    var caption : String?
    
    private var pid : String?
    
    convenience init(_ withPhoto: ItemViewModel) {
        self.init()
        headerImagePath = withPhoto.imageRemotePath
        caption = withPhoto.caption
        pid = withPhoto.pid
    }
    
    
}
