//
//  SpheroActivityManager.swift
//  sphero_control_app
//
//  Created by Killian DROULEZ on 13/12/2021.
//

import Foundation

class SpheroManager {
    static let instance = SpheroManager()
    
    private var currentActivity: Activity {
        get { return ActivityManager.instance.currentActivity }
    }
    
    private var mazeSphero: SpheroActivity = SpheroActivity(id: SpheroID.MAZE.rawValue);
    private var desertSphero: SpheroActivity = SpheroActivity(id: SpheroID.DESERT.rawValue);
    private var pumpSphero: SpheroActivity = SpheroActivity(id: SpheroID.PUMP.rawValue);
    
    // MARK: -- Sphero connection
    
    func connectToActivitySpheros(connected: @escaping (() -> ()), disconnected: @escaping (() -> ())) {
        SharedToyBox.instance
        .searchForBoltsNamed([SpheroID.MAZE.rawValue,
                              SpheroID.DESERT.rawValue,
                              SpheroID.PUMP.rawValue]) { err in
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
    
    // MARK: -- Sphero management
    
    func spheroFromCurrentActivity() -> SpheroActivity {
        switch currentActivity {
        case .MAZE:
            return mazeSphero
        case .DESERT:
            return desertSphero
        case .PUMP:
            return pumpSphero
        }
    }
    
    // MARK: -- Sphero actions
    
    // Execute sphero action like joystick control
    func executeSpheroAction(action: String) {
        let command = ESP32SpheroCommand(rawValue: action)
        let sphero = spheroFromCurrentActivity()
        
        switch command {
        case .AV:
            sphero.foward()
        case .AR:
            sphero.backward()
        case .G:
            sphero.left()
        case .D:
            sphero.right()
        case .AVG:
            sphero.leftFoward()
        case .AVD:
            sphero.rightFoward()
        case .ARG:
            sphero.leftBackward()
        case .ARD:
            sphero.rightBackward()
        case .STOP:
            sphero.stop()
            default: break
        }
    }
    
    // Keeping heading during maze thus the user don't has to recalibrate the sphero during activity.
    // Left and right action are working like rollback
    func executeMazeAction(action: String) {
        if currentActivity != .MAZE { return }
        let command = ESP32SpheroCommand(rawValue: action)
        let sphero = spheroFromCurrentActivity()
        let heading = sphero.heading
        let duration = Float(sphero.DEFAULT_DURATION)
        let speed = Float(sphero.DEFAULT_SPEED)
        
        switch command {
        case .AV:
            sphero.executeMove(move: SpheroMove(heading: heading, duration: duration, speed: speed))
        case .AR:
            sphero.executeMove(move: SpheroMove(heading: heading - 180, duration: duration, speed: speed))
        case .G:
            sphero.executeMove(move: SpheroMove(heading: heading - 90, duration: duration, speed: speed))
        case .D:
            sphero.executeMove(move: SpheroMove(heading: heading + 90, duration: duration, speed: speed))
        case .AVG:
            sphero.executeMove(move: SpheroMove(heading: heading - 45, duration: duration, speed: speed))
        case .AVD:
            sphero.executeMove(move: SpheroMove(heading: heading + 45, duration: duration, speed: speed))
        case .ARG:
            sphero.executeMove(move: SpheroMove(heading: heading - 190, duration: duration, speed: speed))
        case .ARD:
            sphero.executeMove(move: SpheroMove(heading: heading - 190, duration: duration, speed: speed))
        case .STOP:
            sphero.executeMove(move: SpheroMove(heading: heading, duration: 0.0, speed: 0.0))
            default: break
        }
    }
    
    // Rolling sphero across the pump corridor
    func executePumpAction() {
        if currentActivity != .PUMP { return }
        let sphero = spheroFromCurrentActivity()
        sphero.foward()
        
        delay(1.8) {
            sphero.stop()
        }
    }
}
