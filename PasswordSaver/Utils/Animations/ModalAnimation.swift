//
//  ModalAnimation.swift
//  PasswordSaver
//
//  Created by Victor Martins Rabelo on 08/02/18.
//  Copyright © 2018 Victor Martins Rabelo. All rights reserved.
//

import UIKit

class ModalAnimation: NSObject,UIViewControllerAnimatedTransitioning {
    private var showing : Bool
    
    let backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.75)
    
    init(showing: Bool) {
        self.showing = showing
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
        let containerView = transitionContext.containerView
        let backGroud = UIView()
        if showing {
            containerView.addSubview(backGroud)
            containerView.addSubview(toView)
            
            backGroud.center = fromView.center
            backGroud.frame = fromView.frame
            
            backGroud.backgroundColor = .clear
            toView.center.y += UIScreen.main.bounds.height

        } else {
            containerView.addSubview(backGroud)
            containerView.addSubview(fromView)
            backGroud.center = fromView.center
            backGroud.frame = fromView.frame
            
            fromView.backgroundColor = .clear
            backGroud.backgroundColor = self.backgroundColor
            
        }
        
        
        UIView.animate(withDuration: 0.6, animations: {
            if self.showing {
                toView.center.y = 0
                backGroud.backgroundColor = self.backgroundColor
                toView.center.y = UIScreen.main.bounds.height/2
            } else {
                fromView.center.y += UIScreen.main.bounds.height
                backGroud.backgroundColor = .clear
            }
            
        }, completion: {
            finished in
            
            if self.showing {
                toView.backgroundColor = self.backgroundColor
                backGroud.removeFromSuperview()
            } else {
                backGroud.removeFromSuperview()
                fromView.removeFromSuperview()
            }
            
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
