//
//  ViewController.swift
//  sphero_control_app
//
//  Created by Killian DROULEZ on 01/12/2021.
//

import UIKit

class MainController: UIViewController, ActivityListener {
    
    
    @IBOutlet weak var espStateLabel: UILabel!
    @IBOutlet weak var spheroStateLabel: UILabel!
    
    let activityManager: ActivityManager = ActivityManager.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        activityManager.register(listener: self)
    }
    
    // MARK: -- UI Events
    
    @IBAction func connectionToSphero(_ sender: Any) {
        activityManager.connectToSpheros()
    }
    
    // MARK: -- Connection callbacks
    
    func connectedToESP32() {
        self.espStateLabel.text = "[Connected]"
    }
    
    func disconnectedFromESP32() {
        self.espStateLabel.text = "[Disconnected] \nPlease connect to 'PALM_Wifi'"
    }
    
    func connectedToSphero() {
        self.spheroStateLabel.text = "[Connected]"
    }
    
    func disconnectedFromSphero() {
        self.spheroStateLabel.text = "[Disconnected]"
    }
    
}
