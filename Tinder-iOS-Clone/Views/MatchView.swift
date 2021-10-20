//
//  MatchView.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 11/07/21.
//

import UIKit
import FirebaseFirestore
class MatchView: UIView {

    var currentUser: User!

    var cardUID: String! {
        didSet {
            let query = Firestore.firestore().collection("users")
            query.document(cardUID).getDocument { (snapshot, err) in
                if let err = err {
                    print("Failed to fetch card user:", err)
                    return
                }
                guard let dictionary = snapshot?.data() else { return }
                let user: User = .init(dictionary: dictionary)
                guard let url = URL(string: user.imageUrl1 ?? "") else { return}
                self.cardUserImageView.sd_setImage(with: url)

                guard let currentUserImageUrl = URL(string: self.currentUser.imageUrl1 ?? "") else { return }

                self.currentUserImageView.sd_setImage(with: currentUserImageUrl) { (_, _, _, _) in
                    self.setupAnimations()
                }
                self.descriptionLabel.text = "You and \(user.name ?? "") have liked\neach other."
            }
        }
    }

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
        label.numberOfLines = 0
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
        iv.alpha = 0
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
//        setupAnimations()
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

    lazy var views = [
        itsAMatchImageView,
        descriptionLabel,
        currentUserImageView,
        cardUserImageView,
        sendMessageButton,
        keepSwipingButton
    ]

    func setupLayout() {
        views.forEach { (v) in
            addSubview(v)
            v.alpha = 0
        }

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

    func setupAnimations() {
        views.forEach({$0.alpha = 1})
        let angle = 30 * CGFloat.pi / 180
        currentUserImageView.transform = CGAffineTransform.init(rotationAngle: -angle).concatenating(.init(translationX: 200, y: 0))
        cardUserImageView.transform = CGAffineTransform.init(rotationAngle: angle).concatenating(.init(translationX: -200, y: 0))
        sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)

        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic) {

            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
                self.currentUserImageView.transform = CGAffineTransform.init(rotationAngle: -angle)
                self.cardUserImageView.transform = CGAffineTransform.init(rotationAngle: angle)
            }

            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.currentUserImageView.transform = .identity
                self.cardUserImageView.transform = .identity
//                self.sendMessageButton.transform = .identity
//                self.keepSwipingButton.transform = .identity
            }

        } completion: { (_) in

        }

        UIView.animate(withDuration: 0.6, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut) {
            self.sendMessageButton.transform = .identity
            self.keepSwipingButton.transform = .identity
        } completion: { _ in

        }

//        UIView.animate(withDuration: 0.7) {
//            self.currentUserImageView.transform = .identity
//            self.currentUserImageView.transform = .identity
//        } completion: { (_) in
//
//        }

    }

    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.alpha = 0
        } completion: { (_) in
            self.removeFromSuperview()
        }
    }

}
