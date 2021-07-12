//
//  MatchView.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 11/07/21.
//

import UIKit

class MatchView: UIView {

    let itsAMatchImageView: UIImageView = {
        let iv: UIImageView = .init(image: #imageLiteral(resourceName: "itsamatch"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()

    let descriptionLabel: UILabel = {
        let label: UILabel = .init()
        label.text = "You and x have liked\neach other"
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        return label
    }()

    let currentUserImageView: UIImageView = {
        let iv: UIImageView = .init(image: #imageLiteral(resourceName: "kelly1"))
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()

    let cardUserImageView: UIImageView = {
        let iv: UIImageView = .init(image: #imageLiteral(resourceName: "jane1"))
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()

    let sendMessageButton: SendMessageButton = {
        let button: SendMessageButton = .init(type: .system)
        button.setTitle("SEND MESSAGE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    let keepSwipingButton: KeepSwipingButton = {
        let button: KeepSwipingButton = .init(type: .system)
        button.setTitle("Keep Swiping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    let visualEffectView: UIVisualEffectView = .init(effect: UIBlurEffect.init(style: .dark))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurView()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupBlurView() {
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleDismiss)))
        addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.visualEffectView.alpha = 1
        } completion: { (_) in

        }

    }

    func setupLayout() {
        addSubview(currentUserImageView)
        addSubview(cardUserImageView)
        addSubview(itsAMatchImageView)
        addSubview(descriptionLabel)
        addSubview(sendMessageButton)
        addSubview(keepSwipingButton)
        currentUserImageView.layer.cornerRadius = 140 / 2
        currentUserImageView.snp.makeConstraints {
            $0.trailing.equalTo(self.snp.centerX).offset(-16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(140)
            $0.width.equalTo(140)
        }

        cardUserImageView.layer.cornerRadius = 140 / 2
        cardUserImageView.snp.makeConstraints {
            $0.leading.equalTo(self.snp.centerX).offset(16)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(140)
            $0.width.equalTo(140)
        }

        itsAMatchImageView.snp.makeConstraints {
            $0.bottom.equalTo(descriptionLabel.snp.top).offset(-16)
            $0.height.equalTo(80)
            $0.width.equalTo(300)
            $0.centerX.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalTo(currentUserImageView.snp.top).offset(-32)
            $0.height.equalTo(50)
        }

        sendMessageButton.snp.makeConstraints {
            $0.top.equalTo(currentUserImageView.snp.bottom).offset(32)
            $0.trailing.equalToSuperview().inset(48)
            $0.leading.equalToSuperview().inset(48)
            $0.height.equalTo(60)
        }

        keepSwipingButton.snp.makeConstraints {
            $0.top.equalTo(sendMessageButton.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().inset(48)
            $0.leading.equalToSuperview().inset(48)
            $0.height.equalTo(60)
        }
    }

    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.alpha = 0
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }

}
