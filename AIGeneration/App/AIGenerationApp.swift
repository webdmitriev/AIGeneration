//
//  AIGenerationApp.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

@main
struct AIGenerationApp: App {
    let appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            CustomTabBar()
                .environmentObject(appState)
        }
    }
}
