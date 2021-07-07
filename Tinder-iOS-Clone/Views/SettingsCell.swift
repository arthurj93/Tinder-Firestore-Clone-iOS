//
//  SettingsCell.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 05/07/21.
//

import UIKit

class SettingsCell: UITableViewCell {

    class SettingsTextField: UITextField {

        override func textRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 24, dy: 0)
        }

        override func editingRect(forBounds bounds: CGRect) -> CGRect {
            return bounds.insetBy(dx: 24, dy: 0)
        }

        override var intrinsicContentSize: CGSize {
            return .init(width: 0, height: 44)
        }
    }
    static let cellId = "SettingsCell"

    let textField: SettingsTextField = {
        let tf: SettingsTextField = .init()
        tf.placeholder = "Enter name"
        return tf
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        addSubview(textField)
        textField.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
