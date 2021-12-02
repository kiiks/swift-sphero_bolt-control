//
//  ViewController.swift
//  sphero_control_app
//
//  Created by Killian DROULEZ on 01/12/2021.
//

import UIKit

enum Activity: String {
    case UNKNOWN = "UNKNOWN"
    case LABYRINTHE = "LBR"
    case DESERT = "DRT"
    case POMPE = "PMP"
}

enum BtnSpheroCommand: String {
    case STOP = "0"
    case G = "1"
    case D = "2"
    case AR = "4"
    case ARG = "5"
    case ARD = "6"
    case AV = "8"
    case AVG = "9"
    case AVD = "10"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var espStateLabel: UILabel!
    @IBOutlet weak var spheroStateLabel: UILabel!
    

    let wsURL: String = "http://192.168.4.1"
    let wsPath: String = "/ws"
    var wsManager: WebSocketManager = WebSocketManager.instance
    
    var spheroMovementManager: SpheroMovementManager? = nil
    var sequence = [BasicMove]() {
        didSet {
            DispatchQueue.main.async {
                self.spheroMovementManager = SpheroMovementManager(sequence: self.sequence)
                self.spheroMovementManager?.playSequence()
                self.sequence = [BasicMove]()
            }
        }
    }
    
    var currentHeading: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wsManager.addSocket(url: wsURL, path: wsPath)
        wsManager.didConnect(callback: self.connectedToESP32)
        wsManager.didReceivedData(callback: self.didRecieveFromESP32)
        
        spheroMovementManager = SpheroMovementManager(sequence: self.sequence)
    }
    
    
    @IBAction func connectionToSphero(_ sender: Any) {
        SharedToyBox.instance.searchForBoltsNamed(["SB-2020"]) { err in
            if err == nil {
                self.spheroStateLabel.text = "[Connected]"
                print("Connected to Sphero BOLT")
            }
        }
        
        SharedToyBox.instance.box.listenForDisconnection { p in
            print(p.name)
            self.spheroStateLabel.text = "[Disconnected]"
        }
        
    }
    
    func connectedToESP32() {
        self.espStateLabel.text = "[Connected]"
    }
    
    func disconnectedFromESP32() {
        self.espStateLabel.text = "[Disconnected]"
    }
    
    func didRecieveFromESP32(data: String) {
        print(data)
        let components = data.components(separatedBy: "@")
        let activity = whichActivity(activityId: components[0])
        let action = components[1]
        
        switch activity {
        case .UNKNOWN:
            return
        case .LABYRINTHE:
            executeMazeActivity(action: action)
        case .DESERT:
            return
        case .POMPE:
            return
        }
        
    }
    
    func whichActivity(activityId: String) -> Activity {
        if let activity = Activity(rawValue: activityId) {
            return activity
        } else {
            return Activity.UNKNOWN
        }
    }
    
    func executeMazeActivity(action: String) {
        let command = BtnSpheroCommand(rawValue: action)
        let duration: Float = 0.1
        
        switch command {
        case .AV:
            self.sequence.append(SpheroMove(heading: currentHeading, duration: duration, speed: 80.0))
        case .AR:
            self.sequence.append(SpheroMove(heading: currentHeading - 180, duration: duration, speed: 80.0))
        case .G:
            currentHeading -= 10.0
            self.sequence.append(SpheroMove(heading: currentHeading, duration: duration, speed: 0.0))
        case .D:
            currentHeading += 10.0
            self.sequence.append(SpheroMove(heading: currentHeading, duration: duration, speed: 0.0))
        case .AVG:
            currentHeading -= 10
            self.sequence.append(SpheroMove(heading: currentHeading, duration: duration, speed: 80.0))
        case .AVD:
            currentHeading += 10
            self.sequence.append(SpheroMove(heading: currentHeading, duration: duration, speed: 80.0))
        case .ARG:
            currentHeading += 10 // Inversing orientation since we are in rollback
            self.sequence.append(SpheroMove(heading: currentHeading - 180, duration: duration, speed: 80.0))
        case .ARD:
            currentHeading -= 10
            self.sequence.append(SpheroMove(heading: currentHeading - 180, duration: duration, speed: 80.0))
        case .STOP:
            self.sequence.append(SpheroMove(heading: currentHeading, duration: 0.0, speed: 0.0))
            default: break
        }
    }
}
