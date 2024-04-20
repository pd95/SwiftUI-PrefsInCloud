//
//  ContentView.swift
//  PrefsInCloud
//
//  Created by Philipp on 14.04.2024.
//

import SwiftUI

struct ContentView: View {
    @AppStorage(gBackgroundColorKey) var chosenColorValue: ColorIndex = .white
    var body: some View {
        VStack {
            Picker("Background color", selection: $chosenColorValue) {
                ForEach(ColorIndex.allCases, id: \.rawValue) { color in
                    Text(color.name)
                        .tag(color)
                }
            }
            .pickerStyle(.inline)
            .foregroundStyle(.black)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(chosenColorValue.color)
        #if os(macOS)
        .frame(minWidth: 100, minHeight: 100)
        #else
        #endif
    }
}

#Preview {
    ContentView()
}
