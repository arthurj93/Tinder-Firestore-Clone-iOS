//
//  SwipingPhotosController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 09/07/21.
//

import UIKit

class SwipingPhotosController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    //MARK:- Variables

    var cardViewModel: CardViewModel! {
        didSet {
            print(cardViewModel.attributedString)
            controllers = cardViewModel.imageUrls.map({ (imageUrl) in
                let photoController = PhotoController(imageUrl: imageUrl)
                return photoController
            })

            setViewControllers([controllers.first!], direction: .forward, animated: false)
            setupBarViews()
        }
    }

    var controllers: [UIViewController] = .init()
    let barStackView: UIStackView = .init(arrangedSubviews: [])
    let deselectBarColor: UIColor = .init(white: 0, alpha: 0.1)

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.backgroundColor = .white
        view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap)))
    }

    //MARK:- Setup

    func setupBarViews() {
        cardViewModel.imageUrls.forEach { _ in
            let barView: UIView = .init()
            barView.backgroundColor = deselectBarColor
            barView.layer.cornerRadius = 2
            barStackView.addArrangedSubview(barView)
        }
        barStackView.spacing = 4
        barStackView.distribution = .fillEqually
        barStackView.arrangedSubviews.first?.backgroundColor = .white
        view.addSubview(barStackView)
        barStackView.snp.makeConstraints {
            $0.top.equalTo(view.snp.topMargin).inset(8)
            $0.leading.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.height.equalTo(4)
        }
    }

    //MARK:- Functions

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1 { return nil }
        return controllers[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = self.controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 { return nil }
        return controllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let currentPhotoController = viewControllers?.first
        guard let index = self.controllers.firstIndex(where: {$0 == currentPhotoController}) else { return }
        barStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectBarColor }
        barStackView.arrangedSubviews[index].backgroundColor = .white
    }

    @objc func handleTap(gesture: UITapGestureRecognizer) {

        let currentController = viewControllers!.first!

        if let index = controllers.firstIndex(of: currentController) {

            barStackView.arrangedSubviews.forEach { $0.backgroundColor = deselectBarColor }

            if gesture.location(in: self.view).x > view.frame.width / 2 {
                let nextIndex = min(index + 1, controllers.count - 1)
                let nextController = controllers[nextIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                barStackView.arrangedSubviews[nextIndex].backgroundColor = .white
            } else {
                let previousIndex = max(0, index - 1)
                let nextController = controllers[previousIndex]
                setViewControllers([nextController], direction: .forward, animated: false)
                barStackView.arrangedSubviews[previousIndex].backgroundColor = .white
            }

        }
    }

}
