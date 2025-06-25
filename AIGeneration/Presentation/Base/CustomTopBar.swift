//
//  CustomTopBar.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 25.06.2025.
//

import SwiftUI

struct CustomTopBar: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .modifier(ScreenTitle())
                .foregroundColor(.appWhite)
            
            Spacer()
            
            Button(action: action) {
                HStack(spacing: 6) {
                    Image("icon-stars-button")
                        .resizable()
                        .frame(maxWidth: 14, maxHeight: 14)
                        .scaledToFit()
                    
                    Text("PREMIUM")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.appWhite)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topTrailing,
                            endPoint: .bottomLeading
                        ),
                        lineWidth: 3
                    )
            )
        }
        .padding(.horizontal, 16)
    }
}
