//
//  ViewController.swift
//  SensorTagCC2650
//
//  Created by Kazuya Shida on 2017/10/10.
//  Copyright © 2017 mani3. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreBluetooth

class ViewController: UIViewController {
    let dispose = DisposeBag()

    @IBOutlet weak var tableView: UITableView!

    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(scan), for: .valueChanged)
        return refreshControl
    }()

    lazy var centralManager: CBCentralManager = {
       let manager = CBCentralManager(delegate: self, queue: nil)
        return manager
    }()

    var peripherals = Variable<[CBPeripheral]>([])

    override func viewDidLoad() {
        super.viewDidLoad()

        peripherals.asDriver()
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { (_, item: CBPeripheral, cell) in
                cell.textLabel?.text = item.name
                cell.detailTextLabel?.text = item.identifier.uuidString
            }
            .addDisposableTo(dispose)

        tableView.addSubview(refreshControl)
        tableView.rx
            .modelSelected(CBPeripheral.self)
            .subscribe(onNext: { (peripharal) in
                self.performSegue(withIdentifier: "SensorTagSegue", sender: peripharal)
            })
            .addDisposableTo(dispose)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        peripherals.value.removeAll()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl.beginRefreshing()
        tableView.setContentOffset(
            CGPoint(x: 0, y: tableView.contentOffset.y - refreshControl.frame.height), animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.refreshControl.sendActions(for: .valueChanged)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? SensorTagViewController,
            let peripheral = sender as? CBPeripheral {
            viewController.centralManager = centralManager
            viewController.peripheral = peripheral
        }
    }

    func scan() {
        centralManager.delegate = self
        if !centralManager.isScanning {
            centralManager.scanForPeripherals(withServices: nil, options: nil)

            DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
                self?.centralManager.stopScan()
                self?.refreshControl.endRefreshing()
            }
        } else {
            refreshControl.endRefreshing()
        }
    }
}

extension ViewController: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        scan()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String,
            name.lowercased().contains("sensortag") {
            if peripherals.value.filter({ $0 == peripheral }).isEmpty {
                peripherals.value.append(peripheral)
            }
        }
    }
}
