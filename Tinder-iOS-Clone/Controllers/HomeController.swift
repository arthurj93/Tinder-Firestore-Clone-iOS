//
//  HomeController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 13/04/21.
//

import UIKit
import SnapKit
import FirebaseFirestore
import JGProgressHUD
import Firebase

class HomeController: UIViewController {

    //MARK:- Variables
    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottonControls = HomeButtonsStackView()
    var cardViewModels: [CardViewModel] = []
    var topCardView: CardView?

    var user: User?
    var lastFetchedUser: User?
    var swipes: [String: Any] = .init()
    fileprivate let hud = JGProgressHUD(style: .dark)

    //MARK:- Setup
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        bottonControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        bottonControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottonControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
        setupLayout()
        fetchCurrentUser()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser == nil {
            let loginController: LoginController = .init()
            loginController.delegate = self
            let navController: UINavigationController = .init(rootViewController: loginController)
            navController.modalPresentationStyle = .fullScreen
            present(navController, animated: true)
        }
    }

    fileprivate func setupLayout() {
        let mainStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottonControls])
        mainStackView.axis = .vertical
        view.addSubview(mainStackView)
        mainStackView.snp.makeConstraints {
            $0.top.trailing.bottom.leading.equalToSuperview()
        }
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        mainStackView.bringSubviewToFront(cardsDeckView)
    }

    fileprivate func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView(frame: .zero)
        cardView.cardViewModel = user.toCardViewModel()
        cardView.delegate = self
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView)
        cardView.snp.makeConstraints {
            $0.top.trailing.bottom.leading.equalToSuperview()
        }
        return cardView
    }

    // MARK:- Firebase

    fileprivate func fetchCurrentUser() {
        hud.textLabel.text = "Loading"
        hud.show(in: view)
        cardsDeckView.subviews.forEach({$0.removeFromSuperview()})
        Firestore.firestore().fetchCurrentUser { (user, err) in
            if let err = err {
                print("Failed to fetch user:", err)
                self.hud.dismiss()
                return
            }
            self.user = user
            self.fetchSwipes()
//            self.fetchUsersFromFirestore()
        }
    }

    func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipes info for currently logged in user:", err)
                return
            }

            //use if let and put fetch users outside or if you dont have any swipes it wont fetch users
//            guard let data = snapshot?.data() as? [String: Int] else { return }
            if let data = snapshot?.data() as? [String: Int] {
                self.swipes = data
            }

            self.fetchUsersFromFirestore()
        }
    }

    func fetchUsersFromFirestore() {
//        guard let minAge = user?.minSeekingAge, let maxAge = user?.maxSeekingAge else { return }
        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge

//        let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
//        let query = Firestore.firestore().collection("users")
//        let query = Firestore.firestore().collection("users").whereField("age", isLessThan: 31).whereField("age", isGreaterThan: 23)
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge)
        topCardView = nil
        query.getDocuments { (snapshot, err) in
            self.hud.dismiss()
            if let err = err {
                print("failed to fetch users: ", err)
                return
            }
            var previousCardView: CardView?
            snapshot?.documents.forEach({ (documentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)

                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let hasNotSwipedBefore = true
//                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                if  isNotCurrentUser && hasNotSwipedBefore {
                    self.lastFetchedUser = user
                    let cardView = self.setupCardFromUser(user: user)

                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
            })
        }
    }

    fileprivate func saveSwipeToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        guard let cardUID = topCardView?.cardViewModel.uid else { return }

        let documentData = [cardUID: didLike]

        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print("Failed to fetch swipe document:", err)
                return
            }

            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                    print("Successfully updated swipe....")
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                    print("Successfully saved swipe....")
                }
            }
        }
    }

    fileprivate func checkIfMatchExists(cardUID: String) {
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snaphshot, err) in
            if let err = err {
                print("Failed to fetch document for card user:", err)
                return
            }
            guard let data = snaphshot?.data() else { return }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                self.presentMatchView(cardUID: cardUID)
//                let hud: JGProgressHUD = .init(style: .dark)
//                hud.textLabel.text = "Found a match"
//                hud.show(in: self.view)
//                hud.dismiss(afterDelay: 4)
            }
        }
    }

    //MARK:- Functions

    func presentMatchView(cardUID: String) {
        let matchView: MatchView = .init()
        view.addSubview(matchView)
        matchView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    @objc func handleLike() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
    }

    @objc func handleDislike() {
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -700, angle: -15)
    }

    fileprivate func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation: CABasicAnimation = .init(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = .init(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false

        let rotationAnimation: CABasicAnimation = .init(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration

        let cardView = topCardView
        topCardView = cardView?.nextCardView

        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }

        cardView?.layer.add(translationAnimation, forKey: "translation")
        cardView?.layer.add(rotationAnimation, forKey: "rotation")

        CATransaction.commit()
    }

    @objc func handleRefresh() {
        cardsDeckView.subviews.forEach { $0.removeFromSuperview() }
        fetchUsersFromFirestore()
    }

    @objc func handleSettings() {
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navController: UINavigationController = .init(rootViewController: settingsController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
    }
}

extension HomeController: SettingsControllerDelegate {
    func didSaveSettings() {
        fetchCurrentUser()
    }
}

extension HomeController: LoginControllerDelegate {
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
}

extension HomeController: CardViewDelegate {

    func presentInfoController(cardViewModel: CardViewModel) {
        let userDetailsController: UserDetailsController = .init()
        userDetailsController.modalPresentationStyle = .fullScreen
        userDetailsController.cardViewModel = cardViewModel
        present(userDetailsController, animated: true)
    }


    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }

}
