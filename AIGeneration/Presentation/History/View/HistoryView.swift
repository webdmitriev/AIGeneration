//
//  HistoryView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyStore: HistoryStore
    
    @State private var showSubscribeView: Bool = false
    
    private let widthScreen: CGFloat = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView {
            VStack {
                CustomTopBar(title: "AI Photo") {
                    showSubscribeView = true
                }
                .frame(height: 40)
                .clipped()
                
                List {
                    ForEach(historyStore.images.indices, id: \.self) { index in
                        ZStack {
                            Image(uiImage: historyStore.images[index])
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: widthScreen - 32)
                                .frame(height: 320)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .clipped()
                                .listRowSeparator(.hidden)
                            
                            NavigationLink(destination:HistoryDetailView(image: historyStore.images[index])) {
                                EmptyView()
                            }
                        }
                        .listRowBackground(Color.appBg)
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.plain)
            }
            .padding(.bottom, 60)
            .background(.appBg)
            .navigationBarHidden(true)
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            historyStore.deleteImage(at: index)
        }
    }
}

struct HistoryViewItem: View {
    var body: some View {
        /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Hello, world!@*/Text("Hello, world!")/*@END_MENU_TOKEN@*/
    }
}
