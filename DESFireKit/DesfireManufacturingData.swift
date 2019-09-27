//
//  DesfireManufacturingData.swift
//  DESFireKit
//
//  Created by Fabian Thies on 27.09.19.
//  Copyright © 2019 Fabian Thies. All rights reserved.
//

import Foundation

public class DesfireManufacturingData {

    private let hardwareBytes = 7
    private let softwareBytes = 7
    private let uidBytes = 7
    private let batchNumberBytes = 5
    private let productionBytes = 2

    let hardwareVendorId: UInt8
    let hardwareType: UInt8
    let hardwareSubtype: UInt8
    let hardwareVersionMajor: UInt8
    let hardwareVersionMinor: UInt8
    let hardwareStorageSize: UInt8
    let hardwareProtocol: UInt8

    let softwareVendorId: UInt8
    let softwareType: UInt8
    let softwareSubtype: UInt8
    let softwareVersionMajor: UInt8
    let softwareVersionMinor: UInt8
    let softwareStorageSize: UInt8
    let softwareProtocol: UInt8

    let uid: [UInt8]
    let batchNumber: [UInt8]
    let productionWeek: UInt8
    let productionYear: UInt8


    init?(data: Data) {
        var data = data
        guard data.count >= self.hardwareBytes + self.softwareBytes + self.uidBytes + self.batchNumberBytes + self.productionBytes else {
            return nil
        }

        self.hardwareVendorId = data.removeFirst()
        self.hardwareType = data.removeFirst()
        self.hardwareSubtype = data.removeFirst()
        self.hardwareVersionMajor = data.removeFirst()
        self.hardwareVersionMinor = data.removeFirst()
        self.hardwareStorageSize = data.removeFirst()
        self.hardwareProtocol = data.removeFirst()

        self.softwareVendorId = data.removeFirst()
        self.softwareType = data.removeFirst()
        self.softwareSubtype = data.removeFirst()
        self.softwareVersionMajor = data.removeFirst()
        self.softwareVersionMinor = data.removeFirst()
        self.softwareStorageSize = data.removeFirst()
        self.softwareProtocol = data.removeFirst()

        self.uid = data.prefix(self.uidBytes).map({ $0 })
        data.removeFirst(self.uidBytes)

        self.batchNumber = data.prefix(upTo: self.batchNumberBytes).map({ $0 })
        data.removeFirst(self.batchNumberBytes)

        self.productionYear = data.removeFirst()
        self.productionWeek = data.removeFirst()
    }
}
