//
//  CC2650.swift
//  SensorTagCC2650
//
//  Created by Kazuya Shida on 2017/10/13.
//  Copyright © 2017 mani3. All rights reserved.
//

import CoreBluetooth

struct CC2650 {

    enum Service: String {
        case temperature = "F000AA00-0451-4000-B000-000000000000"
        case movement    = "F000AA80-0451-4000-B000-000000000000"
        case humidity    = "F000AA20-0451-4000-B000-000000000000"
        case pressure    = "F000AA40-0451-4000-B000-000000000000"
        case optical     = "F000AA70-0451-4000-B000-000000000000"
        case io          = "F000AA64-0451-4000-B000-000000000000"

        var uuid: CBUUID {
            return CBUUID(string: rawValue)
        }

        static var all: [CBUUID] {
            return [
                Service.temperature.uuid,
                Service.movement.uuid,
                Service.humidity.uuid,
                Service.pressure.uuid,
                Service.optical.uuid,
                Service.io.uuid
            ]
        }
    }

    enum Characteristic: String {
        case tempData = "F000AA01-0451-4000-B000-000000000000"
        case tempConfig = "F000AA02-0451-4000-B000-000000000000"
        case tempPeriod = "F000AA03-0451-4000-B000-000000000000"

        case moveData = "F000AA81-0451-4000-B000-000000000000"
        case moveConfig = "F000AA82-0451-4000-B000-000000000000"
        case movePeriod = "F000AA83-0451-4000-B000-000000000000"

        case humidityData = "F000AA21-0451-4000-B000-000000000000"
        case humidityConfig = "F000AA22-0451-4000-B000-000000000000"
        case humidityPeriod = "F000AA23-0451-4000-B000-000000000000"

        case pressureData = "F000AA41-0451-4000-B000-000000000000"
        case pressureConfig = "F000AA42-0451-4000-B000-000000000000"
        case pressurePeriod = "F000AA44-0451-4000-B000-000000000000"

        case opticalData = "F000AA71-0451-4000-B000-000000000000"
        case opticalConfig = "F000AA72-0451-4000-B000-000000000000"
        case opticalPeriod = "F000AA73-0451-4000-B000-000000000000"

        case ioData = "F000AA65-0451-4000-B000-000000000000"
        case ioConfig = "F000AA66-0451-4000-B000-000000000000"

        var uuid: CBUUID {
            return CBUUID(string: rawValue)
        }
    }
}
