//
//  Item.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
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
