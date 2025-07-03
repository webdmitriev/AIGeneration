//
//  SettingsView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("SettingsView")
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(.appBg)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.appWhite)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
