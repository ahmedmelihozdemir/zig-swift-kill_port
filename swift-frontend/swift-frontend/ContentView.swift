//
//  ContentView.swift
//  swift-frontend
//
//  Created by Melih Özdemir on 31.08.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bolt.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.blue)
                .font(.system(size: 48))
            
            Text("Port Kill Monitor")
                .font(.title)
                .fontWeight(.bold)
            
            Text("This app runs in the menu bar")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Look for the ⚡ icon in your menu bar")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
}

#Preview {
    ContentView()
}
