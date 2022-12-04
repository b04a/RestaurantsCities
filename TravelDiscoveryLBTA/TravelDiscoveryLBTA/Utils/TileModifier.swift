//
//  TileModifier.swift
//  TravelDiscoveryLBTA
//
//  Created by Brian Voong on 10/14/20.
//

import SwiftUI

extension View {
    func asTile() -> some View {
        modifier(TileModifier())
    }
}

struct TileModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(Color("titleBackground"))
            .cornerRadius(5)
            .shadow(color: .init(.sRGB, white: 0.8, opacity: colorScheme == .light ? 1 : 0), radius: 4, x: 0.0, y: 2)
    }
    
}
