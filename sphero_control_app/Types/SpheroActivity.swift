//
//  SpheroActivity.swift
//  sphero_control_app
//
//  Created by Killian DROULEZ on 17/12/2021.
//

import Foundation

class SpheroActivity {
    var id: String
    var heading: Double = 0.0
    
    let DEFAULT_DURATION: Double = 0.1
    let DEFAULT_SPEED: Double = 80.0
    
    init(id: String) {
        self.id = id
    }
    
    func executeMove(move: BasicMove) {
        SharedToyBox.instance.boltById(id: id)?.roll(heading: move.heading, speed: Double(move.speed))
    }
    
    func foward() {
        SharedToyBox.instance.boltById(id: id)?.roll(heading: heading, speed: DEFAULT_SPEED)
    }
    
    func backward() {
        SharedToyBox.instance.boltById(id: id)?.roll(heading: heading - 180, speed: DEFAULT_SPEED)
    }
    
    func right() {
        heading += 10
        SharedToyBox.instance.boltById(id: id)?.roll(heading: heading, speed: 0.0)
    }
    
    func left() {
        heading -= 10
        SharedToyBox.instance.boltById(id: id)?.roll(heading: heading, speed: 0.0)
    }
    
    func rightFoward() {
        heading += 10
        SharedToyBox.instance.boltById(id: id)?.roll(heading: heading, speed: DEFAULT_SPEED)
    }
    
    func leftFoward() {
        heading -= 10
        SharedToyBox.instance.boltById(id: id)?.roll(heading: heading, speed: DEFAULT_SPEED)
    }
    
    func rightBackward() {
        heading -= 10
        SharedToyBox.instance.boltById(id: id)?.roll(heading: heading - 180, speed: DEFAULT_SPEED)
    }
    
    func leftBackward() {
        heading += 10
        SharedToyBox.instance.boltById(id: id)?.roll(heading: heading - 180, speed: DEFAULT_SPEED)
    }
    
    func stop() {
        SharedToyBox.instance.boltById(id: id)?.roll(heading: heading, speed: 0.0)
    }
}
