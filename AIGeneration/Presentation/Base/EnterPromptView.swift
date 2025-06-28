//
//  EnterPromptView.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import SwiftUI

struct EnterPromptView: View {
    @State var yourTextVariable: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Enter Prompt")
                .urbanist(.montserratBold, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.appWhite)
            
            MultilineTextField(
                placeholder: "Type what should be shown in the sketch",
                text: $yourTextVariable
            )
        }
        .padding(.horizontal, 16)
    }
}

struct MultilineTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.appWhite.opacity(0.4))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
            }
            
            TextEditor(text: $text)
                .foregroundColor(.white)
                .scrollContentBackground(.hidden)
                .padding(.bottom, 40)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button {
                        print("Surprise me!")
                    } label: {
                        HStack(spacing: 4) {
                            Image("icon-starts-white")
                                .resizable()
                                .frame(width: 16, height: 16)
                                .scaledToFit()
                            
                            Text("Surprise me!")
                                .urbanist(.montserratMedium, 14)
                                .foregroundStyle(.appWhite)
                        }
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.appBg)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, minHeight: 158, maxHeight: 192)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color.appWhite.opacity(0.05))
        .cornerRadius(12)
    }
}
