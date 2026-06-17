//
//  ColorModel.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 17/06/26.
//

import SwiftUI
import SwiftData

@Model
final class Item{
    var id: UUID = UUID()
    var name: String
    var savedColor: Int = 0
    
    init(name: String, savedColor: Int) {
        self.name = name
        self.savedColor = savedColor
    }
    
}
