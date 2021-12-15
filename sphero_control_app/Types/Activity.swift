//
//  Activity.swift
//  sphero_control_app
//
//  Created by Killian DROULEZ on 14/12/2021.
//

import Foundation

enum Activity: String {
    case UNKNOWN = "UNKNOWN"
    case LABYRINTHE = "LBR"
    case DESERT = "DRT"
    case POMPE = "PMP"
}

enum ActivitySphero: String {
    case LABYRINTHE = "SB-2020"
    case DESERT = "SB-0994"
    case POMPE = "SB-42C1"
}
