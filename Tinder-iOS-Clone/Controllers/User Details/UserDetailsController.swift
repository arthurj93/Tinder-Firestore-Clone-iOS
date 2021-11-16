//
//  UserDetailsController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 08/07/21.
//

import UIKit

class UserDetailsController: UIViewController {

    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    let extraSwipingHeight: CGFloat = 80
    lazy var scrollView: UIScrollView  = {
        let sv: UIScrollView = .init()
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        sv.delegate = self
        return sv
    }()

    let swipingPhotosController: SwipingPhotosController = .init(transitionStyle: .scroll, navigationOrientation: .horizontal)

    let infoLabel: UILabel = {
        let label: UILabel = .init()
        label.text = "User name 30\nDoctor\nbio text down below"
        label.numberOfLines = 0
        return label
    }()

    let dismissButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setImage(#imageLiteral(resourceName: "dismiss_down_arrow"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()

    lazy var dislikeButton = createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
    lazy var likeButton = createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleDislike))
    lazy var superLikeButton = createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleDislike))

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
        setupVisualBlurEffectView()
        setupBottomControls()
    }

    fileprivate func setupLayout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.leading.trailing.bottom.top.equalToSuperview()
        }

        let swipingView = swipingPhotosController.view!

        scrollView.addSubview(swipingView)
        scrollView.addSubview(infoLabel)
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(swipingView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        scrollView.addSubview(dismissButton)
        dismissButton.snp.makeConstraints {
            $0.trailing.equalTo(view.snp.trailing).inset(24)
            $0.top.equalTo(swipingView.snp.bottom).inset(25)
            $0.width.height.equalTo(50)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        swipingView.frame = .init(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
    }

    fileprivate func setupVisualBlurEffectView() {
        let blurEffect: UIBlurEffect = .init(style: .regular)
        let visualEffectView: UIVisualEffectView = .init(effect: blurEffect)
        view.addSubview(visualEffectView)
        visualEffectView.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.bottom.equalTo(view.snp.topMargin)
        }
    }

    fileprivate func setupBottomControls() {
        let stackView: UIStackView = .init(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottomMargin)
            $0.width.equalTo(300)
            $0.centerX.equalTo(view.snp.centerX)
            $0.height.equalTo(80)
        }
    }

    @objc fileprivate func handleDismiss() {
        self.dismiss(animated: true)
    }

    func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button: UIButton = .init(type: .system)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }

    @objc func handleDislike() {

    }

}

extension UserDetailsController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        let swipingView = swipingPhotosController.view!
        swipingView.frame = CGRect(x: min(0, -changeY), y: min(0, -changeY), width: width, height: width)
    }
}
