//
//  UIView.ext.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 25.06.2025.
//

import SwiftUI

extension UIView {
    func enclosingScrollView() -> UIScrollView? {
        var responder: UIResponder? = self
        while responder != nil {
            if let scrollView = responder as? UIScrollView {
                return scrollView
            }
            responder = responder?.next
        }
        return nil
    }
}
