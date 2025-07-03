//
//  HistoryView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 28.06.2025.
//

import SwiftUI

struct HistoryView: View {
    @ObservedObject var historyStore: HistoryStore
    
    var body: some View {
        NavigationView {
            List {
                ForEach(historyStore.images.indices, id: \.self) { index in
                    ZStack {
                        Image(uiImage: historyStore.images[index])
                            .resizable()
                            .scaledToFill()
                            .frame(height: 360)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .listRowSeparator(.hidden)
                        
                        NavigationLink(destination:HistoryDetailView(image: historyStore.images[index])) {
                            EmptyView()
                        }
                    }
                }
                .onDelete(perform: delete)
            }
            .listStyle(.plain)
            .navigationTitle("History")
            .padding(.bottom, 60)
            .toolbar {
                EditButton()
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            historyStore.deleteImage(at: index)
        }
    }
}
