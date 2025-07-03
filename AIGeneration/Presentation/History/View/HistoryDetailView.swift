//
//  HistoryDetailView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 03.07.2025.
//

import SwiftUI

struct HistoryDetailView: View {
    let item: HistoryItem

    var body: some View {
        ScrollView {
            if let uiImage = UIImage(data: item.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
            }
            if let prompt = item.prompt {
                Text(prompt)
                    .padding()
            }
            Text(item.date.formatted())
                .foregroundColor(.secondary)
                .padding()
        }
        .navigationTitle("Detail")
    }
}
