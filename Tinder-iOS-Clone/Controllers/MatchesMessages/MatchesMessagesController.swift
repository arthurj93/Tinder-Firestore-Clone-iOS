//
//  MatchesMessagesController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 07/09/21.
//

import UIKit
import LBTATools
import FirebaseFirestore
import Firebase

class MatchesMessagesController: LBTAListHeaderController<RecentMessageCell, RecentMessage, MatchesHeader>, UICollectionViewDelegateFlowLayout {
    
    //MARK:- Variables
    
    var recentMessagesDictionary: [String: RecentMessage] = [:]
    var listener: ListenerRegistration?
    let customNavBar = MatchesNavBar()
    override func setupHeader(_ header: MatchesHeader) {
        header.matchesHorizontalController.rootMatchesController = self
    }
    
    //MARK:- Setup

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecentMessages()

        collectionView.backgroundColor = .white

        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)

        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.topMargin)
            $0.height.equalTo(150)
        }

        collectionView.contentInset.top = 150
        collectionView.verticalScrollIndicatorInsets.top = 150
        
        let statusBarCover: UIView = .init(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.bottom.equalTo(view.snp.topMargin)
            $0.trailing.equalToSuperview()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            listener?.remove()
        }
    }
    
    //MARK:- Functions
    
    func didSelectMatchFromHeader(match: Match) {
        let chatLogController: ChatLogController = .init(match: match)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    //MARK:- Firebase

    fileprivate func fetchRecentMessages() {
        guard let currentUserUid = Auth.auth().currentUser?.uid else { return }
        let query = Firestore.firestore().collection("matches_messages").document(currentUserUid).collection("recent_messages")
        listener = query.addSnapshotListener { querySnapshot, err in
            if let err = err {
                print("Failed to fetch recent messages:", err)
                return
            }
            
            querySnapshot?.documentChanges.forEach({ change in
                if change.type == .added || change.type == .modified {
                    let dictionary = change.document.data()
                    let recentMessage = RecentMessage(dictionary: dictionary)
                    self.recentMessagesDictionary[recentMessage.uid] = recentMessage
                    
                }
            })
            
            self.resetItems()
        }
    }
    
    fileprivate func resetItems() {
        let values = Array(recentMessagesDictionary.values)
        items = values.sorted(by: { rm1, rm2 in
            return rm1.timestamp.compare(rm2.timestamp) == .orderedDescending
        })
        collectionView.reloadData()
    }

    @objc fileprivate func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    //MARK:- Delegate Collection

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 250)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let recentMessage = self.items[indexPath.item]
        let dictionary = ["name": recentMessage.name, "profileImageUrl": recentMessage.profileImageUrl, "uid": recentMessage.uid]
        let match = Match(dictionary: dictionary)
        let chatLogController: ChatLogController = .init(match: match)
        navigationController?.pushViewController(chatLogController, animated: true)
    }

}
