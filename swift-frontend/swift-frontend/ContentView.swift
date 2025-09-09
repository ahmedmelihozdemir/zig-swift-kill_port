//
//  ContentView.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Design System
    
    private enum Constants {
        static let iconSize: CGFloat = 80
        static let iconFontSize: CGFloat = 32
        static let smallIconSize: CGFloat = 24
        static let minWindowWidth: CGFloat = 400
        static let minWindowHeight: CGFloat = 500
        static let contentPadding: CGFloat = 32
        static let verticalSpacing: CGFloat = 28
    }
    
    struct Colors {
        static let accent = Color(red: 0.27, green: 0.54, blue: 1.0)
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let background = Color(NSColor.windowBackgroundColor)
    }
    
    var body: some View {
        VStack(spacing: Constants.verticalSpacing) {
            // App icon with modern design
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Colors.accent, Colors.accent.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .shadow(color: Colors.accent.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "cpu.fill")
                    .font(.system(size: Constants.iconFontSize, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("Port Monitor")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Colors.textPrimary)
                
                Text("This app runs silently in your menu bar")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Colors.textSecondary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: 8) {
                    Text("Look for the")
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textSecondary)
                    
                    ZStack {
                        Circle()
                            .fill(Colors.accent.opacity(0.1))
                            .frame(width: Constants.smallIconSize, height: Constants.smallIconSize)
                        
                        Image(systemName: "cpu.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Colors.accent)
                    }
                    
                    Text("icon in your menu bar")
                        .font(.system(size: 14))
                        .foregroundColor(Colors.textSecondary)
                }
            }
            
            VStack(spacing: 16) {
                FeatureRow(
                    icon: "eye.fill",
                    title: "Monitor Ports",
                    description: "Track processes running on development ports"
                )
                
                FeatureRow(
                    icon: "xmark.circle.fill",
                    title: "Kill Processes",
                    description: "Terminate processes with a single click"
                )
                
                FeatureRow(
                    icon: "gear.circle.fill",
                    title: "Customizable",
                    description: "Configure monitored ports and preferences"
                )
            }
        }
        .padding(Constants.contentPadding)
        .frame(minWidth: Constants.minWindowWidth, minHeight: Constants.minWindowHeight)
        .background(Colors.background)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(ContentView.Colors.accent.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ContentView.Colors.accent)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(ContentView.Colors.textPrimary)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(ContentView.Colors.textSecondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    ContentView()
}
