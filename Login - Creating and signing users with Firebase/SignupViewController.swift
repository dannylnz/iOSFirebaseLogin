//
//  SignupViewController.swift
//  Login - Creating and signing users with Firebase
//
//  Created by Daniele Lanzetta on 23.03.17.
//  Copyright © 2017 Daniele Lanzetta. All rights reserved.
//

import UIKit
import Firebase




class SignupViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    //Outlets
    @IBOutlet var nameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var comPwField: UITextField!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    
        // Var & Let
    

    let picker = UIImagePickerController()
    var userStorage: FIRStorageReference!
    var ref: FIRDatabaseReference!
    
    
    
    
    // ViewDidLoad (what is loaded before app is fully loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        let storage = FIRStorage.storage().reference(forURL: "gs://login-users-with-firebase.appspot.com")
      
        ref = FIRDatabase.database().reference()
        userStorage = storage.child("users")
        
        }

    
        //Actions
    
    @IBAction func selectImagePressed(_ sender: Any) {
        
        picker.allowsEditing = true
          picker.sourceType = .photoLibrary
           present(picker, animated: true, completion: nil)
        
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.imageView.image = image
            nextBtn.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }

    
    
    @IBAction func nextPressed(_ sender: Any) {
        
        guard nameField.text != "", emailField.text != "" , passwordField.text != "",comPwField.text != "" else {
            
            return
            
        }
        
        if passwordField.text == comPwField.text {
            
            FIRAuth.auth()?.createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { (user, error) in
                if let error = error {
                    
                    print(error.localizedDescription)
                    
                    
                    if let user = user {
                        
                        
                        let changeRequest = FIRAuth.auth()?.currentUser!.profileChangeRequest()
                        changeRequest?.displayName = self.nameField.text!
                        changeRequest?.commitChanges(completion: nil)
                        
                        let imageRef =  self.userStorage.child("\(user.uid).jpg")
                        let data = UIImageJPEGRepresentation(self.imageView.image!, 0.5)
                        let uploadTask = imageRef.put(data!, metadata: nil, completion: { (metadata, err) in
                            if err != nil {
                                print(err!.localizedDescription)
                                
                                
                            }
                            
                            imageRef.downloadURL(completion: { (url, er) in
                                if er != nil {
                                    print(er!.localizedDescription)
                                }
                                
                                if let url = url {
                                
                                    let userInfo : [String: Any] = ["uid": user.uid,
                                                                    "full name" : self.nameField.text!,
                                                                    "urlToImage": url.absoluteString]
                                    
                                    self.ref.child("users").child(user.uid).setValue(userInfo)
                                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "userVC")
                                    
                                    self.present(vc, animated: true, completion: nil)
                                    
                                    
                                    
                                    
                                }
                                
                                
                            })
                            
                        })
                        
                        uploadTask.resume()
                        
                        
                        
                    }
                }
            })
            
        } else {
            
            print("password does not match")
            
        }
        
        
        
        
        
        
        
        
        
        
        
    }

}
