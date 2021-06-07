//
//  CardViewModel.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 13/04/21.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

struct CardViewModel {
    let imageName: String
    let attributeString: NSAttributedString
    let textAlignment: NSTextAlignment
}
