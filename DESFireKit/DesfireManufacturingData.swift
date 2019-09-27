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

    public let hardwareVendorId: UInt8
    public let hardwareType: UInt8
    public let hardwareSubtype: UInt8
    public let hardwareVersionMajor: UInt8
    public let hardwareVersionMinor: UInt8
    public let hardwareStorageSize: UInt8
    public let hardwareProtocol: UInt8

    public let softwareVendorId: UInt8
    public let softwareType: UInt8
    public let softwareSubtype: UInt8
    public let softwareVersionMajor: UInt8
    public let softwareVersionMinor: UInt8
    public let softwareStorageSize: UInt8
    public let softwareProtocol: UInt8

    public let uid: [UInt8]
    public let batchNumber: [UInt8]
    public let productionWeek: UInt8
    public let productionYear: UInt8


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
