//
//  AgeRangeCell.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 06/07/21.
//

import UIKit

class AgeRangeCell: UITableViewCell {

    let minSlider: UISlider = {
        let slider: UISlider = .init()
        slider.minimumValue = 18
        slider.maximumValue = 100
        return slider
    }()

    let maxSlider: UISlider = {
        let slider: UISlider = .init()
        slider.minimumValue = 18
        slider.maximumValue = 100
        return slider
    }()

    let minLabel: AgeRangeLabel = {
        let label: AgeRangeLabel = .init()
        label.text = "Min 88"
        return label
    }()

    let maxLabel: AgeRangeLabel = {
        let label: AgeRangeLabel = .init()
        label.text = "Max 88"
        return label
    }()

    class AgeRangeLabel: UILabel {
        override var intrinsicContentSize: CGSize {
            return .init(width: 80, height: 0)
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = true
        let padding: CGFloat = 16
        let overallStackView: UIStackView = .init(arrangedSubviews: [
            UIStackView(arrangedSubviews: [minLabel, minSlider]),
            UIStackView(arrangedSubviews: [maxLabel, maxSlider])
        ])
        overallStackView.axis = .vertical
        overallStackView.spacing = padding
        addSubview(overallStackView)
        overallStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(padding)
            $0.leading.equalToSuperview().inset(padding)
            $0.bottom.equalToSuperview().inset(padding)
            $0.trailing.equalToSuperview().inset(padding)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
