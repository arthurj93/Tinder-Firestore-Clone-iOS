//
//  FireBaseUtils+Extension.swift
//  Tinder-iOS-Clone
//
//  Created by Arthur Octavio Jatobá Macedo Leite - ALE on 07/07/21.
//

import Firebase
import FirebaseFirestore
import JGProgressHUD

extension Firestore {
    func fetchCurrentUser(completion: @escaping (User?, Error?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                completion(nil, err)
                return
            }

            // fetched our user here
            guard let dictionary = snapshot?.data() else { return }
            let user = User(dictionary: dictionary)
            completion(user, nil)
        }
    }

    func saveUserData(user: User, buttons: [UIButton], imageCount: Int, hud: JGProgressHUD, completion: @escaping (Error?) -> ()) {
        saveUserProfileImages(user: user, buttons: buttons, count: imageCount, hud: hud) { (user, hud, valid) in
            guard let user = user, let valid = valid else { return }
            if valid {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let docData: [String: Any] = [
                    "uid": uid,
                    "fullName": user.name ?? "",
                    "imageUrl1": user.imageUrl1,
                    "imageUrl2": user.imageUrl2,
                    "imageUrl3": user.imageUrl3,
                    "age": user.age ?? -1,
                    "profession": user.profession ?? "",
                    "minSeekingAge": user.minSeekingAge ?? 18,
                    "maxSeekingAge": user.maxSeekingAge ?? 60
                ]

                Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
                    hud?.dismiss()
                    if let err = err {
                        print("Failed to save user settings:", err)
                        completion(err)
                        return
                    }

                    print("Finished save user info")
                    completion(nil)
                }
            }
        }
    }

    fileprivate func saveUserProfileImages(user: User, buttons: [UIButton], count: Int, hud: JGProgressHUD, completion: @escaping (User?, JGProgressHUD?, Bool?) -> ()) {
        var user = user
        for (index, button) in buttons.enumerated() {

            if let image = button.imageView?.image {
                let filename = UUID().uuidString
                let ref = Storage.storage().reference(withPath: "/images/\(filename)")
                guard let uploadData = image.jpegData(compressionQuality: 0.75) else { return }

                ref.putData(uploadData, metadata: nil) { (_, err) in
                    if let err = err {
                        hud.dismiss()
                        completion(nil, nil, nil)
                        print("Failed to upload image to storage:", err)
                        return
                    }

                    print("Finished upload image")
                    ref.downloadURL { (url, err) in
                        if let err = err {
                            hud.dismiss()
                            print("Failed to retrieve download URL:", err)
                            completion(nil, nil, nil)
                            return
                        }

                        print("Finished gettint download url:", url?.absoluteString ?? "")
                        if index == 0 {
                            user.imageUrl1 = url?.absoluteString
                        } else if index == 1 {
                            user.imageUrl2 = url?.absoluteString
                        } else {
                            user.imageUrl3 = url?.absoluteString
                        }
                        if index + 1 == count {
                            completion(user, hud, true)
                        } else {
                            completion(user, hud, false)
                        }
                    }
                }
            }
        }
    }
}

