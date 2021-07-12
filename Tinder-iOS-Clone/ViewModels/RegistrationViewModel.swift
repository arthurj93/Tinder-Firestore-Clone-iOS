//
//  RegistrationViewModel.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 01/07/21.
//

import UIKit
import Firebase
import FirebaseFirestore

class RegistrationViewModel {

    var fullName: String? {
        didSet { checkFormValidity() }
    }
    var email: String? {
        didSet { checkFormValidity() }
    }
    var password: String? {
        didSet { checkFormValidity() }
    }

    var bindableImage = Bindable<UIImage>()
    var bindableIsFormValid = Bindable<Bool>()
    var bindableIsRegistering = Bindable<Bool>()

    func checkFormValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false && bindableImage.value != nil
        bindableIsFormValid.value = isFormValid
    }

    func performRegistration(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err {
                completion(err)
                return
            }

            self.saveImageToFirebase(completion: completion)
        }
    }

    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil) { (_, err) in
            if let err = err {
                completion(err)
                return
            }
            ref.downloadURL { (url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                self.bindableIsRegistering.value = false
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirestore(imageUrl: imageUrl, completion: completion)
            }
        }
    }

    fileprivate func saveInfoToFirestore(imageUrl: String, completion: @escaping (Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let docData: [String: Any] = ["fullName": fullName ?? "",
                       "uid": uid,
                       "imageUrl1": imageUrl,
                       "minSeekingAge": SettingsController.defaultMinSeekingAge,
                       "maxSeekingAge": SettingsController.defaultMaxSeekingAge,
                       "age": 18]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            if let err = err {
                completion(err)
                return
            }

            completion(nil)
        }
    }
}
