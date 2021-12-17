//
//  SharedToyBox.swift
//  SpheroManager
//
//  Created by AL on 01/09/2019.
//  Copyright © 2019 AL. All rights reserved.
//

import Foundation
import UIKit

class SharedToyBox {
    
    static let instance = SharedToyBox()
    
    private var searchCallBack:((Error?)->())?
    
    let box = ToyBox()
    var boltsNames = [String]()
    var bolts:[BoltToy] = []
    
    var bolt:BoltToy? {
        get {
            return bolts.first
        }
    }
    
    func boltById(id: String) -> BoltToy? {
        return self.bolts.first(where: {(bolt: BoltToy) -> Bool in
            bolt.peripheral?.name == id
        })
    }
    
    init() {
        box.addListener(self)
    }
    
    func searchForBoltsNamed(_ names:[String], doneCallBack:@escaping (Error?)->()) {
        searchCallBack = doneCallBack
        boltsNames = names
        box.start()
    }
    
    func stopScan() {
        box.stopScan()
    }
    
}

extension SharedToyBox:ToyBoxListener{
    func toyBoxReady(_ toyBox: ToyBox) {
        box.startScan()
    }
    
    func toyBox(_ toyBox: ToyBox, discovered descriptor: ToyDescriptor) {
        print("discovered \(descriptor.name)")
        
        if bolts.count >= boltsNames.count {
            box.stopScan()
        }else{
            if boltsNames.contains(descriptor.name ?? "") {
                let bolt = BoltToy(peripheral: descriptor.peripheral, owner: toyBox)
                bolts.append(bolt)
                toyBox.connect(toy: bolt)
            }
        }
        
    }
    
    func toyBox(_ toyBox: ToyBox, readied toy: Toy) {
        print("readied")
        if let b = toy as? BoltToy {
            print(b.peripheral?.name ?? "")
            if let i = self.bolts.firstIndex(where: { (item) -> Bool in
                item.identifier == b.identifier
            }){
                self.bolts[i] = b
                switch b.peripheral?.name {
                case ActivitySphero.LABYRINTHE.rawValue:
                    b.setupLEDArrow(color: UIColor.orange)
                case ActivitySphero.DESERT.rawValue:
                    b.setupLEDArrow(color: UIColor.blue)
                case ActivitySphero.POMPE.rawValue:
                    b.setupLEDArrow(color: UIColor.red)
                default:
                    return
                }
            }
            
            if bolts.count >= boltsNames.count {
                DispatchQueue.main.async {
                    self.searchCallBack?(nil)
                }
            }
        }
    }
    
    func toyBox(_ toyBox: ToyBox, putAway toy: Toy) {
        print("put away")
    }
    
    
}

