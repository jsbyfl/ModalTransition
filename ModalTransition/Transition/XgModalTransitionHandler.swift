//
//  XgModalTransitionHandler.swift
//  Demo
//
//  Created by lpc on 2024/7/3.
//

import UIKit

//MARK: - XgModalTransitionHandler
/// 处理模态转场动画
@objcMembers public class XgModalTransitionHandler: NSObject {
    private var interactor: XgModalInteractor?
    
    /// 为某个vc注入动画
    @discardableResult
    public static func injectModalTransition(for controller: UIViewController) -> XgModalTransitionHandler {
        let transition = XgModalTransitionHandler()
        transition.interactor = XgModalInteractor(viewController: controller)
        controller.transitioningDelegate = transition
        controller.transition = transition
        if let nav = controller as? UINavigationController {
            nav.delegate = transition
        }
        return transition
    }
    
    /// 设置手势可用状态
    public func setupPanGesture(enable: Bool) {
        interactor?.transitionRecognizer?.isEnabled = enable
    }
}

extension XgModalTransitionHandler: UIViewControllerTransitioningDelegate {

    // present
//    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        let animator = XgModalPresentAnimator()
//        return animator
//    }
    
    // dismiss
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animator = XgModalDismissAnimator()
        return animator
    }
    
    // dismiss(处理手势动画)
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if let interactive = self.interactor?.interactive, interactive == true {
            return self.interactor
        } else {
            return nil
        }
    }
}

extension XgModalTransitionHandler: UINavigationControllerDelegate {

    /// UINavigationControllerDelegate

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        setupPanGesture(enable: false)
    }
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 1 {
            setupPanGesture(enable: false)
        } else {
            setupPanGesture(enable: true)
        }
    }
}



//MARK: - XgModalInteractor
/// 模态转场动画-场景管理(手势)
class XgModalInteractor: UIPercentDrivenInteractiveTransition {
    /// 手势
    private(set) var transitionRecognizer: UIPanGestureRecognizer?
    
    private(set) public var interactive: Bool = false
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        
        let panGR = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(gestureDrivenInteractiveTransition(_:)))
        panGR.edges = .left
        viewController.view.addGestureRecognizer(panGR)
        transitionRecognizer = panGR
    }
    
    @objc func gestureDrivenInteractiveTransition(_ recognizer: UIPanGestureRecognizer) {
        let progress = recognizer.translation(in: viewController?.view).x / (viewController?.view.bounds.size.width ?? 1.0)
        
        switch recognizer.state {
        case .began:
            interactive = true
            viewController?.dismiss(animated: true, completion: nil)
            
        case .changed:
            update(progress)
            
        case .ended:
            interactive = false
            let velocity = recognizer.velocity(in: viewController?.view)
            if velocity.x > 600.0 || progress > 0.5 {
                completionSpeed = 0.35
                finish()
            } else {
                cancel()
            }
            
        case .cancelled:
            interactive = false
            cancel()
            
        default:
            break
        }
    }
}


//MARK: - ex
private var transitionKey: UInt8 = 0
extension UIViewController {
    
    fileprivate var transition: XgModalTransitionHandler? {
        get { objc_getAssociatedObject(self, &transitionKey) as? XgModalTransitionHandler }
        set { objc_setAssociatedObject(self, &transitionKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @objc public func configGestureToBack() {
        XgModalTransitionHandler.injectModalTransition(for: self)
    }
    
    @objc public func setupBackGesture(_ enable: Bool) {
        transition?.setupPanGesture(enable: enable)
    }
}
