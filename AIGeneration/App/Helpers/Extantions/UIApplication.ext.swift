//
//  UIApplication.ext.swift
//  AIGeneration
//
//  Created by Олег Дмитриев on 27.06.2025.
//

import UIKit

extension UIApplication {
    static var keyWindowSafeAreaTop: CGFloat {
        let topInset = UIApplication
            .shared
            .connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .safeAreaInsets.top ?? 0
        return topInset
    }
}
