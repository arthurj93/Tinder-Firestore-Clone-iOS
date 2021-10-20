//
//  MessagesNavBar.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 21/09/21.
//

import LBTATools

class MessageNavBar: UIView {
    let userProfileImageView: CircularImageView = .init(width: 44, image: #imageLiteral(resourceName: "kelly1"))
    let nameLabel: UILabel = .init(text: "UserName", font: .systemFont(ofSize: 16))
    let backButton: UIButton = .init(image: #imageLiteral(resourceName: "back"), tintColor: #colorLiteral(red: 0.9860271811, green: 0.3476872146, blue: 0.4476813674, alpha: 1))
    let flagButton: UIButton = .init(image: #imageLiteral(resourceName: "flag"), tintColor: #colorLiteral(red: 0.9860271811, green: 0.3476872146, blue: 0.4476813674, alpha: 1))
    fileprivate let match: Match

    init(match: Match) {
        self.match = match
        nameLabel.text = match.name
        userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl))
        super.init(frame: .zero)
        backgroundColor = .white
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.2))

        let middleStack = hstack(
            stack(
                userProfileImageView,
                nameLabel,
                spacing: 8,
                alignment: .center),
            alignment: .center
        )

        hstack(backButton.withWidth(50),
               middleStack,
               flagButton).withMargins(.init(top: 0, left: 12, bottom: 0, right: 12))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
