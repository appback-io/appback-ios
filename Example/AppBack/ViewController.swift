//
//  ViewController.swift
//  AppBack
//
//  Created by slozano95 on 12/20/2019.
//  Copyright (c) 2019 slozano95. All rights reserved.
//

import UIKit
import AppBack

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        AppBack.shared.configure(apiKey: "2fZ1CNZWfyfuSYRuNQBtP8nWYipbFtFbzNNlpMYvFPlUDg9l787RZ6SwEnKl")
        // Do any additional setup after loading the view, typically from a nib.
        AppBack.shared.getTranslations(router: "1_transl") { (ready) in
            if ready {
                print("TODO OK")
            } else {
                print("NOUP")
            }
        }
        AppBack.shared.getToggles(router: "ft_1") { (ready) in
            if ready {
                print("todo OK 2")
            } else {
                print("noup 2")
            }
        }
        AppBack.shared.addEventLog(router: "ev1", eventName: "evento iOS", description: "description de iOS", logLevel: .error) { (ready) in
            if ready {
                print("todo OK 3")
            } else {
                print("noup 3")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func rgerg(_ sender: Any) {
        AppBack.shared.addEventLog(router: "ev1", eventName: "evento iOS", description: "description de iOS", logLevel: .error) { (ready) in
            if ready {
                print("todo OK 3")
            } else {
                print("noup 3")
            }
        }
    }
}

