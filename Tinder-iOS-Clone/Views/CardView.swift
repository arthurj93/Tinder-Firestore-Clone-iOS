//
//  CardView.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 13/04/21.
//

import UIKit

class CardView: UIView {

    var cardViewModel: CardViewModel? {
        didSet {
            guard let cardViewModel = cardViewModel else { return }
            imageView.image = UIImage(named: cardViewModel.imageName)
            informationLabel.attributedText = cardViewModel.attributeString
            informationLabel.textAlignment = cardViewModel.textAlignment
        }
    }
    private let imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
    private let gradientLayer: CAGradientLayer = .init()
    private let informationLabel = UILabel()
    let threshold: CGFloat = 100

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    func setupLayout() {
        layer.cornerRadius = 10
        clipsToBounds = true

        addSubview(imageView)
        imageView.contentMode = .scaleAspectFill
        imageView.snp.makeConstraints {
            $0.top.trailing.bottom.leading.equalToSuperview()
        }

        setupGradientLayer()

        addSubview(informationLabel)
        informationLabel.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview().inset(16)
        }
        informationLabel.text = "TEXT NAME TEST NAME AGE"
        informationLabel.textColor = .white
        informationLabel.font = .systemFont(ofSize: 34, weight: .heavy)
        informationLabel.numberOfLines = 0
        let panGesture: UIPanGestureRecognizer = .init(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
    }

    func setupGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.7, 1.1]
        layer.addSublayer(gradientLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.frame
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handleChanged(gesture)
        case .ended:
            handleEnded(gesture)
        default:
            break
        }
    }

    fileprivate func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = (gesture.translation(in: nil).x).magnitude > threshold
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut) {
            if shouldDismissCard {
//                self.frame = .init(x: 1000, y: 0, width: self.frame.width, height: self.frame.height)
                ///checkthis
                let offScreenTransform = self.transform.translatedBy(x: 1000 * translationDirection, y: 0)
                self.transform = offScreenTransform
            } else {
                self.transform = .identity
            }
        } completion: { (_) in

            self.transform = .identity
            if shouldDismissCard {
                self.removeFromSuperview()
            }
            ///x
//            self.frame = .init(x: 0, y: 0, width: self.superview!.frame.width, height: self.superview!.frame.height)
        }
    }

    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let degress: CGFloat = translation.x / 20
        let angle = degress * .pi / 180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
