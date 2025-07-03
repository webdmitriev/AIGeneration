//
//  TabBar.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var isTabBarVisible: Bool = true
}

struct TabItem {
    let icon: String
    let title: String
}

struct CustomTabBar: View {
    @EnvironmentObject var appState: AppState
    @StateObject var generator = ImageGenerator()
    @State private var selectedTab: Int = 0
    
    let tabs: [TabItem] = [
        TabItem(icon: "tab-main", title: "Main"),
        TabItem(icon: "tab-photo", title: "Photo"),
        TabItem(icon: "tab-history", title: "History"),
        TabItem(icon: "tab-settings", title: "Settings")
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            tabContentView
                .edgesIgnoringSafeArea(.all)

            if appState.isTabBarVisible {
                HStack {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        TabBarButton(
                            icon: tab.icon,
                            title: tab.title,
                            isActive: selectedTab == index
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = index
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 12)
                .background(Color.appBg)
                .frame(height: 110)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
                .transition(.move(edge: .bottom))
            }
        }
        .padding(0)
        .ignoresSafeArea(edges: .all)
    }
    
    @ViewBuilder
    private var tabContentView: some View {
        switch selectedTab {
        case 0:
            HomeView()
                .environmentObject(appState)
        case 1:
            PhotoView()
                .environmentObject(appState)
        case 2:
            HistoryView(selection: $selectedTab)
                .environmentObject(appState)
        case 3:
            SettingsView()
                .environmentObject(appState)
        default:
            EmptyView()
        }
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(isActive ? .appWhite : .appWhite.opacity(0.4))
                
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(isActive ? .appWhite : .appWhite.opacity(0.4))
            }
            .padding(.vertical, 8)
        }
    }
}

