//
//  SubscribeView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 26.06.2025.
//

import SwiftUI

struct SubscribeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel = SubscribeViewModel()
    
    @State private var isShowTerms: Bool = false
    @State private var isShowRestore: Bool = false
    @State private var isShowPolicy: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            topBar
            
            Spacer()
            
            BgGradient(height: 180, opacity: 1)
            
            premiumItemsSection
        }
        .background {
            Image("subscribe-01")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .background(.appBg)
        .onAppear {
            withAnimation {
                appState.isTabBarVisible = false
            }
        }
        .onDisappear {
            withAnimation(.easeInOut(duration: 0.2)) {
                appState.isTabBarVisible = true
            }
        }
        .sheet(isPresented: $isShowTerms) {
            PopupTermsView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowRestore) {
            PopupRestoreView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowPolicy) {
            PopupPolicyView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var topBar: some View {
        let topInset = UIApplication.keyWindowSafeAreaTop
        let topBarHeight: CGFloat = 44 + (topInset > 0 ? 20 : 0)

        return HStack {
            Spacer()
            Button {
                dismiss()
            } label: {
                Image("icon-close-white")
                    .resizable()
                    .frame(width: 23, height: 23)
                    .scaledToFit()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, topBarHeight)
    }
    
    private var premiumItemsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Text(viewModel.premiumItems.titleWhite)
                    .urbanist(.montserratBold, 26)
                    .foregroundStyle(.appWhite)
                
                Text(viewModel.premiumItems.titleGradient)
                    .urbanist(.montserratBold, 26)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
            }
            
            Text(viewModel.premiumItems.descr)
                .urbanist(.montserratMedium, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.appWhite)
            
            if !viewModel.premiumItems.items.isEmpty {
                ForEach(viewModel.premiumItems.items, id: \.id) { item in
                    PremiumItem(
                        item: item,
                        isActive: viewModel.selectedItemId == item.id
                    ) {
                        viewModel.selectedItemId = item.id
                    }
                }
                
                Button {
                    print("Subscribe")
                } label: {
                    Text("Subscribe")
                        .modifier(ButtonPurpuleModifier())
                }
            }
            
            HStack {
                Button {
                    isShowTerms.toggle()
                } label: {
                    Text("Terms of Use")
                        .font(.system(size: 12, weight: .regular))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.appWhite.opacity(0.4))
                }
                
                Spacer()
                
                Button {
                    isShowRestore.toggle()
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.appWhite.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                Button {
                    isShowPolicy.toggle()
                } label: {
                    Text("Privacy Policy")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(.appWhite.opacity(0.4))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 4)
        .padding(.horizontal, 16)
        .background(.appBg)
    }

}

struct PremiumItem: View {
    var item: PremiumVersionItemStruct
    var isActive: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .center, spacing: 20) {
                VStack {
                    Text(item.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 4)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.appWhite)

                    Text(item.descr)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.appWhite)
                }
                VStack {
                    Text(item.price)
                        .frame(maxWidth: 90, alignment: .leading)
                        .padding(.bottom, 4)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.appWhite)

                    Text(item.when)
                        .frame(maxWidth: 90, alignment: .leading)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.appWhite)
                }

                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.purple, .blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: isActive ? 23 : 0, height: isActive ? 23 : 0)
                    )
            }
            .padding()
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.appWhite.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [.purple, .blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isActive ? 2 : 0
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SubscribeView()
}
