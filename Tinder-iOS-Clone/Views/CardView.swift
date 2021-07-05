//
//  CardView.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 13/04/21.
//

import UIKit

class CardView: UIView {

    var cardViewModel: CardViewModel! {
        didSet {
//            guard let cardViewModel = cardViewModel else { return }
            let imageName = cardViewModel.imageNames.first ?? ""
            imageView.image = UIImage(named: imageName)
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment

            (0..<cardViewModel.imageNames.count).forEach { _ in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white

            setupImageIndexObserver()
        }
    }

    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] (index,image) in
            self?.imageView.image = image
            self?.barsStackView.arrangedSubviews.forEach { v in
                v.backgroundColor = self?.barDeselectedColor
            }
            self?.barsStackView.arrangedSubviews[index].backgroundColor = .white
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
        setupBarsStackView()
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
        let tapGesture: UITapGestureRecognizer = .init(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }

    var imageIndex = 0
    let barDeselectedColor: UIColor = .init(white: 0, alpha: 0.1)

    @objc func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
    }

    let barsStackView = UIStackView()
    func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.snp.makeConstraints {
            $0.topMargin.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
            $0.leading.equalTo(8)
            $0.height.equalTo(4)
        }
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
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
