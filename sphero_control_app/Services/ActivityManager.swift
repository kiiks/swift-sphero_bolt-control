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
    
    private  let wsURL: String = "http://192.168.4.1"
    private let wsPath: String = "/ws"
    private var wsManager: WebSocketManager = WebSocketManager.instance
    
    private let spheroManager: SpheroManager = SpheroManager.instance
    
    // MARK: Activity variables
    
    private var nbMazeLEDEnbaled = 0 // Max 3
    private var nbDesertLEDEnabled = 0 // Max 3
    
    private var currentPressure = 0 // From 0 to 150
    private var pressureDelivered = false
    
    private var activitiesFinished = 0
    
    // Default activity is the maze
    var currentActivity: Activity = Activity.MAZE
    
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
        if (data == "RAZ") { return }
        let components = data.components(separatedBy: "@")
        let activity = whichActivity(activityId: components[0])
        let data = components[1].components(separatedBy: ":")
        let commandType = data[0]
        let command = data[1]
        
        switch activity {
        case .MAZE:
            if currentActivity == .MAZE {
                if commandType == CommandType.INFO.rawValue {
                    nbMazeLEDEnbaled = Int(command) ?? nbMazeLEDEnbaled
                    if nbMazeLEDEnbaled == 3 {
                        activitiesFinished += 1
                    }
                }
                if commandType == CommandType.CTRL.rawValue {
                    spheroManager.executeMazeAction(action: command)
                }
            }
        case .DESERT:
            if currentActivity == .DESERT {
            if commandType == CommandType.INFO.rawValue {
                nbDesertLEDEnabled = Int(command) ?? nbDesertLEDEnabled
                if nbMazeLEDEnbaled == 3 {
                    activitiesFinished += 1
                }
            }
            if commandType == CommandType.CTRL.rawValue {
                spheroManager.executeSpheroAction(action: command)
            }
            }
        case .PUMP:
            if currentActivity == .PUMP {
            if commandType ==  CommandType.INFO.rawValue {
                // TODO: Determine wich value is efficient to stop pumping & simulate pressure loss
                currentPressure = Int(command) ?? -1
                if currentPressure >= 150 && !pressureDelivered{
                    pressureDelivered = true
                    activitiesFinished += 1
                    spheroManager.executePumpAction()
                }
            }
            }
        }
    }
    
    // MARK: -- Sphero connection
    
    public func connectToSpheros() {
        spheroManager.connectToActivitySpheros(connected: {
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
        }
        return Activity.MAZE
    }
    
    // MARK: -- Activity actions
    
    public func resetActivities() {
        wsManager.send(value: "CMD@RAZ")
    }
}
