//
//  RegistrationController.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 06/06/21.
//

import UIKit
import Firebase
import JGProgressHUD

class RegistrationController: UIViewController {

    //MARK:- Variables
    let registrationViewModel: RegistrationViewModel = .init()
    let registeringHUD = JGProgressHUD(style: .dark)

    let selectPhotoButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 32, weight: .heavy)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.snp.makeConstraints {
            $0.height.equalTo(275)
        }
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }()

    let fullNameTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter full name"
        tf.backgroundColor = .white
        tf.autocorrectionType = .no
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()

    let emailTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter email"
        tf.autocorrectionType = .no
        tf.keyboardType = .emailAddress
        tf.backgroundColor = .white
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()

    let passwordTextField: CustomTextField = {
        let tf = CustomTextField(padding: 24, height: 50)
        tf.placeholder = "Enter password"
        tf.isSecureTextEntry = true
        tf.backgroundColor = .white
        tf.autocorrectionType = .no
        tf.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return tf
    }()

    let registerButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .heavy)
        button.backgroundColor = .lightGray
        button.setTitleColor(.gray, for: .disabled)
        button.isEnabled = false
        button.layer.cornerRadius = 22
        button.snp.makeConstraints {
            $0.height.equalTo(44)
        }
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()

    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            fullNameTextField,
            emailTextField,
            passwordTextField,
            registerButton
        ])
        sv.axis = .vertical
        sv.distribution = .fillEqually
        sv.spacing = 8
        return sv
    }()

    lazy var overallStackView: UIStackView = .init(arrangedSubviews: [
        selectPhotoButton,
        verticalStackView
    ])

    let loginButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.setTitle("Go to Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .heavy)
        button.addTarget(self, action: #selector(handleGoToLogin), for: .touchUpInside)
        return button
    }()

    let gradientLayer = CAGradientLayer()

    //MARK:- Setup

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGradientLayer()
        setupLayout()
        setupTapGesture()
        setupRegistrationViewModalObserver()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    fileprivate func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(overallStackView)
        overallStackView.axis = .vertical
        overallStackView.spacing = 8
        overallStackView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(50)
            $0.trailing.equalToSuperview().inset(50)
            $0.centerY.equalToSuperview()
        }

        view.addSubview(loginButton)
        loginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottomMargin)
        }
    }

    func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.3725490196, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1)
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }

    func setupTapGesture() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
    }

    fileprivate func setupRegistrationViewModalObserver() {
        registrationViewModel.bindableIsFormValid.bind { [weak self] isFormValid in
            guard let isFormValid = isFormValid else { return }
            self?.registerButton.isEnabled = isFormValid
            if isFormValid {
                self?.registerButton.backgroundColor = #colorLiteral(red: 0.800593555, green: 0.1297297776, blue: 0.335547626, alpha: 1)
                self?.registerButton.setTitleColor(.white, for: .normal)
            } else {
                self?.registerButton.backgroundColor = .lightGray
                self?.registerButton.setTitleColor(.gray, for: .normal)
            }
        }

        registrationViewModel.bindableImage.bind { [weak self] image in
            self?.selectPhotoButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        }

        registrationViewModel.bindableIsRegistering.bind { [weak self] isRegistering in
            if isRegistering == true {
                self?.registeringHUD.textLabel.text = "Register"
                self?.registeringHUD.show(in: self?.view ?? UIView())
            } else {
                self?.registeringHUD.dismiss()
            }
        }
    }

    //MARK:- Functions

    @objc func handleRegister() {
        handleTapDismiss()
        registrationViewModel.bindableIsRegistering.value = true
        registrationViewModel.performRegistration { [weak self] (err) in
            if let err = err {
                self?.showHUDWithError(error: err)
                return
            }
            print("Finished register our user")
        }
    }

    fileprivate func showHUDWithError(error: Error) {
        registeringHUD.dismiss()
        let hud: JGProgressHUD = .init(style: .dark)
        hud.textLabel.text = "Failed registration"
        hud.detailTextLabel.text = error.localizedDescription
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4)
    }

    @objc func handleTextChange(textField: UITextField) {
        if textField == fullNameTextField {
            registrationViewModel.fullName = textField.text
        } else if textField == emailTextField {
            registrationViewModel.email = textField.text
        } else {
            registrationViewModel.password = textField.text
        }
    }

    @objc func handleTapDismiss() {
        self.view.endEditing(true)
    }

    @objc func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc func handleGoToLogin() {
        let loginController: LoginController = .init()
        navigationController?.pushViewController(loginController, animated: true)
    }
}

extension RegistrationController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        registrationViewModel.bindableImage.value = image
        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

