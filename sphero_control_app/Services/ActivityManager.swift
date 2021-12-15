//
//  ActivityManager.swift
//  sphero_control_app
//
//  Created by Killian DROULEZ on 13/12/2021.
//

import Foundation

protocol ActivityListener {
    func connectedToESP32()
    func disconnectedFromESP32()
    func connectedToSphero()
    func disconnectedFromSphero()
}

class ActivityManager {
    // MARK: Object variable
    
    static let instance = ActivityManager()
    
    private var listeners: [ActivityListener] = []
    
    let wsURL: String = "http://192.168.4.1"
    let wsPath: String = "/ws"
    var wsManager: WebSocketManager = WebSocketManager.instance
    
    let spheroActivityManager: SpheroActivityManager = SpheroActivityManager.instance
    
    // MARK: Activity variables
    
    var mazeLEDs = [false, false, false]
    var desertLEDs = [false, false, false]
    var currentPressure = 0
    
    
    // Default activity is the maze
    private var currentActivity: Activity = Activity.LABYRINTHE
    
    // MARK: Init
    
    init() {
        wsManager.addSocket(url: wsURL, path: wsPath)
        wsManager.didConnect(callback: self.connected)
        wsManager.didDisconnect(callback: self.disconnected)
        wsManager.didReceivedData(callback: self.didRecieve)
    }
    
    // MARK: -- WS Callbacks
    
    private func connected() {
        for listener in listeners {
            listener.connectedToESP32()
        }
    }
    
    private func disconnected() {
        for listener in listeners {
            listener.disconnectedFromESP32()
        }
    }
    
    private func didRecieve(data: String) {
        print(data)
        let components = data.components(separatedBy: "@")
        let activity = whichActivity(activityId: components[0])
        let data = components[1].components(separatedBy: ":")
        let commandType = data[0]
        let command = data[1]
        
        switch activity {
        case .UNKNOWN:
            return
        case .LABYRINTHE:
            if commandType == CommandType.CTRL.rawValue {
                spheroActivityManager.executeMazeAction(action: command)
            }
        case .DESERT:
            if commandType == CommandType.CTRL.rawValue {
                spheroActivityManager.executeSpheroAction(action: command)
            }
            return
        case .POMPE:
            return
        }
    }
    
    // MARK: -- Sphero connection
    
    public func connectToSpheros() {
        spheroActivityManager.connectToActivitySpheros(connected: {
            for listener in self.listeners {
                listener.connectedToSphero()
            }
        }, disconnected: {
            for listener in self.listeners {
                listener.disconnectedFromSphero()
            }
        })
    }
    
    // MARK: -- Utils
    
    public func register(listener: ActivityListener) {
        self.listeners.append(listener)
    }
    
    public func whichActivity(activityId: String) -> Activity {
        if let activity = Activity(rawValue: activityId) {
            return activity
        } else {
            return Activity.UNKNOWN
        }
    }
    
    // MARK: -- Activity actions
    
    
}
