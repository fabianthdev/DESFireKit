//
//  DesfireCardError.swift
//  DESFireKit
//
//  Created by Fabian Thies on 01.09.19.
//  Copyright © 2019 Fabian Thies. All rights reserved.
//

import Foundation

public enum DesfireCardError: LocalizedError {
    case invalidCommand
    case invalidResponse
    case permissionDenied
    case unknownError

    public var errorDescription: String? {
        switch self {
        case .invalidCommand:
            return "The command that should be sent was invalid."

        case .invalidResponse:
            return "The card's response was invalid."

        case .permissionDenied:
            return "Permission denied."

        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
