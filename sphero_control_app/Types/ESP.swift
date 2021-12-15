//
//  ESP.swift
//  sphero_control_app
//
//  Created by Killian DROULEZ on 14/12/2021.
//

import Foundation

enum CommandType: String {
    case INFO = "INFO"
    case CTRL = "CTRL"
}

enum ESP32SpheroCommand: String {
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
