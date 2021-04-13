//
//  MainViewController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 13/04/21.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var topNavigationStackView: UIStackView!
    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var cardsView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        topNavigationStackView.isLayoutMarginsRelativeArrangement = true
        topNavigationStackView.layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)

        setupDummyCards()

        // Do any additional setup after loading the view.
    }

    func setupDummyCards() {
        let cardView = CardsView(frame: .zero)
        view.addSubview(<#T##view: UIView##UIView#>)
    }

}
