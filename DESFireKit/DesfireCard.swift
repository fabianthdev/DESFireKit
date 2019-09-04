//
//  DesfireCard.swift
//  DESFireKit
//
//  Created by Fabian Thies on 01.09.19.
//  Copyright © 2019 Fabian Thies. All rights reserved.
//

import Foundation
import CoreNFC

public class DesfireCard {
    
    // MARK: - Command
    enum Command: UInt8 {
        case getManufaturingData = 0x60
        case getApplicationDirectory = 0x6A
        case getAdditionalFrame = 0xAF
        case selectApplication = 0x5A
        case readData = 0xBD
        case readRecord = 0xBB
        case readValue = 0x6C
        case getFiles = 0x6F
        case getFileSettings = 0xF5
        
        var data: Data {
            return Data(repeating: self.rawValue, count: 1)
        }
    }
    
    // MARK: - StatusCode
    enum StatusCode: UInt8 {
        case operationOk = 0x00
        case permissionDenied = 0x9D
        case additionalFrame = 0xAF
        
        var data: Data {
            return Data(repeating: self.rawValue, count: 1)
        }
    }
    
    
    // MARK: - Parameters
    private var tag: NFCMiFareTag
    
    
    // MARK: - Lifecycle
    public init(tag: NFCMiFareTag) {
        self.tag = tag
    }
    
    
    // MARK: - Actions
    // MARK: General Information
    public func getManufacturingData(completion: @escaping (CardResponse<Data>) -> Void) {
        
        guard let command = self.apduCommand(for: .getManufaturingData) else {
            completion(.failure(error: DesfireCardError.invalidCommand))
            return
        }
        
        self.sendCommand(command, completion: completion)
    }
    
    // MARK: Apps
    public func getAppList(completion: @escaping (CardResponse<[Int]>) -> Void) {
        
        guard let command = self.apduCommand(for: .getApplicationDirectory) else {
            completion(.failure(error: DesfireCardError.invalidCommand))
            return
        }
        
        self.sendCommand(command) { (response) in
            
            switch response {
            case let .success(value, sw1, sw2):
                var value = value
                var appIds: [Int] = []
                for var i in 0..<value.count {
                    appIds.append(value.prefix(upTo: 3).withUnsafeBytes({ $0.load(as: Int.self) }))
                    value.removeFirst(3)
                    i += 3
                }
                completion(.success(value: appIds, sw1: sw1, sw2: sw2))
                
            case let .failure(error):
                completion(.failure(error: error))
            }
        }
    }
    
    public func selectApp(_ appId: UInt, completion: @escaping (CardResponse<Data>) -> Void) {
        
        var parameters = [UInt8]()
        parameters.append(UInt8((appId & 0xFF0000) >> 16))
        parameters.append(UInt8((appId & 0xFF00) >> 8))
        parameters.append(UInt8(appId & 0xFF))
        
        guard let command = self.apduCommand(for: .selectApplication, parameters: parameters) else {
            completion(.failure(error: DesfireCardError.invalidCommand))
            return
        }
        
        self.sendCommand(command, completion: completion)
    }
    
    // MARK: Files
    public func getFileList(completion: @escaping (CardResponse<[UInt8]>) -> Void) {
        
        guard let command = self.apduCommand(for: .getFiles) else {
            completion(.failure(error: DesfireCardError.invalidCommand))
            return
        }
        
        self.sendCommand(command) { (response) in
            
            switch response {
            case let .success(value, sw1, sw2):
                let fileIds = value.map({ $0 as UInt8 })
                completion(.success(value: fileIds, sw1: sw1, sw2: sw2))
                
            case let .failure(error: error):
                completion(.failure(error: error))
            }
        }
    }
    
    public func getFileSettings<T: DesfireFileSettings>(for fileId: UInt8, completion: @escaping (CardResponse<T>) -> Void) {
        
        guard let command = self.apduCommand(for: .getFileSettings, parameters: [fileId]) else {
            completion(.failure(error: DesfireCardError.invalidCommand))
            return
        }
        
        self.sendCommand(command) { (response) in
            
            switch response {
            case let .success(data, sw1, sw2):
                guard let fileSettings = DesfireFileSettings.create(from: data) as? T else {
                    completion(.failure(error: DesfireCardError.invalidResponse))
                    return
                }
                completion(.success(value: fileSettings, sw1: sw1, sw2: sw2))
            case let .failure(error):
                completion(.failure(error: error))
            }
        }
    }
    
    // MARK: Read Data
    public func readFile(from fileId: UInt8, completion: @escaping (CardResponse<Data>) -> Void) {
        
        guard let command = self.apduCommand(for: .readData, parameters: [fileId, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) else {
            completion(.failure(error: DesfireCardError.invalidCommand))
            return
        }
        
        self.sendCommand(command, completion: completion)
    }
    
    public func readRecord(from fileId: UInt8, completion: @escaping (CardResponse<Data>) -> Void) {
        
        guard let command = self.apduCommand(for: .readData, parameters: [fileId, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]) else {
            completion(.failure(error: DesfireCardError.invalidCommand))
            return
        }
        
        self.sendCommand(command, completion: completion)
    }
    
    public func readValue(from fileId: UInt8, completion: @escaping (CardResponse<Int>) -> Void) {
        
        guard let command = self.apduCommand(for: .readValue, parameters: [fileId]) else {
            completion(.failure(error: DesfireCardError.invalidCommand))
            return
        }
        
        self.sendCommand(command) { (response) in
            switch response {
            case let .success(data, sw1, sw2):
                let value = Int(littleEndian: data.withUnsafeBytes({ $0.load(as: Int.self) }))
                completion(.success(value: value, sw1: sw1, sw2: sw2))
            case let .failure(error):
                completion(.failure(error: error))
            }
        }
    }
    
    
    // MARK: - Helper
    private func apduCommand(for command: Command, parameters: [UInt8]? = nil) -> NFCISO7816APDU? {
        
        var bytes = [UInt8]()
        bytes.append(0x90)                          // Instruction Set
        bytes.append(command.rawValue)              // Command
        bytes.append(0x00)                          // Parameter 1, null byte because it is encoded later
        bytes.append(0x00)                          // Parameter 2, null byte because it is encoded later
        if let parameters = parameters {
            bytes.append(UInt8(parameters.count))   // Parameter count to let the receiver know, how many parameters are coming
            bytes.append(contentsOf: parameters)    // The actual parameters
        }
        bytes.append(0x00)                          // Expexted response length, set to 0 to accept any length
        
        return NFCISO7816APDU(data: Data(bytes))
    }
    
    private func sendCommand(_ command: NFCISO7816APDU, completion: @escaping (CardResponse<Data>) -> Void) {
        
        self.tag.sendMiFareISO7816Command(command) { (data, sw1, sw2, error) in
            
            if let error = error {
                completion(.failure(error: error))
            } else {
                
                guard sw1 == 0x91 else {
                    completion(.failure(error: DesfireCardError.invalidResponse))
                    return
                }
                
                switch StatusCode(rawValue: sw2) {
                case .operationOk:
                    completion(.success(value: data, sw1: sw1, sw2: sw2))
                    
                case .permissionDenied:
                    completion(.failure(error: DesfireCardError.permissionDenied))
                    
                case .additionalFrame:
                    guard let additionalCommand = self.apduCommand(for: .getAdditionalFrame) else {
                        completion(.failure(error: DesfireCardError.invalidCommand))
                        return
                    }
                    self.sendCommand(additionalCommand) { (response) in
                        
                        switch response {
                        case let .success(value, sw1, sw2):
                            completion(.success(value: data + value, sw1: sw1, sw2: sw2))
                        case let .failure(error):
                            completion(.failure(error: error))
                        }
                    }
                    
                default:
                    completion(.failure(error: DesfireCardError.unknownError))
                }
            }
        }
    }
}
