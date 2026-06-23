//
//  ViewController.swift
//  ModalTransition
//
//  Created by longm3 on 2026/6/22.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func openVC(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TestVC") as! TestViewController
        vc.modalPresentationStyle = .fullScreen
        vc.configGestureToBack()
        present(vc, animated: true)
    }
    
    @IBAction func openNav(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TestVC") as! TestViewController
        let nav = BaseNavController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.configGestureToBack()
        present(nav, animated: true)
    }
}


// MARK: - VC

class TestViewController: UIViewController {
    
    @IBOutlet weak var lab: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let nav = navigationController {
            lab.text = "第 \(nav.viewControllers.count) 个"
        } else {
            lab.text = "modal"
        }
    }
    
    @IBAction func backClick(_ sender: Any) {
        if let nav = navigationController, nav.viewControllers.count > 1 {
            nav.popViewController(animated: true)
            return
        } else {
            dismiss(animated: true)
        }
    }
    
    @IBAction func pushClick(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "TestVC") as! TestViewController
        navigationController?.pushViewController(vc, animated: true)
    }
}


// MARK: - Nav

class BaseNavController: UINavigationController {
    
}
