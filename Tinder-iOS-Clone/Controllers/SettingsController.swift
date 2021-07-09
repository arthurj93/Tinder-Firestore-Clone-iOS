//
//  SettingsController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 05/07/21.
//

import UIKit
import FirebaseFirestore
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate: class {
    func didSaveSettings()
}

class CustomImagePickerController: UIImagePickerController {
    var imageButton: UIButton?
}

class SettingsController: UITableViewController {

    //MARK:- Variables

    lazy var imageButton1 = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButton2 = createButton(selector: #selector(handleSelectPhoto))
    lazy var imageButton3 = createButton(selector: #selector(handleSelectPhoto))

    weak var delegate: SettingsControllerDelegate?

    var user: User?
    let hud: JGProgressHUD = .init(style: .dark)

    lazy var header: UIView = {
        let header = UIView()
        let padding: CGFloat = 16
        header.addSubview(imageButton1)
        imageButton1.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(padding)
            $0.bottom.equalToSuperview().inset(padding)
            $0.top.equalToSuperview().inset(padding)
            $0.width.equalToSuperview().multipliedBy(0.45)
        }
        let stackView: UIStackView = .init(arrangedSubviews: [imageButton2, imageButton3])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        header.addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(padding)
            $0.bottom.equalToSuperview().inset(padding)
            $0.trailing.equalToSuperview().inset(padding)
            $0.leading.equalTo(imageButton1.snp.trailing).offset(padding)
        }
        return header
    }()

    fileprivate func createButton(selector: Selector) -> UIButton {
        let button: UIButton = .init(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }

    //MARK:- Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
        tableView.backgroundColor = .init(white: 0.95, alpha: 1)
        tableView.tableFooterView = .init()
        tableView.keyboardDismissMode = .interactive
        fetchCurrentUser()
    }

    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }

            guard let dictionary = snapshot?.data() else { return }
            self.user = .init(dictionary: dictionary)
            self.loadUserPhotos()
            self.tableView.reloadData()
        }
    }

    fileprivate func setupNavigation() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = .init(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            .init(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            .init(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        ]
    }


    fileprivate func loadUserPhotos() {
        if let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.imageButton1.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }

        if let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.imageButton2.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }

        if let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared.loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.imageButton3.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }

    // MARK:- Functions

    @objc func handleSave() {
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        var images: [UIImage] = .init()
        for button in [imageButton1, imageButton2, imageButton3] {
            if let image = button.imageView?.image {
                images.append(image)
            }
        }

        guard let user = user else { return }
        Firestore.firestore().saveUserData(user: user, buttons: [imageButton1, imageButton2, imageButton3], imageCount: images.count, hud: hud) { err in
            if err != nil {
                return
            }

            self.dismiss(animated: true) {
                self.delegate?.didSaveSettings()
            }
        }
    }

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func handleLogout() {
        try? Auth.auth().signOut()
        dismiss(animated: true) {
            
        }
    }

    @objc func handleSelectPhoto(button: UIButton) {
        let imagePicker: CustomImagePickerController = .init()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func handleMinAgeChanged(slider: UISlider) {
        evaluateMinMax()
    }

    @objc func handleMaxAgeChanged(slider: UISlider) {
        evaluateMinMax()
    }

    fileprivate func evaluateMinMax() {
        guard let ageRangeCell = tableView.cellForRow(at: [5, 0]) as? AgeRangeCell else { return }
        let minValue = Int(ageRangeCell.minSlider.value)
        var maxValue = Int(ageRangeCell.maxSlider.value)
        maxValue = max(minValue, maxValue)
        ageRangeCell.maxSlider.value = Float(maxValue)
        ageRangeCell.minLabel.text = "Min \(minValue)"
        ageRangeCell.maxLabel.text = "Max \(maxValue)"

        user?.minSeekingAge = minValue
        user?.maxSeekingAge = maxValue
    }

    @objc func handleNameChange(textField: UITextField) {
        self.user?.name = textField.text
    }

    @objc func handleProfessionChange(textField: UITextField) {
        self.user?.profession = textField.text
    }

    @objc func handleAgeChange(textField: UITextField) {
        self.user?.age = Int(textField.text ?? "")
    }

}

extension SettingsController {

    //MARK:- TableView

    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 5 {
            let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
            ageRangeCell.minSlider.addTarget(self, action: #selector(handleMinAgeChanged), for: .valueChanged)
            ageRangeCell.maxSlider.addTarget(self, action: #selector(handleMaxAgeChanged), for: .valueChanged)
            ageRangeCell.minLabel.text = "Min \(user?.minSeekingAge ?? -1)"
            ageRangeCell.maxLabel.text = "Max \(user?.maxSeekingAge ?? -1)"
            return ageRangeCell
        }
        let cell: SettingsCell = .init(style: .default, reuseIdentifier: nil)
        switch indexPath.section {
        case 1:
            cell.textField.placeholder = "Enter Name"
            cell.textField.text = user?.name
            cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
        case 2:
            cell.textField.placeholder = "Enter Profession"
            cell.textField.text = user?.profession
            cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
        case 3:
            cell.textField.placeholder = "Enter Age"
            cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
            if let age = user?.age {
                cell.textField.text = "\(age)"
            }
        default:
            cell.textField.placeholder = "Enter Bio"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel: HeaderLabel = .init()
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"
        default:
            headerLabel.text = "Seeking age range"
        }
        headerLabel.font = .boldSystemFont(ofSize: 16)
        return headerLabel
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 40
    }
}


extension SettingsController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true, completion: nil)
    }

}
