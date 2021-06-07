//
//  HomeController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 13/04/21.
//

import UIKit
import SnapKit

class HomeController: UIViewController {

    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let buttonsStackView = HomeButtonsStackView()
    let cardViewModels: [CardViewModel] = {
        let producers = [
            User(name: "Kelly", age: 23, profession: "Music DJ", imageName: "lady5c"),
            User(name: "Jane", age: 18, profession: "Teacher", imageName: "lady4c"),
            Advertiser(title: "Slide Out Menu", brandName: "Lets Build That App", posterPhotoName: "slide_out_menu_poster")
        ] as [ProducesCardViewModel]
        let viewModels = producers.map { return $0.toCardViewModel() }
        return viewModels
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupDummyCards()
        view.backgroundColor = .white
    }
    
    fileprivate func setupDummyCards() {
        cardViewModels.forEach { cardViewModel in
            let cardView = CardView(frame: .zero)
            cardView.cardViewModel = cardViewModel
            cardsDeckView.addSubview(cardView)
            cardView.snp.makeConstraints {
                $0.top.trailing.bottom.leading.equalToSuperview()
            }
        }
    }

    // MARK:- Fileprivate
    
    fileprivate func setupLayout() {
        let mainStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, buttonsStackView])
        mainStackView.axis = .vertical
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.trailing.bottom.leading.equalToSuperview()
        }
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        mainStackView.bringSubviewToFront(cardsDeckView)
    }

}

