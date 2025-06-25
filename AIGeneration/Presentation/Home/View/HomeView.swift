//
//  HomeView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 24.06.2025.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedCategory: String?
    let items = AIGenerationStruct.mockData()
    
    var categories: [String] {
        Array(Set(items.flatMap { $0.category } )).sorted()
    }
    
    var filteredItems: [AIGenerationItemStruct] {
        if let selectedCategory = selectedCategory {
            return items.filter { $0.category.contains(selectedCategory) }
        } else {
            return items
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        CategoryButton(
                            title: category,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation {
                                selectedCategory = (selectedCategory == category) ? nil : category
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 216, maximum: 216),
                                 spacing: 6, alignment: .top),
                        GridItem(.adaptive(minimum: 216, maximum: 216),
                                 spacing: 6, alignment: .top)
                    ],
                    spacing: 6,
                ) {
                    ForEach(filteredItems, id: \.id) { item in
                        AIGenerationCard(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("AI Generation")
        .background(.appBg)
    }
}

// MARK: CategoryButton
struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .modifier(CategoryButtonModifier())
                .foregroundColor(isSelected ? .white : .primary)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.appPurpule : Color.gray.opacity(0.2))
                )
        }
    }
}

// MARK: AIGenerationCard
struct AIGenerationCard: View {
    let item: AIGenerationItemStruct
    
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

#Preview {
    HomeView()
}
