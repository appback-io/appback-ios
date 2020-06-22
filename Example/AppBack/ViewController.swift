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
    
    @IBOutlet weak var languagesLabel: UILabel!
    @IBOutlet weak var translateExample: UILabel!
    @IBOutlet weak var toggleExample: UILabel!
    @IBOutlet weak var eventLogExample: UILabel!
    
    private var sendDeviceInformation = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLanguagesExample()
        getTranslationsExample()
        getToggleExample()
        sendEventLogExample()
    }
    
    @IBAction func sendDeviceInformationChanged(_ sender: UISwitch) {
        sendDeviceInformation = sender.isOn
    }
    
    /// Sends event log
    func sendEventLogExample() {
        
        let parameters = [["key1": "this is a test"], ["key2": "1234"]]
        
        AppBack.shared.addEventLog(router: "events_prod", eventName: "hola_evento", parameters: parameters, deviceInformation: sendDeviceInformation) { [weak self] (success, parameters) in
            if success {
                
                var eventLogMessage = "EventLog example:\n"
                
                for value in (parameters ?? []).enumerated() {
                    eventLogMessage += "\(value.element)\n"
                }
                
                self?.eventLogExample.text = eventLogMessage
                
            } else {
                print("noup 3")
            }
        }
    }
    
    /// Sets toggle configuration and gets a value as example
    func getToggleExample() {
        AppBack.shared.getToggles(router: "toggles_prod") { [weak self] (ready) in
            if ready {
                let toggleKey = "bool_test"
                guard let value = AppBack.shared.getBoolToggle(key: toggleKey) else {
                    self?.toggleExample.text = "\(toggleKey): key Not found"
                    return
                }
                var message = "Toggle example\n"
                message += "\(toggleKey): \(value)"
                self?.toggleExample.text = message
            } else {
                self?.toggleExample.text = "Fetching error, please check your configuration"
            }
        }
    }
    
    /// Sets all translation configuration and gets a value as example
    func getTranslationsExample() {
        AppBack.shared.getTranslations(router: "translations_jutilities", languageIdentifier: "ES") { [weak self] (ready) in
            if ready {
                var message = "Translation example:\n"
                let translationKey = "general.greeting"
                let value = AppBack.shared.getTranslation(key: translationKey)
                message += "\(translationKey): \(value)"
                self?.translateExample.text = message
            } else {
                self?.translateExample.text = "Fetching error, please check your dashboard"
            }
        }
    }
    
    /// Gets all languages in a router
    func getLanguagesExample() {
        AppBack.shared.getLanguages(router: "translations_jutilities") { [weak self] (success, languages)  in
            if success, let languages = languages {
                var values = "Languages: \n"
                for language in languages {
                    guard let name = language.name, let identifier = language.identifier else { continue }
                    values += "\(name): \(identifier)\n"
                }
                self?.languagesLabel.text = values
            }
        }
    }
    
}



