//
//  DesfireCardResponse.swift
//  DESFireKit
//
//  Created by Fabian Thies on 01.09.19.
//  Copyright © 2019 Fabian Thies. All rights reserved.
//

import Foundation

public enum CardResponse<T> {
    case success(value: T, sw1: UInt8, sw2: UInt8)
    case failure(error: Error)
}
