//
//  CBCharacteristic.swift
//  SensorTagCC2650
//
//  Created by Kazuya Shida on 2017/10/11.
//  Copyright © 2017 mani3. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBCharacteristic {
    
    var propertyName: String {
        var name = [String]()
        if properties.rawValue & CBCharacteristicProperties.broadcast.rawValue != 0 {
            name.append("broadcast")
        }
        if properties.rawValue & CBCharacteristicProperties.read.rawValue != 0 {
            name.append("Read")
        }
        if properties.rawValue & CBCharacteristicProperties.write.rawValue != 0 {
            name.append("WriteWithoutResponse")
        }
        if properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue != 0 {
            name.append("Write")
        }
        if properties.rawValue & CBCharacteristicProperties.notify.rawValue != 0 {
            name.append("Notify")
        }
        if properties.rawValue & CBCharacteristicProperties.indicate.rawValue != 0 {
            name.append("Indicate")
        }
        if properties.rawValue & CBCharacteristicProperties.authenticatedSignedWrites.rawValue != 0 {
            name.append("AuthenticatedSignedWrites")
        }
        if properties.rawValue & CBCharacteristicProperties.extendedProperties.rawValue != 0 {
            name.append("ExtendedProperties")
        }
        return name.joined(separator: ", ")
    }
}
