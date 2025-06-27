//
//  PhotoView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import SwiftUI

struct PhotoView: View {
    @State private var showSubscribeView: Bool = false
    @State private var withoutPhoto: Bool = true
    @State private var usePhoto: Bool = false
    
    private let widthScreen: CGFloat = UIScreen.main.bounds.width

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                CustomTopBar(title: "AI Photo") {
                    showSubscribeView = true
                }
                .frame(height: 40)
                .clipped()
                
                toogleBar
                
                EnterPromptView()
                
                Text("Photo Screen")
                
                Spacer()
            }
            .navigationDestination(isPresented: $showSubscribeView) {
                SubscribeView()
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 60)
            .background(.appBg)
            .navigationBarHidden(true)
        }
    }
    
    private var toogleBar: some View {
        HStack {
            Button {
                withoutPhoto = true
                usePhoto = false
            } label: {
                Text("Without Photo")
                    .frame(maxWidth: widthScreen / 2, maxHeight: 32, alignment: .center)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(withoutPhoto ? .appBlack : .appWhite)
                    .background(withoutPhoto ? .appWhite : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            Button {
                withoutPhoto = false
                usePhoto = true
            } label: {
                Text("Use Photo")
                    .frame(maxWidth: widthScreen / 2, maxHeight: 32, alignment: .center)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(usePhoto ? .appBlack : .appWhite)
                    .background(usePhoto ? .appWhite : .clear)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .frame(maxWidth: .infinity)
        .background(.appWhite.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .clipped()
    }
}

#Preview {
    let appState = AppState()
    return PhotoView()
        .environmentObject(appState)
}
