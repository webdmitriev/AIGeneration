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
            Spacer()

            Text("SettingsView")
                .foregroundStyle(.appWhite)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 16)
        .background(.appBg)
        .navigationBarHidden(true)
    }
}
