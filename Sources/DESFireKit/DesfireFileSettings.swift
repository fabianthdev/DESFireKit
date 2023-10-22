//
//  DesfireFileSettings.swift
//  DESFireKit
//
//  Created by Fabian Thies on 01.09.19.
//  Copyright © 2019 Fabian Thies. All rights reserved.
//

import Foundation

public class DesfireFileSettings {
    
    public enum FileType: UInt8 {
        case standard = 0x00
        case backup = 0x01
        case value = 0x02
        case linearRecord = 0x03
        case cyclicRecord = 0x04
    }
    
    public var fileType: FileType
    public var commSetting: UInt8
    public var accessRights: [UInt8]
    
    public static func create(from data: Data) -> DesfireFileSettings? {
        guard let fileTypeValue = data.first, let fileType = FileType(rawValue: fileTypeValue) else {
            return nil
        }
        
        var dataCopy = data
        
        switch fileType {
        case .standard, .backup:
            return StandardDesfireFileSettings(data: &dataCopy, fileType: fileType)
        case .value:
            return ValueDesfireFileSettings(data: &dataCopy, fileType: fileType)
        default:
            return nil
        }
    }
    
    public init?(data: inout Data, fileType: FileType) {
        
        self.fileType = fileType
        data.removeFirst()
        
        guard let commSetting = data.first else {
            return nil
        }
        self.commSetting = commSetting
        data.removeFirst()
        
        self.accessRights = data.prefix(2).map({ $0 })
        data.removeFirst(2)
    }
}

public class StandardDesfireFileSettings: DesfireFileSettings {
    
    public var fileSize: Int
    
    override init?(data: inout Data, fileType: FileType) {
        
        self.fileSize = 0
        super.init(data: &data, fileType: fileType)
        
        let buffer = data.prefix(upTo: 3)
        data.removeFirst(3)
        self.fileSize = Int(littleEndian: buffer.withUnsafeBytes({ $0.load(as: Int.self) }))
    }
}

public class RecordDesfireFileSettings: DesfireFileSettings {
    
    public var recordSize: Int
    public var maxRecords: Int
    public var currentRecords: Int
    
    public override init?(data: inout Data, fileType: FileType) {
        
        self.recordSize = 0
        self.maxRecords = 0
        self.currentRecords = 0
        super.init(data: &data, fileType: fileType)
        
        var buffer = data.prefix(upTo: 3)
        data.removeFirst(3)
        self.recordSize = Int(littleEndian: buffer.withUnsafeBytes({ $0.load(as: Int.self) }))
        
        buffer = data.prefix(upTo: 3)
        data.removeFirst(3)
        self.maxRecords = Int(littleEndian: buffer.withUnsafeBytes({ $0.load(as: Int.self) }))
        
        buffer = data.prefix(upTo: 3)
        data.removeFirst(3)
        self.currentRecords = Int(littleEndian: buffer.withUnsafeBytes({ $0.load(as: Int.self) }))
    }
}

public class ValueDesfireFileSettings: DesfireFileSettings {
    
    public var lowerLimit: Int
    public var upperLimit: Int
    public var value: Int
    public var limitedCreditEnabled: UInt8?
    
    override init?(data: inout Data, fileType: FileType) {
        
        self.lowerLimit = -1
        self.upperLimit = -1
        self.value = -1
        super.init(data: &data, fileType: fileType)
        
        var buffer = data.prefix(4)
        data.removeFirst(4)
        let lowerLimit = UInt32(littleEndian: buffer.withUnsafeBytes({ $0.load(as: UInt32.self) }))
        self.lowerLimit = Int(lowerLimit)
        
        buffer = data.prefix(4)
        data.removeFirst(4)
        let upperLimit = UInt32(littleEndian: buffer.withUnsafeBytes({ $0.load(as: UInt32.self) }))
        self.upperLimit = Int(upperLimit)
        
        buffer = data.prefix(4)
        data.removeFirst(4)
        let value = UInt32(littleEndian: buffer.withUnsafeBytes({ $0.load(as: UInt32.self) }))
        self.value = Int(value)
        
        self.limitedCreditEnabled = data.first
    }
}
