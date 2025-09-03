//
//  Item.swift
//  HabitQuest
//
//  Created by Daniel Stevens on 6/27/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
