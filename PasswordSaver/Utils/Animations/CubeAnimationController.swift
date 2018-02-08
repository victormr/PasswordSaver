//
//  CubeAnimation.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 06/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

class CubeAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private var showing : Bool
    let interactionController: SwipeInteractionController?
    
    init(showing: Bool, interactionController: SwipeInteractionController?) {
        self.showing = showing
        self.interactionController = interactionController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from)
            else {
                return
        }
        
        let fromView = fromVC.view!
        let toView = toVC.view!
        
        let direction: CGFloat = self.showing ? 1 : -1
        let const: CGFloat = -0.005
                
        let containerView = transitionContext.containerView
        if self.showing {
            fromView.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            toView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            
            containerView.addSubview(toView)
            fromView.center.x = UIScreen.main.bounds.width
            toView.center.x = UIScreen.main.bounds.width
        } else {
            fromView.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            toView.layer.anchorPoint = CGPoint(x: 1, y: 0.5)
            
            containerView.addSubview(toView)
            toView.center.x = 0
            fromView.center.x = 0
        }
        
        var viewFromTransform: CATransform3D = CATransform3DMakeRotation(direction * .pi/2, 0.0, 1.0, 0.0)
        var viewToTransform: CATransform3D = CATransform3DMakeRotation(-direction * .pi/2, 0.0, 1.0, 0.0)
        viewFromTransform.m34 = const
        viewToTransform.m34 = const
        
        toView.layer.transform = viewToTransform
        
        UIView.animate(withDuration: 0.6, animations: {
            if self.showing {
                fromView.center.x = 0
                fromView.layer.transform = viewFromTransform
                
                toView.center.x = 0
                toView.layer.transform = CATransform3DIdentity
            } else {
                toView.center.x = UIScreen.main.bounds.width
                toView.layer.transform = CATransform3DIdentity
                
                fromView.center.x = UIScreen.main.bounds.width
                fromView.layer.transform = viewFromTransform
            }
            
        }, completion: {
            finished in
            containerView.transform = .identity
            fromView.layer.transform = CATransform3DIdentity
            toView.layer.transform = CATransform3DIdentity
            
            fromView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            toView.center.x = fromView.bounds.width/2
            fromView.center.x = fromView.bounds.width/2
            
            if self.showing {
                fromView.removeFromSuperview()
            } else {
                toView.removeFromSuperview()
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

}
