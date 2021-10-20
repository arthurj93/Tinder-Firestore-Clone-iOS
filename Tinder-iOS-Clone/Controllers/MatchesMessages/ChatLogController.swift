//
//  ChatLogController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 21/09/21.
//

import LBTATools

struct Message {
    let text: String
    let isFromCurrentLoggedUser: Bool
}

class MessageCell: LBTAListCell<Message> {

    let textView: UITextView = {
        let tv: UITextView = .init()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 20)
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()

    let bubbleContainer : UIView = .init(backgroundColor: #colorLiteral(red: 0.9005706906, green: 0.9012550712, blue: 0.9006766677, alpha: 1))
//    var anchoredConstraints: AnchoredConstraints!
    override var item: Message! {
        didSet {
            textView.text = item.text
            bubbleContainerConstraint(isFromCurrentUser: item.isFromCurrentLoggedUser)
        }
    }

    override func setupViews() {
        super.setupViews()
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        bubbleContainer.addSubview(textView)
        textView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(4)
            $0.trailing.equalToSuperview().inset(12)
        }
    }

    fileprivate func bubbleContainerConstraint(isFromCurrentUser: Bool) {
        if isFromCurrentUser {
            bubbleContainer.backgroundColor = #colorLiteral(red: 0.1471898854, green: 0.8059007525, blue: 0.9965714812, alpha: 1)
            textView.textColor = .white
            bubbleContainer.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.bottom.equalToSuperview()
                $0.trailing.equalToSuperview().inset(20)
                $0.width.lessThanOrEqualTo(250)
            }
        } else {
            bubbleContainer.backgroundColor = #colorLiteral(red: 0.9005706906, green: 0.9012550712, blue: 0.9006766677, alpha: 1)
            textView.textColor = .black
            bubbleContainer.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalToSuperview().inset(20)
                $0.bottom.equalToSuperview()
                $0.width.lessThanOrEqualTo(250)
            }
        }
    }
}


class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {

    fileprivate lazy var customNavBar: MessageNavBar = .init(match: match)

    fileprivate let navBarHeight: CGFloat = 150
    fileprivate let match: Match

    init(match: Match) {
        self.match = match
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        items = [
            .init(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.", isFromCurrentLoggedUser: true),
            .init(text: "hello bud", isFromCurrentLoggedUser: false),
            .init(text: "hello from tinder course", isFromCurrentLoggedUser: true)
        ]

        view.addSubview(customNavBar)
        customNavBar.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.topMargin)
            $0.height.equalTo(navBarHeight)
        }
        collectionView.contentInset.top = navBarHeight
        collectionView.verticalScrollIndicatorInsets.top = navBarHeight
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        let statusBarCover: UIView = .init(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.bottom.equalTo(view.snp.topMargin)
            $0.trailing.equalToSuperview()
        }
    }

    @objc func handleBack() {
        navigationController?.popViewController(animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let estimatedSizeCell = MessageCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: 1000))

        estimatedSizeCell.item = self.items[indexPath.item]
        estimatedSizeCell.layoutIfNeeded()
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(.init(width: view.frame.width, height: 1000))
        return .init(width: view.frame.width, height: estimatedSize.height)
    }

}
