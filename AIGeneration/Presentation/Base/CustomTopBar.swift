//
//  CustomTopBar.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 25.06.2025.
//

import SwiftUI

struct CustomTopBar: View {
    let title: String
    var darkMode: Bool = false
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .modifier(ScreenTitle())
                .foregroundColor(.appWhite)
            
            Spacer()
            
            Button(action: action) {
                if !darkMode {
                    HStack(spacing: 6) {
                        Image("icon-stars-button")
                            .resizable()
                            .frame(maxWidth: 14, maxHeight: 14)
                            .scaledToFit()
                        
                        Text("PREMIUM")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.appWhite)
                    }
                } else {
                    Text("Settings")
                        .urbanist(.montserratMedium, 16)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .foregroundStyle(.appWhite)
                        .background(.appWhite.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                }
            }
            .padding(.horizontal, !darkMode ? 16 : 0)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        ),
                        lineWidth: !darkMode ? 3 : 0
                    )
            )
        }
        .padding(.horizontal, 16)
    }
}
