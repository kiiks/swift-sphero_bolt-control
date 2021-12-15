//
//  SpheroActivityManager.swift
//  sphero_control_app
//
//  Created by Killian DROULEZ on 13/12/2021.
//

import Foundation

class SpheroActivityManager {
    static let instance = SpheroActivityManager()
    
    var spheroMovementManager: SpheroMovementManager? = nil
    
    var currentActivity: Activity = Activity.LABYRINTHE
    var currentHeading: Double = 0.0
    
    var sequence = [BasicMove]() {
        didSet {
            DispatchQueue.main.async {
                self.spheroMovementManager? = SpheroMovementManager(sequence: self.sequence)
                self.spheroMovementManager?.playSequence()
                self.sequence = [BasicMove]()
            }
        }
    }
    
    init() {
        spheroMovementManager = SpheroMovementManager(sequence: self.sequence)
    }
    
    // MARK: -- Sphero connection
    
    func connectToActivitySpheros(connected: @escaping (() -> ()), disconnected: @escaping (() -> ())) {
        SharedToyBox.instance
        .searchForBoltsNamed([ActivitySphero.LABYRINTHE.rawValue,
                              ActivitySphero.DESERT.rawValue,
                              ActivitySphero.POMPE.rawValue]) { err in
            if err == nil {
                print("Connected to Sphero BOLT")
                connected()
            }
        }
        SharedToyBox.instance.box.listenForDisconnection { p in
            print("Disconnected from Sphero BOLT", p.name!)
            disconnected()
        }
    }
    
    // MARK: -- Sphero actions
    
    func switchActivitySphero(activity: Activity) {
        currentActivity = activity
        
        switch activity {
        case .UNKNOWN:
            return
        case .LABYRINTHE:
            spheroMovementManager?.switchTo(sphero: ActivitySphero.LABYRINTHE)
        case .DESERT:
            spheroMovementManager?.switchTo(sphero: ActivitySphero.DESERT)
        case .POMPE:
            spheroMovementManager?.switchTo(sphero: ActivitySphero.POMPE)
        }
    }
    
    func pressureAction() {
        guard currentActivity == Activity.POMPE else {
            return
        }
        
        let fowardMove = SpheroMove(heading: currentHeading, duration: 2, speed: 80.0)
        self.spheroMovementManager?.executeMove(move: fowardMove)
    }
    
    func executeSpheroAction(action: String) {
        let command = ESP32SpheroCommand(rawValue: action)
        let duration: Float = 0.1
        
        switch command {
        case .AV:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading, duration: duration, speed: 80.0))
        case .AR:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading - 180, duration: duration, speed: 80.0))
        case .G:
            currentHeading -= 10.0
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading, duration: duration, speed: 0.0))
        case .D:
            currentHeading += 10.0
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading, duration: duration, speed: 0.0))
        case .AVG:
            currentHeading -= 10
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading, duration: duration, speed: 80.0))
        case .AVD:
            currentHeading += 10
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading, duration: duration, speed: 80.0))
        case .ARG:
            currentHeading += 10 // Inversing orientation since we are in rollback
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading - 180, duration: duration, speed: 80.0))
        case .ARD:
            currentHeading -= 10
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading - 180, duration: duration, speed: 80.0))
        case .STOP:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading, duration: 0.0, speed: 0.0))
            default: break
        }
    }
    
    func executeMazeAction(action: String) {
        let command = ESP32SpheroCommand(rawValue: action)
        let duration: Float = 0.1
        
        switch command {
        case .AV:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading, duration: duration, speed: 80.0))
        case .AR:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading - 180, duration: duration, speed: 80.0))
        case .G:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading - 90, duration: duration, speed: 80.0))
        case .D:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading + 90, duration: duration, speed: 80.0))
        case .AVG:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading - 45, duration: duration, speed: 80.0))
        case .AVD:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading + 45, duration: duration, speed: 80.0))
        case .ARG:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading - 190, duration: duration, speed: 80.0))
        case .ARD:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading - 190, duration: duration, speed: 80.0))
        case .STOP:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: currentHeading, duration: 0.0, speed: 0.0))
            default: break
        }
    }
}
