//
//  Item.swift
//  Boxing Companion
//
//  Created by Jordan Lyne on 29/04/2026.
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
