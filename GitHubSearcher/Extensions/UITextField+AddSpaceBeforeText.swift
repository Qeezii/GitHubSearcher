//
//  UITextField+AddSpaceBeforeText.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 09.05.2023.
//

import UIKit

extension UITextField {
    /// Creates a left indentation for the text field by adding a UIView object as a sub-representation to the left of the text field. This improves the appearance of a group of text fields.
    func addSpaceBeforeText() {
        let leftView = UIView(frame: CGRect(x: 10, y: 0, width: 7, height: bounds.height))
        leftView.backgroundColor = .clear
        self.leftView = leftView
        self.leftViewMode = .always
        self.contentVerticalAlignment = .center
    }
}
