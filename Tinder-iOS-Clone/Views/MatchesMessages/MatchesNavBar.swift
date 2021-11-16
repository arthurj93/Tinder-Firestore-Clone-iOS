//
//  MatchesNavBar.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 07/09/21.
//

import LBTATools

class MatchesNavBar: UIView {

    let backButton: UIButton = .init(image: #imageLiteral(resourceName: "app_icon"), tintColor: .lightGray)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        let navBar: UIView = .init()
        navBar.backgroundColor = .white
        let iconImageView: UIImageView = .init(image: #imageLiteral(resourceName: "top_right_messages").withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        iconImageView.tintColor = #colorLiteral(red: 0.9860271811, green: 0.3476872146, blue: 0.4476813674, alpha: 1)
        let messagesLabel: UILabel = .init(text: "Messages", font: .boldSystemFont(ofSize: 20), textColor: #colorLiteral(red: 0.9860271811, green: 0.3476872146, blue: 0.4476813674, alpha: 1), textAlignment: .center)
        let feedLabel: UILabel = .init(text: "Feed", font: .boldSystemFont(ofSize: 20), textColor: .gray, textAlignment: .center)
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.2))

        stack(iconImageView.withHeight(44),
              navBar.hstack(messagesLabel, feedLabel,
                            distribution: .fillEqually))

        addSubview(backButton)
        backButton.snp.makeConstraints {
            $0.top.equalTo(snp.topMargin)
            $0.leading.equalToSuperview().offset(12)
            $0.height.equalTo(34)
            $0.width.equalTo(34)
        }

        iconImageView.snp.makeConstraints {
            $0.top.equalTo(snp.topMargin)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
