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
    
    private var currentActivity: Activity = Activity.LABYRINTHE
    
    private var previousCommand: ESP32SpheroCommand = ESP32SpheroCommand.STOP
    
    private let DEFAULT_DURATION: Float = 0.1
    private let DEFAULT_SPEED: Float = 80.0
    
    private var mazeHeading: Double = 0.0
    private var desertHeading: Double = 0.0
    private var pumpHeading: Double = 0.0
    private var manualHeading: Double = 0.0
    
    private var sequence = [BasicMove]()
    
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
    
    // Execute sphero action like joystick control
    func executeSpheroAction(action: String, act:Activity? = nil) {
        let command = ESP32SpheroCommand(rawValue: action)
        print(command)
        switch command {
        case .AV:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: desertHeading, duration: DEFAULT_DURATION, speed: 80.0))
        case .AR:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: desertHeading - 180, duration: DEFAULT_DURATION, speed: 80.0))
        case .G:
            desertHeading -= 10.0
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: desertHeading, duration: DEFAULT_DURATION, speed: 0.0))
        case .D:
            desertHeading += 10.0
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: desertHeading, duration: DEFAULT_DURATION, speed: 0.0))
        case .AVG:
            desertHeading -= 10
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: desertHeading, duration: DEFAULT_DURATION, speed: 80.0))
        case .AVD:
            desertHeading += 10
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: desertHeading, duration: DEFAULT_DURATION, speed: 80.0))
        case .ARG:
            desertHeading += 10 // Inversing orientation since we are in rollback
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: desertHeading - 180, duration: DEFAULT_DURATION, speed: 80.0))
        case .ARD:
            desertHeading -= 10
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: desertHeading - 180, duration: DEFAULT_DURATION, speed: 80.0))
        case .STOP:
            self.spheroMovementManager?.executeMove(move: SpheroMove(heading: desertHeading, duration: 0.0, speed: 0.0))
            default: break
        }
    }
    
    // Keeping heading during maze thus the user don't has to recalibrate the sphero during activity.
    // Left and right action are working like rollback
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
        previousCommand = command!
    }
    
    // Apply force to sphero from begining of the pump corridor to the end
    func executePumpAction() {
        SharedToyBox.instance.boltById(id: ActivitySphero.POMPE.rawValue)?.roll(heading: pumpHeading, speed: 80)
        
        delay(1.8) {
            SharedToyBox.instance.boltById(id: ActivitySphero.POMPE.rawValue)?.roll(heading: self.pumpHeading, speed: 0)
        }
    }
}
