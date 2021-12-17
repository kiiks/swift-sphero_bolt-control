//
//  ManualCommandViewController.swift
//  sphero_control_app
//
//  Created by Killian DROULEZ on 14/12/2021.
//

import UIKit

class ManualCommandViewController: UIViewController {
    
    @IBOutlet weak var spheroSelector: UISegmentedControl!
    
    var currentActivity: Activity = Activity.LABYRINTHE
    var spheroActivityManager: SpheroActivityManager = SpheroActivityManager.instance
    
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: -- Direction buttons action

    
    @IBAction func onRightBtnHold(_ sender: UIButton) {
        print("right button hold")
        spheroActivityManager.executeSpheroAction(action: ESP32SpheroCommand.D.rawValue,act: currentActivity)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onRightBtnHold(_:)), userInfo: nil, repeats: false)
    }
    
    @IBAction func onRightBtnReleased(_ sender: UIButton) {
        print("right button released")
        timer?.invalidate()
        stopSphero()
    }
    
    @IBAction func onLeftBtnHold(_ sender: UIButton) {
        print("left button hold")
        spheroActivityManager.executeSpheroAction(action: ESP32SpheroCommand.G.rawValue,act: currentActivity)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(onLeftBtnHold(_:)), userInfo: nil, repeats: false)
    }
    
    
    @IBAction func onLeftBtnReleased(_ sender: UIButton) {
        print("left button released")
        timer?.invalidate()
        stopSphero()
    }
    
    @IBAction func onFowardBtnHold(_ sender: UIButton) {
        print("foward button hold")
        spheroActivityManager.executeSpheroAction(action: ESP32SpheroCommand.AV.rawValue)
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(onFowardBtnHold(_:)), userInfo: nil, repeats: false)
    }
    
    
    @IBAction func onFowardBtnReleased(_ sender: UIButton) {
        print("foward button released")
        timer?.invalidate()
        stopSphero()
        
    }
    
    @IBAction func onBackBtnHold(_ sender: UIButton) {
        print("back button hold")
        spheroActivityManager.executeSpheroAction(action: ESP32SpheroCommand.AR.rawValue)
        timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(onBackBtnHold(_:)), userInfo: nil, repeats: false)
    }
    
    @IBAction func onBackBtnReleased(_ sender: UIButton) {
        print("back button released")
        timer?.invalidate()
        stopSphero()
    }
    
    @IBAction func stopSphero() {
        timer?.invalidate()
        spheroActivityManager.executeSpheroAction(action: ESP32SpheroCommand.STOP.rawValue)
    }
    
    @IBAction func onPressureActionBtn(_ sender: UIButton) {
        print("manual pressure action")
        //stopSphero()
        spheroActivityManager.executePumpAction()
    }
    
    
    @IBAction func onSegmentedControlChanged(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            let activity = Activity.LABYRINTHE
            currentActivity = activity
            spheroActivityManager.switchActivitySphero(activity: activity)
            ActivityManager.instance.currentActivity = activity
            
        case 1:
            let activity = Activity.DESERT
            currentActivity = activity
            spheroActivityManager.switchActivitySphero(activity: activity)
            ActivityManager.instance.currentActivity = activity
        case 2:
            let activity = Activity.POMPE
            currentActivity = activity
            spheroActivityManager.switchActivitySphero(activity: activity)
            ActivityManager.instance.currentActivity = activity
        default:
            return
        }
    }
    
    
}
