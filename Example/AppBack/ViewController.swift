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
        
        AppBack.shared.configure(apiKey: "RIvzTBbH7LnHsxBmomzogxov0B4lW7tumhho5jaTxLMjfAPv4t1589904786")
        AppBack.shared.getTranslations(router: "translations_jutilities", lenguageIdentifier: "es_CO") { (ready) in
            if ready {
                let username = AppBack.shared.getTranslation(key: "general.userName")
                print(username)
            } else {
                print("NOUP")
            }
        }
        
        
//        AppBack.shared.getToggles(router: "ft_1") { (ready) in
//            if ready {
//                print("todo OK 2")
//            } else {
//                print("noup 2")
//            }
//        }
//        AppBack.shared.addEventLog(router: "ev1", eventName: "evento iOS", description: "description de iOS", logLevel: .error) { (ready) in
//            if ready {
//                print("todo OK 3")
//            } else {
//                print("noup 3")
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

