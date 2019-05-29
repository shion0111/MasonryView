//
//  ItemDisplayContainerViewController.swift
//  ScaleTransitViewController
//
//  Created by Antelis on 2019/1/23.
//  Copyright © 2019 Antelis. All rights reserved.
//

import UIKit

public protocol ItemTransitionDelegate {
    func imageViewInSource() -> UIImageView?
    func imageViewInDest() -> UIImageView?
    func delegateSourceRect() -> CGRect
    func didFinishedTransition(_ isPresented: Bool, _ rect: CGRect, _ image:UIImage?)
    
}

public class ItemDisplayTransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    open var transitioningDelegate : ItemTransitionDelegate?
    open var toVC: UIViewController?
    open var fromVC: UIViewController?
    var isPresenting : Bool = false
    
    fileprivate var transitioningImageView :UIImageView?
    
    
    func calculateZoomedFrame(_ sourceimage: UIImage?, _ forview:UIView?) -> CGRect{
        //if let forview = forview,
        if let sourceimage = sourceimage {
        
            let h = sourceimage.size.height*UIScreen.main.bounds.width/sourceimage.size.width
            
            return CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width,height: h)
        }
        return forview?.frame ?? CGRect(x:0,y:0,width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.width)
    }
    func animateZoomInTransitionWithContext(_ transitionContext : UIViewControllerContextTransitioning?) {
        if let container = transitionContext?.containerView,
            
            let dest = self.toVC,
            let destimage = transitioningDelegate?.imageViewInDest() {
            
            let srcimage = transitioningDelegate?.imageViewInSource()
            let rect = transitioningDelegate?.delegateSourceRect()
            
            //destimage.isHidden = true
            container.addSubview(dest.view)
            
            dest.view.alpha = 0
            let img = srcimage?.image
            self.transitioningImageView = UIImageView.init(image: img)
            self.transitioningImageView?.contentMode = .scaleAspectFill
            self.transitioningImageView?.clipsToBounds = true
            self.transitioningImageView?.layer.cornerRadius = 8
            self.transitioningImageView?.frame = rect ?? CGRect.zero
            if let t = self.transitioningImageView {
                container.addSubview(t)
                srcimage?.isHidden = true
                let finalresult = self.calculateZoomedFrame(img, dest.view)
                UIView .animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .transitionCrossDissolve, animations: {
                    self.transitioningImageView?.frame = finalresult
                    if let nav = dest.navigationController {
                        nav.isNavigationBarHidden = true
                    }
                    dest.view.alpha = 1.0
                }) { (finished) in
                    
                    srcimage?.isHidden = false
                    destimage.isHidden = false
                    
                    transitionContext?.completeTransition(true)
                    if let d = self.transitioningDelegate {
                        d.didFinishedTransition(self.isPresenting, finalresult, self.transitioningImageView?.image)
                        self.transitioningImageView?.removeFromSuperview()
                    }
                    
                }
            }
        }
    }
    func animateZoomOutTransitionWithContext(_ transitionContext : UIViewControllerContextTransitioning?) {
        if let container = transitionContext?.containerView,
            let dest = self.toVC,
            let source = self.fromVC,
            let destimage = transitioningDelegate?.imageViewInDest(),
            let srcimage = transitioningDelegate?.imageViewInSource(),
            let src = transitioningDelegate?.delegateSourceRect() {
            
            self.transitioningImageView?.image = destimage.image
            self.transitioningImageView?.frame = destimage.frame
            self.transitioningImageView?.alpha = 1
            self.transitioningImageView?.layer.cornerRadius = 8
            container.addSubview(self.transitioningImageView!)
            
            // https://stackoverflow.com/questions/33513050/is-uiviewcontrollercontexttransitionings-containerview-really-the-view-that-co
            if let _ = dest.navigationController {
                container.insertSubview(dest.view, belowSubview: source.view)
            }
            //
            srcimage.isHidden = true
            container.bringSubviewToFront(self.transitioningImageView!)
            let sc = src.width / UIScreen.main.bounds.width
            UIView .animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .transitionCrossDissolve, animations: {
                self.transitioningImageView?.frame = src
                dest.view.alpha = 1
                source.view.transform = CGAffineTransform.init(scaleX:sc , y:sc )
                source.view.frame.origin = src.origin
                //source.view.transform = source.view.transform.translatedBy(x: src.origin.x, y:src.origin.y )
                source.view.alpha = 0
                
            }) { (finished) in
                
                srcimage.alpha = 1
                srcimage.isHidden = false
                dest.view.isHidden = false
                if let nav = dest.navigationController {
                    nav.delegate = nil
                }
                self.transitioningImageView?.removeFromSuperview()
                transitionContext?.completeTransition(true)
                
                if let d = self.transitioningDelegate {
                    d.didFinishedTransition(self.isPresenting, CGRect.zero, nil)
                
                }
            }
            
        }
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if self.isPresenting {
            return 0.5 }
        
        return 0.8
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if self.isPresenting {
            self.animateZoomInTransitionWithContext(transitionContext)
        } else {
            self.animateZoomOutTransitionWithContext(transitionContext)
        }
        
    }
    
    
}
class ItemDisplayVCDismissInteractionTransitioning: NSObject, UIViewControllerInteractiveTransitioning {
    
    var contextTransitioning : ItemDisplayVCTransitioningController?
    var animatedTransitioning : ItemDisplayTransitioningAnimator?
    var transitionContext : UIViewControllerContextTransitioning?
    var isPandDismissed : Bool = false
    var fromRect : CGRect = CGRect.zero
    var destRect : CGRect = CGRect.zero
    
    
    func didPanWith(_ pan: UIPanGestureRecognizer) {
        self.dragDismiss(pan)
    }
    private func panDismiss(_ pan: UIPanGestureRecognizer) {
        
    }
    private func dragDismiss(_ pan: UIPanGestureRecognizer) {
        guard let contextTransitioning = self.contextTransitioning,
            let animator = self.animatedTransitioning, let transitionContext = self.transitionContext,
            let transitioningImageView = animator.transitioningImageView else {
            return
        }
        
        if let source = animator.toVC,
            let dest = animator.fromVC,
            let destimage = contextTransitioning.transitionDelegate?.imageViewInDest(),
            let srcimage = contextTransitioning.transitionDelegate?.imageViewInSource(),
            let srcRect = contextTransitioning.transitionDelegate?.delegateSourceRect() {
            
            transitioningImageView.layer.cornerRadius = 8
            
            let anchor = CGPoint(x: destimage.frame.midX, y: destimage.frame.midY)
            let translatedPoint = pan.translation(in: destimage)
            var verticaldelta = translatedPoint.y
            if verticaldelta < 0 {
                verticaldelta = 0
            }
            let alpha = self.backgroundAlphaForDragDismiss(dest.view, verticaldelta)
            let scale = self.scaleForViewWithGestureDelta(dest.view, verticaldelta)
            dest.view.alpha = alpha*0.5
            
            let h0 = CGFloat(transitioningImageView.frame.height*(1-scale)*0.5)
            transitioningImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
            dest.view.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            //let rr = dest.view.frame
            
            let newCenter = CGPoint(x: anchor.x+translatedPoint.x, y: anchor.y+translatedPoint.y - h0)
            transitioningImageView.center = newCenter
            dest.view.frame.origin = transitioningImageView.frame.origin
            //dest.view.frame = rr.offsetBy(dx: newCenter.x-c.x , dy: newCenter.y-c.y)
            transitionContext.updateInteractiveTransition(1-scale)
            
            
            switch pan.state {
            case .ended:
                let v = pan.velocity(in: dest.view)
                // cancelled
                if v.y < 0 || newCenter.y < anchor.y {
                    UIView.animate(withDuration: animator.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .transitionCrossDissolve, animations: {
                        transitioningImageView.frame = destimage.frame
                        
                        dest.view.transform = CGAffineTransform.identity
                        dest.view.frame.origin = CGPoint.zero
                        dest.view.alpha = 1
                        
                    }) { (finished) in
                        destimage.alpha = 1
                        destimage.isHidden = false
                        
                        source.view.alpha = 1
                        srcimage.alpha = 1
                        srcimage.isHidden = false
                        
                        transitioningImageView.removeFromSuperview()
                        
                        let to = animator.toVC
                        animator.toVC = animator.fromVC
                        animator.fromVC = to
                        
                        transitionContext.cancelInteractiveTransition()
                        transitionContext.completeTransition(false)
                        
                    }
                } else {
                    if let nav = source.navigationController {
                        nav.setNavigationBarHidden(false, animated: false)
                    }
                    UIView.animate(withDuration: animator.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: .transitionCrossDissolve, animations: {
                        transitioningImageView.frame = srcRect
                        //transitioningImageView.alpha = 0
                        dest.view.alpha = 0
                        
                    }) { (finished) in
                        srcimage.alpha = 1
                        srcimage.isHidden = false
                        dest.view.isHidden = false
                        if let nav = source.navigationController {
                            nav.delegate = nil
                        
                        }
                        transitioningImageView.removeFromSuperview()
                        transitionContext.finishInteractiveTransition()
                        transitionContext.completeTransition(true)
                        
                        if let d = animator.transitioningDelegate {
                            d.didFinishedTransition(false, CGRect.zero, nil)
                            
                        }
                    }
                }
                break
                
            default: break
                
                
            }
            
            
        }
    }
    
    private func backgroundAlphaForPanDismiss(_ view: UIView?, _ panningDelta : CGFloat) -> CGFloat {
        return 0
    }
    private func backgroundAlphaForDragDismiss(_ view: UIView?, _ panningVerticalDelta : CGFloat) -> CGFloat {
        if let v = view {
            let max = v.bounds.height/CGFloat(2.0)
            let delta = min(abs(panningVerticalDelta)/max, 1.0)
            return 1.0 - delta*1.0
        }
        return 1
    }
    private func scaleForViewWithGestureDelta(_ view: UIView?, _ delta: CGFloat) -> CGFloat {
        if let v = view {
            let start = CGFloat(1.0), final = CGFloat(0.5), total = start - final
            let max = v.bounds.height/CGFloat(2.0)
            let delta = min(abs(delta)/max, 1.0)
            return start - delta * total
        }
        return 1
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let contextTransitioning = self.contextTransitioning, let animator = self.animatedTransitioning  else {
            return
        }
        self.transitionContext = transitionContext
        let container = transitionContext.containerView
        if let source = animator.toVC,
            let dest = animator.fromVC {
            
            let isNav = (dest.navigationController != nil)
            if isNav {
                container.insertSubview(source.view, belowSubview: dest.view)
            }
            
            
            if let destimage = contextTransitioning.transitionDelegate?.imageViewInDest(),
                let srcimage = contextTransitioning.transitionDelegate?.imageViewInSource() {//,let src = contextTransitioning.transitionDelegate?.delegateSourceRect() {
                
                animator.transitioningImageView = UIImageView(image: destimage.image)
                animator.transitioningImageView?.frame = destimage.frame
                animator.transitioningImageView?.contentMode = .scaleAspectFill
                animator.transitioningImageView?.clipsToBounds = true
                container.addSubview(animator.transitioningImageView!)
                container.bringSubviewToFront(animator.transitioningImageView!)
                
                destimage.isHidden = true
                srcimage.isHidden = true
            }
        }
    }
    
    
}
class ItemDisplayVCTransitioningController : NSObject, UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    var isPanDismissed : Bool = false
    var isInteractive : Bool = false
    fileprivate var transitionAnimator : ItemDisplayTransitioningAnimator?
    fileprivate var dismissInteractiveTransition : ItemDisplayVCDismissInteractionTransitioning?
    open var transitionDelegate : ItemTransitionDelegate?
    var sourceRect : CGRect = CGRect.zero
    var sourceView : UIImageView?
    
    override init() {
        super.init()
        self.transitionAnimator = ItemDisplayTransitioningAnimator();
        self.dismissInteractiveTransition = ItemDisplayVCDismissInteractionTransitioning()
        
    }
    
    ////
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator?.isPresenting = false
        
        // switch toVC and fromVC
        let to = self.transitionAnimator?.toVC
        self.transitionAnimator?.toVC = self.transitionAnimator?.fromVC
        self.transitionAnimator?.fromVC = to
        
        return self.transitionAnimator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.transitionAnimator?.isPresenting = true
        self.transitionAnimator?.toVC = presented
        self.transitionAnimator?.fromVC = presenting
        self.transitionAnimator?.transitioningDelegate = self.transitionDelegate
        return self.transitionAnimator
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        if self.isInteractive , let animator = animator as? ItemDisplayTransitioningAnimator{
            self.dismissInteractiveTransition?.animatedTransitioning = animator
            self.dismissInteractiveTransition?.contextTransitioning = self
            return self.dismissInteractiveTransition
        }
        
        return nil
    }
    /////
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if self.isInteractive, let animator = self.transitionAnimator{
            self.dismissInteractiveTransition?.animatedTransitioning = animator
            self.dismissInteractiveTransition?.contextTransitioning = self
            return self.dismissInteractiveTransition
        }
        
        return nil
    }
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
        self.transitionAnimator?.isPresenting = (operation == .push)
        
        self.transitionAnimator?.toVC = toVC
        self.transitionAnimator?.fromVC = fromVC
            
        
        self.transitionAnimator?.transitioningDelegate = self.transitionDelegate
        
        return self.transitionAnimator
    }
    
}
class ItemDisplayContainerViewController: UIViewController, UIGestureRecognizerDelegate,ItemTransitionDelegate {
    
    fileprivate var contentVC: ItemDisplayViewController?
    fileprivate var transitionController : ItemDisplayVCTransitioningController?
    private var viewModel : ItemDisplayViewModel? //photo : FlickrPhotoModel?
    private var panGesture : UIPanGestureRecognizer?
    var sourceRect : CGRect = CGRect.zero
    var sourceView : UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.transitionController = ItemDisplayVCTransitioningController()
        self.transitionController?.transitionDelegate = self
        self.modalPresentationStyle = .custom
        self.modalPresentationCapturesStatusBarAppearance = true
        self.transitioningDelegate = self.transitionController
        
    }
    
    func navigationControllerDelegate() -> UINavigationControllerDelegate? {
        
        return self.transitionController
    }
    func setPhoto(_ photo: ItemViewModel) {
        self.viewModel = ItemDisplayViewModel(photo)
    }
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let p = gestureRecognizer as? UIPanGestureRecognizer,
            let v = self.contentVC,
            let base = v.baseView {
            let velocity = p.velocity(in: self.view)
            let atTop = base.contentOffset.y < CGFloat(1.0)
            if velocity.y < 0 {
                return !atTop
            }
        }
        return true
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let v = self.contentVC, let base = v.baseView{
            let p = base.panGestureRecognizer
            if (p == otherGestureRecognizer) && (base.contentOffset.y == 0) {
                return true
            }
            
        }
        return false
    }
    
    @objc func didPan(_ pan:UIPanGestureRecognizer) {
        guard let c = self.contentVC, let v = self.contentVC?.view, let transitionController = transitionController, let interaction = transitionController.dismissInteractiveTransition else {
            return
        }
        switch pan.state {
        case .began:
            //let an = pan.location(in: v)
            let vel = pan.velocity(in: v)
            if vel.y > 0 &&  abs(vel.x) <= abs(vel.y) {
                transitionController.isInteractive = true
                c.baseView?.isScrollEnabled = false
                if let _ = self.navigationController {
                    self.navigationController?.delegate = transitionController
                    self.navigationController?.popViewController(animated: true)
                } else {
                    c .dismiss(animated: true, completion: nil)
                }
            }
            
            break
        case .failed, .cancelled:
            c.baseView?.isScrollEnabled = true
            break
        case .ended :
            c.baseView?.isScrollEnabled = true
            if transitionController.isInteractive {
                transitionController.isInteractive = false
                interaction.didPanWith(pan)
            }
            break
        default:
            if transitionController.isInteractive {
                interaction.didPanWith(pan)
            }
        }
        
        
        
    }
    @objc func dismissPressed(_ sender: Any?) {
        //self.contentVC?.dismiss(animated: true, completion: nil)
        if !self.contentVC!.isPresented {
            
            self.navigationController?.popViewController(animated: true)
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loadItemVC" {
            self.contentVC = segue.destination as? ItemDisplayViewController
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
            panGesture?.delegate = self
            if let p = panGesture, let vm = self.viewModel {
                self.contentVC?.loadViewModel(vm)
                self.contentVC?.isPresented = (self.navigationController == nil)//false//animator.isPresenting
                self.contentVC?.view.addGestureRecognizer(p)
                self.contentVC?.dismissBtn?.addTarget(self, action: #selector(dismissPressed), for: .touchUpInside)
            }
        }
    }
    
    //MARK:
    func imageViewInSource() -> UIImageView? {
        
        return self.sourceView
    }
    func imageViewInDest() -> UIImageView? {
        if let v = self.contentVC {
            return v.headerView
        }
        
        return nil
    }
    func delegateSourceRect() -> CGRect {
        return self.sourceRect
    }
    func didFinishedTransition(_ isPresented: Bool, _ rect: CGRect, _ image:UIImage?) {
        if let v = self.contentVC {
            if (isPresented), let vm = self.viewModel {
                v.prepareVC(rect, image)
                v.loadViewModel(vm)
                
            }
        }
        
    }
}
