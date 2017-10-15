//
//  Data+CC2650.swift
//  SensorTagCC2650
//
//  Created by Kazuya Shida on 2017/10/14.
//  Copyright © 2017 mani3. All rights reserved.
//

import Foundation

// swiftlint:disable identifier_name
fileprivate let SCALE_LSB: Float = 0.0312

enum AccelerationRange: Int {
    case range2G = 2
    case range4G = 4
    case range8G = 8
    case range16G = 16
}

// MARK: - IR Temperature

extension Data {

    /// object temperature
    var object: Float {
        let data = Data(self[0..<2]).to(type: UInt16.self) >> 2
        let temperature = Float(data) * SCALE_LSB
        return temperature
    }

    /// Ambience temperature
    var ambience: Float {
        let data = Data(self[2..<4]).to(type: UInt16.self) >> 2
        let temperature = Float(data) * SCALE_LSB
        return temperature
    }

}

// MARK: - Movement

extension Data {

    /// Calculate rotation, unit deg/s, range -250, +250
    var gyro: Float {
        let data = to(type: UInt16.self)
        return (Float(data) * 1.0) / (65536 / 500)
    }

    /// Calculate acceleration, unit G, range ±2, ±4, ±8, ±16
    ///
    /// - Parameter range: Acceleration range ±2, ±4, ±8, ±16
    /// - Returns: acceleration value
    func acc(range: AccelerationRange = .range2G) -> Float {
        let data = to(type: UInt16.self)
        let accRange = Float(range.rawValue)
        return (Float(data) * 1.0) / (32768 / accRange)
    }

    /// Calculate magnetism, unit uT, range +-4900
    var mag: Float {
        let data = to(type: UInt16.self)
        return (Float(data) * 1.0)
    }
}

// MARK: - Humidity

extension Data {

    /// Calculate temperature [°C]
    var temperature: Double {
        let data = Data(self[0..<2]).to(type: UInt16.self)
        let temperature = (Double(data) / 65536) * 165 - 40
        return temperature
    }

    /// Calculate relative humidity [%RH]
    var humidity: Double {
        let data = Data(self[0..<2]).to(type: UInt16.self) & ~0x0003
        let humidity = (Double(data) / 65536) * 100
        return humidity
    }
}

// MARK: - Pressure

extension Data {

    var pressure: Float {
        let data = to(type: UInt32.self)
        return Float(data) / 100
    }
}

// MARK: - Optical

extension Data {

    var optical: Float {
        let data = to(type: UInt16.self)
        let m = data & 0x0FFF
        var e = data & 0xF000 >> 12
        e = e == 0 ? 1 : 2 << (e - 1)
        return Float(m) * (0.01 * Float(e))
    }
}

extension Data {
    init<T>(from value: T) {
        var v = value
        self.init(buffer: UnsafeBufferPointer(start: &v, count: 1))
    }

    init<T>(from values: [T]) {
        var v = values
        self.init(buffer: UnsafeBufferPointer(start: &v, count: v.count))
    }

    func to<T>(type: T.Type) -> T {
        return withUnsafeBytes { $0.pointee }
    }
}
