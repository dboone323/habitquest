//
//  DataManagerError.swift
//  PlannerApp
//
//  Created by Daniel Stevens on 4/29/25.
//

// PlannerApp/Services/DataManagerError.swift
// (Optional but good practice: Define a common error type)
import Foundation

public enum DataManagerError: Error {
    case encodingFailed(Error?)
    case decodingFailed(Error?)
    case loadFailed(Error?)
    case saveFailed(Error?)
    case dataNotFound
}
