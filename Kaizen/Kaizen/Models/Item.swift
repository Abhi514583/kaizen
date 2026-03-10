//
//  Item.swift
//  Kaizen
//
//  Created by Abhishek Thakur on 2026-03-10.
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
