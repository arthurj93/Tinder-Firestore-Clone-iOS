//
//  MessageCell.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 15/11/21.
//

import LBTATools

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

