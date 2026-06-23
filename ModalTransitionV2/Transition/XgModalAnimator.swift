//
//  XgModalAnimator.swift
//  Demo
//
//  Created by lpc on 2024/7/3.
//

import UIKit

class XgModalAnimator: NSObject {
    // 页面动画类型
    enum AnimatorType {
        case modal, push
    }
    var animatType: AnimatorType = .modal
}


//MARK: - present Animator
class XgModalPresentAnimator: XgModalAnimator, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        ///获取转场动画进行的视图
        let containerView = transitionContext.containerView
        ///获取控制器
        guard let fromViewController = transitionContext.viewController(forKey: .from),
                let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        ///获取视图
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            return
        }

        let fromControllerFrame = transitionContext.initialFrame(for: fromViewController)
        let toControllerFrame = transitionContext.finalFrame(for: toViewController)
        toView.frame = toControllerFrame

        containerView.insertSubview(toView, aboveSubview: fromView)

        let maskView = UIView(frame: containerView.bounds)
        maskView.backgroundColor = .clear // 初始透明-->黑
        containerView.insertSubview(maskView, aboveSubview: fromView) // fromView(0)--maskView--toView
        
        let width = fromControllerFrame.size.width
        let height = fromControllerFrame.size.height
        let toFrame = CGRectOffset(fromControllerFrame, 0, 0) // 在屏幕显示
        switch animatType {
        case .modal:
            toView.frame = CGRectOffset(fromControllerFrame, 0, height) // 初始在下
        case .push:
            toView.frame = CGRectOffset(fromControllerFrame, width, 0) // 初始在右
        }

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            // fromView.frame = toFrame
            toView.frame = toFrame
            maskView.backgroundColor = .black.withAlphaComponent(0.35)
        }, completion:{(_) in
            maskView.removeFromSuperview()
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                 toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!cancelled)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
}


//MARK: - dismiss Animator
class XgModalDismissAnimator: XgModalAnimator, UIViewControllerAnimatedTransitioning {
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        ///获取转场动画进行的视图
        let containerView = transitionContext.containerView
        let containerOriginBgColor = containerView.backgroundColor
        containerView.backgroundColor = .black
        
        ///获取控制器
        guard let fromViewController = transitionContext.viewController(forKey: .from),
                let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        ///获取视图
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else {
            return
        }

        let fromControllerFrame = transitionContext.initialFrame(for: fromViewController)
        let toControllerFrame = transitionContext.finalFrame(for: toViewController)

        toView.frame = toControllerFrame
        containerView.insertSubview(toView, belowSubview: fromView)

        let maskView = UIView(frame: containerView.bounds)
        maskView.backgroundColor = .black.withAlphaComponent(0.5) // 初始黑-->透明
        containerView.insertSubview(maskView, aboveSubview: toView) // toView(0)--maskView--fromView
        
        let width = fromControllerFrame.size.width
        let height = fromControllerFrame.size.height
        var toFrame: CGRect
        switch animatType {
        case .modal:
            toFrame = CGRectOffset(fromControllerFrame, 0, height) // 从屏幕消失->停在下
        case .push:
            toFrame = CGRectOffset(fromControllerFrame, width, 0) // 从屏幕消失->停在右
        }

        // 先缩放,模拟下沉效果
        toView.transform = CGAffineTransform(scaleX: 0.975, y: 0.975)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toView.transform = .identity
            fromView.frame = toFrame
            maskView.backgroundColor = UIColor.clear
        }, completion:{(_) in
            containerView.backgroundColor = containerOriginBgColor // 还原
            toView.transform = .identity
            maskView.removeFromSuperview()
            let cancelled = transitionContext.transitionWasCancelled
            if cancelled {
                toView.removeFromSuperview()
            }
            transitionContext.completeTransition(!cancelled)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.35
    }
}
