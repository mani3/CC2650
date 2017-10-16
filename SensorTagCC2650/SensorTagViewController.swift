//
//  SensorTagViewController.swift
//  SensorTagCC2650
//
//  Created by Kazuya Shida on 2017/10/11.
//  Copyright © 2017 mani3. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreBluetooth

class SensorTagViewController: UIViewController {
    let dispose = DisposeBag()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logView: UITextView!

    var centralManager: CBCentralManager?
    var peripheral: CBPeripheral?
    var characteristics = Variable<[CBCharacteristic]>([])

    override func viewDidLoad() {
        super.viewDidLoad()

        characteristics.asDriver()
            .throttle(0.3)
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { (_, item: CBCharacteristic, cell) in
                cell.textLabel?.text = "\(item.propertyName)"
                cell.detailTextLabel?.text = item.uuid.uuidString
            }
            .addDisposableTo(dispose)

        tableView.rx.modelSelected(CBCharacteristic.self)
            .subscribe(onNext: { [weak self] (characteristic) in
                if characteristic.properties.rawValue & CBCharacteristicProperties.read.rawValue != 0 {
                    self?.peripheral?.readValue(for: characteristic)
                }
                if characteristic.uuid.isEqual(CC2650.Characteristic.tempConfig.uuid)
                    || characteristic.uuid.isEqual(CC2650.Characteristic.humidityConfig.uuid)
                    || characteristic.uuid.isEqual(CC2650.Characteristic.pressureConfig.uuid)
                    || characteristic.uuid.isEqual(CC2650.Characteristic.opticalConfig.uuid) {
                    self?.peripheral?.writeValue(Data([0x01]), for: characteristic, type: .withResponse)
                }
                if characteristic.uuid.isEqual(CC2650.Characteristic.moveConfig.uuid) {
                    self?.peripheral?.writeValue(Data([0xFF, 0x00]), for: characteristic, type: .withResponse)
                }
            })
            .addDisposableTo(dispose)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let manager = centralManager, let peripheral = peripheral {
            manager.delegate = self
            manager.connect(peripheral, options: nil)
        } else {
            dismiss(animated: true) {}
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let manager = centralManager, let peripheral = peripheral {
            manager.delegate = nil
            manager.cancelPeripheralConnection(peripheral)
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension SensorTagViewController: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
    }
}

// MARK: - CBPeripheralDelegate

extension SensorTagViewController: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            NSLog("%@, %@", #function, error.localizedDescription)
            return
        }
        guard let services = peripheral.services, !services.isEmpty else {
            return
        }
        for service in services {
            NSLog("%@", service.debugDescription)
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            NSLog("%@, %@", #function, error.localizedDescription)
            return
        }
        guard let characteristics = service.characteristics, !characteristics.isEmpty else {
            return
        }
        for characteristic in characteristics {
            NSLog("%@", characteristic.debugDescription)
            self.characteristics.value.append(characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("%@, %@", #function, error.localizedDescription)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            NSLog("%@, %@", #function, error.localizedDescription)
            return
        }
        guard let data = characteristic.value else {
            return
        }

        if characteristic.uuid.isEqual(CC2650.Characteristic.tempData.uuid) {
            logView.appendLog(text: "\(characteristic.name): object=\(data.object) ℃, ambience=\(data.ambience) ℃")
        } else if characteristic.uuid.isEqual(CC2650.Characteristic.moveData.uuid) {
            logView.appendLog(text: "\(characteristic.name): gyro x=\(Data(data[0..<2]).gyro), y=\(Data(data[2..<4]).gyro), z=\(Data(data[4..<6]).gyro)")
            logView.appendLog(text: "\(characteristic.name): acc x=\(Data(data[6..<8]).acc()), y=\(Data(data[8..<10]).acc()), z=\(Data(data[10..<12]).acc())")
            logView.appendLog(text: "\(characteristic.name): mag x=\(Data(data[12..<14]).mag), y=\(Data(data[14..<16]).mag), z=\(Data(data[16..<18]).mag)")
        } else if characteristic.uuid.isEqual(CC2650.Characteristic.humidityData.uuid) {
            logView.appendLog(text: "\(characteristic.name): temp=\(data.temperature), humidity=\(data.humidity)")
        } else if characteristic.uuid.isEqual(CC2650.Characteristic.pressureData.uuid) {
            logView.appendLog(text: "\(characteristic.name): pressure=\(Data(data[3..<6]).pressure)")
        } else if characteristic.uuid.isEqual(CC2650.Characteristic.opticalData.uuid) {
            logView.appendLog(text: "\(characteristic.name): oprical=\(data.optical)")
        } else if data.count == 1 {
            logView.appendLog(text: "\(characteristic.name): \(String(format: "0x%02X ", data[0]))")
        } else if let text = String(bytes: data, encoding: .utf8) {
            logView.appendLog(text: "\(characteristic.name): \(text)")
        } else {
            let message: String = data.map { String(format: "%02X ", $0) }.joined()
            logView.appendLog(text: "\(characteristic.name): \(message)")
        }
    }
}

// MARK: - UITextView

extension UITextView {

    func appendLog(text: String, animated: Bool = true) {
        DispatchQueue.main.async {
            let formatter: DateFormatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let now = formatter.string(from: Date())
            self.text = String(format: "%@[%@] %@\n", self.text, now, text)
            self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height), animated: animated)
        }
    }
}
