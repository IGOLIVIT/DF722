//
//  Theme.swift
//  VaultRise
//
//  Created by Cursor AI
//

import SwiftUI

struct AppTheme {
    // Color Palette
    static let primaryBackground = Color(hex: "#0A0E2F")
    static let accentGold = Color(hex: "#F7C948")
    static let accentRuby = Color(hex: "#D21F3C")
    
    // Gradients
    static let goldGradient = LinearGradient(
        colors: [Color(hex: "#F7C948"), Color(hex: "#FFD966")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let rubyGradient = LinearGradient(
        colors: [Color(hex: "#D21F3C"), Color(hex: "#E63950")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let cardGradient = LinearGradient(
        colors: [Color(hex: "#1A1F4F"), Color(hex: "#0F1237")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Spacing
    static let cornerRadius: CGFloat = 20
    static let cardPadding: CGFloat = 20
    static let spacing: CGFloat = 16
    
    // Shadows
    static let cardShadow = Color.black.opacity(0.3)
}

// Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


