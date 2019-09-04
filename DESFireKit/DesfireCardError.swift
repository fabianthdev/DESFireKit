//
//  DesfireCardError.swift
//  DESFireKit
//
//  Created by Fabian Thies on 01.09.19.
//  Copyright © 2019 Fabian Thies. All rights reserved.
//

import Foundation

public enum DesfireCardError: Error {
    case invalidCommand
    case invalidResponse
    case permissionDenied
    case unknownError
}
