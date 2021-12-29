//
//  SpheroMovementManager.swift
//  SparkPerso
//
//  Created by AL on 18/10/2019.
//  Copyright © 2019 AlbanPerli. All rights reserved.
//
//  (REWORKED)

import Foundation

class SpheroMovementManager: GenericMovementManager {
    
    var currentSphero: SpheroID = SpheroID.MAZE
    
    // Executed when playSequence() is called
    override func playMove(move: BasicMove, moveDidFinish: @escaping (() -> ())) {
        self.executeMove(move: move)
        delay(3.0) {
            self.executeMove(move: SpheroMove(heading: move.heading, duration: 0.0, speed: 0.0))
            moveDidFinish()
        }
    }
    
    func executeMove(move: BasicMove) {
        SharedToyBox.instance.boltById(id: currentSphero.rawValue)?.roll(heading: move.heading, speed: Double(move.speed))
    }
    
    func switchTo(sphero: SpheroID) {
        currentSphero = sphero
    }
}
