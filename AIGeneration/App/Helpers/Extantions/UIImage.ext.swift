//
//  UIImage.ext.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 01.07.2025.
//

import SwiftUI

extension UIImage {
    func resized(to size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
