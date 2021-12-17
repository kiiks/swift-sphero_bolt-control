//
//  WebSocketManager.swift
//  SimpleTest
//
//  Created by al on 30/11/2021.
//  Copyright © 2021 vluxe. All rights reserved.
//

import Foundation
import Starscream

class WebSocketManager: WebSocketDelegate {
    
    static let instance = WebSocketManager()
    var sockets = [String:WebSocket]()
    
    var receivedData: ((String)->())?
    var connected: (()->())?
    var disconnected: (()->())?
    
    func addSocket(url:String,path:String) {
        var request = URLRequest(url: URL(string: url+path)!)
        request.timeoutInterval = 5
        let socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
        sockets[path] = socket
    }
    
    func didReceivedData(callback:@escaping (String)->()) {
        self.receivedData = callback
    }
    
    func didConnect(callback:@escaping ()->()) {
        self.connected = callback
    }
    
    func didDisconnect(callback:@escaping ()->()) {
        self.disconnected = callback
    }
    
    func send(value:String){
        if sockets.count == 0 { return }
        
        sockets["/ws"]?.write(string: value, completion: {
            print("sended to ESP32 :", value)
        })
    }
    
    func reconnectToWebsocket() {
        sockets["/ws"]?.connect()
    }
    
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        switch event {
        case .connected(let headers):
            if let callback = self.connected {
                callback()
            }
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            if let callback = self.disconnected {
                callback()
            }
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            if let callback = self.receivedData{
                callback(string)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            self.reconnectToWebsocket()
            break
        case .cancelled:
            print("websocket has been cancelled")
            self.reconnectToWebsocket()
            break
        case .error(let error):
            print("An error occured on websocket")
            break
        }
    }
}
