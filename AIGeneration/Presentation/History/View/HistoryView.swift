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
                    Image(uiImage: historyStore.images[index])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(8)
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("History")
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
