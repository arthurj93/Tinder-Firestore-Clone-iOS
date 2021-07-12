//
//  PhotoController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 10/07/21.
//

import UIKit

class PhotoController: UIViewController {

    let imageView = UIImageView(image: #imageLiteral(resourceName: "photo_placeholder"))

    init(imageUrl: String) {
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url)
        }
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageView)
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints {
            $0.top.trailing.leading.bottom.equalToSuperview()
        }
        imageView.contentMode = .scaleAspectFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

