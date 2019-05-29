//
//  ItemDisplayViewController.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/1/23.
//  Copyright © 2019 Antelis. All rights reserved.
//

import UIKit

public class ItemDisplayViewController: UIViewController {
    
    @IBOutlet weak var headerView : UIImageView?
    @IBOutlet weak var dismissBtn : UIButton?
    @IBOutlet weak var headerHeight : NSLayoutConstraint?
    @IBOutlet weak var baseView: UIScrollView?
    @IBOutlet weak var itemInfoText : UILabel?
    var isPresented: Bool = false
    
    private var viewModel : ItemDisplayViewModel?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

    }
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func loadViewModel(_ vm : ItemDisplayViewModel) {
        self.viewModel = vm //vm.copy() as? ItemDisplayViewModel
        
    }
    func prepareVC(_ rect: CGRect, _ image:UIImage?) {
        
        guard let p = self.viewModel?.headerImagePath else { return }
        
        if let i = image {
            self.headerView?.frame = rect
            self.headerHeight?.constant = rect.height
            self.headerView?.image = i
        }
        if  let url = URL(string: p) {
            //let size = p.coverSize
            let URLsession = URLSession(configuration: URLSessionConfiguration.default)
            
            let datatask = URLsession.dataTask(with: url) { (data :Data?,response: URLResponse?, error:Error?) in
                if let d = data, let image = UIImage(data: d) {
                    DispatchQueue.main.async {
                        let size = image.size
                        let w = self.view.frame.width
                        let h = size.height*w/size.width                        
                        self.headerView?.frame = CGRect(x: 0, y: 0, width: w, height: h)
                        self.headerHeight?.constant = h
                        self.headerView?.image = image
                        self.headerView?.contentMode = .scaleAspectFill
                        self.itemInfoText?.text = self.viewModel?.caption
                    }
                }
            }
            
            datatask.resume()
        }
    }
    
    @IBAction func dismissBtnPressed(_ sender:Any?) {
        if self.isPresented {
            self.dismiss(animated: true, completion: nil)
        } else {
          
        }
    }
    
}
