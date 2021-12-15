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
    
    var currentSphero: ActivitySphero = ActivitySphero.LABYRINTHE
    
    // Executed when playSequence() is called
    override func playMove(move: BasicMove, moveDidFinish: @escaping (() -> ())) {
        executeMove(move: move)
        if move.durationInSec > 3.0 {
            
            delay(1.0) {
                self.executeMove(move: move)
                delay(1.0) {
                    moveDidFinish()
                }
            }
        }else{
            delay(move.durationInSec) {
                moveDidFinish()
            }
        }
    }
    
    
    func executeMove(move: BasicMove) {
        SharedToyBox.instance.boltById(id: currentSphero.rawValue)?.roll(heading: move.heading, speed: Double(move.speed))
    }
    
    func switchTo(sphero: ActivitySphero) {
        currentSphero = sphero
    }
}
