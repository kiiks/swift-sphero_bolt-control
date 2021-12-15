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
    
    let DEFAULT_DURATION: Float = 0.1
    
    var mazeHeading: Double = 0.0
    var desertHeading: Double = 0.0
    var pumpHeading: Double = 0.0
    var manualHeading: Double = 0.0
    
    var sequence = [BasicMove]() {
        didSet {
            DispatchQueue.main.async {
                print("from sphero manager", self.sequence)
                self.spheroMovementManager?.playSequence()
                //self.sequence = [BasicMove]()
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
    
    func executeSpheroAction(action: String) {
        let command = ESP32SpheroCommand(rawValue: action)
        
        switch command {
        case .AV:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading, duration: DEFAULT_DURATION, speed: 80.0))
        case .AR:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading - 180, duration: DEFAULT_DURATION, speed: 80.0))
        case .G:
            mazeHeading -= 10.0
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading, duration: DEFAULT_DURATION, speed: 0.0))
        case .D:
            mazeHeading += 10.0
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading, duration: DEFAULT_DURATION, speed: 0.0))
        case .AVG:
            mazeHeading -= 10
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading, duration: DEFAULT_DURATION, speed: 80.0))
        case .AVD:
            mazeHeading += 10
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading, duration: DEFAULT_DURATION, speed: 80.0))
        case .ARG:
            mazeHeading += 10 // Inversing orientation since we are in rollback
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading - 180, duration: DEFAULT_DURATION, speed: 80.0))
        case .ARD:
            mazeHeading -= 10
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading - 180, duration: DEFAULT_DURATION, speed: 80.0))
        case .STOP:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading, duration: 0.0, speed: 0.0))
            default: break
        }
    }
    
    func executeMazeAction(action: String) {
        let command = ESP32SpheroCommand(rawValue: action)
        
        switch command {
        case .AV:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading, duration: DEFAULT_DURATION, speed: 80.0))
        case .AR:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading - 180, duration: DEFAULT_DURATION, speed: 80.0))
        case .G:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading - 90, duration: DEFAULT_DURATION, speed: 80.0))
        case .D:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading + 90, duration: DEFAULT_DURATION, speed: 80.0))
        case .AVG:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading - 45, duration: DEFAULT_DURATION, speed: 80.0))
        case .AVD:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading + 45, duration: DEFAULT_DURATION, speed: 80.0))
        case .ARG:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading - 190, duration: DEFAULT_DURATION, speed: 80.0))
        case .ARD:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading - 190, duration: DEFAULT_DURATION, speed: 80.0))
        case .STOP:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: mazeHeading, duration: 0.0, speed: 0.0))
            default: break
        }
    }
    
    func executePumpAction() {
        //SharedToyBox.instance.bolt?.roll(heading: pumpHeading, speed: 80)
        SharedToyBox.instance.boltById(id: ActivitySphero.LABYRINTHE.rawValue)?.roll(heading: pumpHeading, speed: 80)
        
        delay(1.8) {
            print("Stopped")
            SharedToyBox.instance.boltById(id: ActivitySphero.LABYRINTHE.rawValue)?.roll(heading: self.pumpHeading, speed: 0)
        }
    }
}
