//
//  CardView.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 13/04/21.
//

import UIKit
import SDWebImage

protocol CardViewDelegate: class {
    func presentInfoController(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
}

class CardView: UIView {

    //MARK:- Variables

    weak var delegate: CardViewDelegate?

    var nextCardView: CardView?

    var cardViewModel: CardViewModel! {
        didSet {

//            let imageName = cardViewModel.imageUrls.first ?? ""
//            if let url = URL(string: imageName) {
//                imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "photo_placeholder"), options: .continueInBackground)
//            }
            swipingPhotoController.cardViewModel = self.cardViewModel
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment

            (0..<cardViewModel.imageUrls.count).forEach { _ in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white

            setupImageIndexObserver()
        }
    }

    var imageIndex = 0
    let barDeselectedColor: UIColor = .init(white: 0, alpha: 0.1)
//    private let imageView = UIImageView(image:  #imageLiteral(resourceName: "photo_placeholder"))
    private let swipingPhotoController: SwipingPhotosController = .init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let gradientLayer: CAGradientLayer = .init()
    private let informationLabel = UILabel()
    let threshold: CGFloat = 100
    let barsStackView = UIStackView()
    let moreInfoButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setImage(#imageLiteral(resourceName: "info_icon"), for: .normal)
        button.addTarget(self, action: #selector(handleMoreInfo), for: .touchUpInside)
        return button
    }()

    //MARK:- Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        disableSwipingAbility()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupImageIndexObserver() {
        cardViewModel.imageIndexObserver = { [weak self] (index, imageUrl) in
            if let url = URL(string: imageUrl ?? "") {
//                self?.imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "photo_placeholder"), options: .continueInBackground)
            }
            self?.barsStackView.arrangedSubviews.forEach { v in
                v.backgroundColor = self?.barDeselectedColor
            }
            self?.barsStackView.arrangedSubviews[index].backgroundColor = .white
        }
    }

    func setupLayout() {
        let swipingPhotosView = swipingPhotoController.view!
        layer.cornerRadius = 10
        clipsToBounds = true

        addSubview(swipingPhotosView)
//        imageView.contentMode = .scaleAspectFill
        swipingPhotosView.snp.makeConstraints {
            $0.top.trailing.bottom.leading.equalToSuperview()
        }
//        setupBarsStackView()
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

        addSubview(moreInfoButton)
        moreInfoButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(44)
            $0.width.equalTo(44)
        }
    }

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

    func disableSwipingAbility() {
        swipingPhotoController.view.subviews.forEach { v in
            if let v = v as? UIScrollView {
                v.isScrollEnabled = false
            }
        }
    }

    //MARK:- Functions

    @objc func handleTap(gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
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

        if shouldDismissCard {
            guard let homeController = self.delegate as? HomeController else { return }
            if translationDirection == 1 {
                homeController.handleLike()
            } else {
                homeController.handleDislike()
            }
        } else {
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut) {
                self.transform = .identity
            }

        }
    }

    fileprivate func handleChanged(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let degress: CGFloat = translation.x / 20
        let angle = degress * .pi / 180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
    }

    @objc func handleMoreInfo() {
        delegate?.presentInfoController(cardViewModel: cardViewModel)
    }

}
