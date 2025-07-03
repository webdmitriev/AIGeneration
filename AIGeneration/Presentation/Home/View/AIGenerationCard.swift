//
//  AIGenerationCard.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 03.07.2025.
//

import SwiftUI

struct AIGenerationCard: View {

    let item: AIGenerationItemStruct
    var prompt: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack(alignment: .bottomLeading) {
                
                BgGradient(height: 98, opacity: 0.8)
                
                Text(item.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.system(size: 16, weight: .medium))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
            }
        }
        .frame(height: 216)
        .background(
            Image(item.image)
                .resizable()
                .scaledToFill()
                .clipped()
        )
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .clipped()
    }
}
