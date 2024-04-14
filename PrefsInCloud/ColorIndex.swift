//
//  ColorIndex.swift
//  PrefsInCloud
//
//  Created by Philipp on 14.04.2024.
//

import SwiftUI

enum ColorIndex: Int, CaseIterable {
    case white = 0, red, green, yellow

    var name: LocalizedStringKey {
        switch self {
        case .white:
            "White"
        case .red:
            "Red"
        case .green:
            "Green"
        case .yellow:
            "Yellow"
        }
    }

    var color: Color {
        switch self {
        case .white:
                .white
        case .red:
                .red
        case .green:
                .green
        case .yellow:
                .yellow
        }
    }
}
