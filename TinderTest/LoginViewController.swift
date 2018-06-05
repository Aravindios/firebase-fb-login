//
//  LoginViewController.swift
//  TinderTest
//
//  Created by Apple on 17/05/18.
//  Copyright © 2018 David Seek. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import FirebaseDatabase
import SwiftyJSON
import FirebaseStorage
import JGProgressHUD
import SDWebImage
import CoreLocation

//import FirebaseMessaging

var locManager:CLLocationManager!


class LoginViewController: UIViewController, CLLocationManagerDelegate  {

   
    
    var name: String? = ""
    var gender: String? = ""
    var username: String? = ""
    var email: String? = ""
    var profileImage: UIImage?
    var lattitude: String? = ""
    var longitude: String? = ""
    var last_time = true
   
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fbBtn: UIButton!
 @IBOutlet weak var phoneNumBtn: UIButton!
    
    override func viewDidLoad() {
        
        //Login Button Design
        
        fbBtn.setTitle("Login with Facebook", for: .normal)
         fbBtn.setImage(#imageLiteral(resourceName: "FacebookButton").withRenderingMode(.alwaysTemplate), for: .normal)
        fbBtn.loginButtonDesign()
        
        phoneNumBtn.setTitle("Login with Phone Number", for: .normal)
        phoneNumBtn.loginButtonDesign()
        
        //PageViewController
        
        
        
    }
    func fetchingLocation(){
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
             last_time = true
            locManager.startUpdatingLocation()
        }
    }
  
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations.last as! CLLocation
        
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        lattitude = "\(userLocation.coordinate.latitude)"
        longitude = "\(userLocation.coordinate.longitude)"
        if last_time {
            self.last_time = false
            locManager.stopUpdatingLocation()
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }

    @IBAction func fbBtnAction(_ sender: UIButton) {
        handleSignInWithFacebookButtonTapped()
        
    }

    func handleSignOutButtonTapped() {
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            do {
                try Auth.auth().signOut()
               // CredentialState.sharedInstance.signedIn = false
                let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
                let newController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(newController, animated: true, completion: nil)
            } catch let err {
                print("Failed to sign out with error", err)
                
                Service.showAlert(on: self, style: .alert, title: "Sign Out Error", message: err.localizedDescription)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        Service.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, cancelAction], completion: nil)
    }
    
    func handleSignInWithFacebookButtonTapped() {
        
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = FBSDKLoginBehavior.web
        loginManager.logIn(withReadPermissions: ["public_profile","email"], from: self) { (result, error) in
            if (error != nil) {
                print("Process error")
                loginManager.logOut()
            }
            else if (result?.isCancelled)! {
                print("Cancelled")
                  loginManager.logOut()
            }
            else {
                self.hud.textLabel.text = "Logging in with Facebook..."
                self.hud.show(in: self.view, animated: true)
                self.signIntoFirebase()
                
            }
        }
    }

    func signIntoFirebase() {
        guard let authenticationToken = FBSDKAccessToken.current().tokenString
        else { return }
        let credential = FacebookAuthProvider.credential(withAccessToken: authenticationToken)
        Auth.auth().signIn(with: credential) { (user, err) in
            if let err = err {
                print("Sign up error")
                Service.dismissHud(self.hud, text: "Sign up error", detailText: err.localizedDescription, delay: 3)
                return
            }
            print("Succesfully authenticated with Firebase.")
            self.fetchFacebookUser()
        }
    }
    
    func fetchFacebookUser() {
        
        let graphRequestConnection = FBSDKGraphRequestConnection()
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "name, picture.type(large), email"]).start(completionHandler: { (httpResponse, result, error) -> Void in
        if (error == nil){
            print("FETCHFacebookUSER\(result)")
            print("FETCHFacebookUSER\(result!)")
            let json = JSON(result)
            self.name = json["name"].stringValue
            self.gender = json["gender"].stringValue
            self.email = json["email"].stringValue
            
            let profilePictureUrl = json["picture"]["data"]["url"].stringValue
            let url = URL(string: profilePictureUrl)
            URLSession.shared.dataTask(with: url!) { (data, response, err) in
            if let data = try? Data(contentsOf: url!){
                    self.profileImage = UIImage(data: data)!
                    self.saveUserIntoFirebaseDatabase()
                }
            }.resume()
        }
        })
        //Location Fetching
        fetchingLocation()
    }
    
    func saveUserIntoFirebaseDatabase () {
            
            guard let uid = Auth.auth().currentUser?.uid,
                let name = self.name,
                let username = self.username,
                let email = self.email,
                let gender = self.gender,
                let profileImage = profileImage,
                let lattitude = lattitude,
                let longitude = longitude,
                let profileImageUploadData = UIImageJPEGRepresentation(profileImage, 0.3) else {
                    print("Error")
                    Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3);
                    return
            }
         //   let fileName = UUID().uuidString
        let fileName = uid
        print("FILENAME:\(fileName)")
            Storage.storage().reference().child("profileImages").child(fileName).putData(profileImageUploadData, metadata: nil) { (metadata, err) in
            if let err = err {
                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user with error: \(err)", delay: 3);
                return
            }
            guard let profileImageUrl = metadata?.downloadURL()?.absoluteString else {
                print("Error")
                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user.", delay: 3);
                return
            
            }
            print("Successfully uploaded profile image into Firebase storage with URL:", profileImageUrl)
            let dictionaryValues = ["name": name,
                                    
                                        "email": email,
                                        "username": username,
                                        "profileImageUrl": profileImageUrl,
                                        "lattitude": lattitude,
                                        "longitude": longitude] as Dictionary
            let values = [uid : dictionaryValues]
            Database.database().reference().child("users").updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to save user info with error: \(err)", delay: 3)
                return
            }
            print("Successfully saved user info into Firebase database")
            UserDefaults.standard.set(uid, forKey: "userDetails")
            //after successfull save dismiss the Login view controller
            self.hud.dismiss(animated: true)
            self.dismiss(animated: true, completion: nil)
               
            })
        }
    }

}
extension UIButton{
    func loginButtonDesign () {
        //FB Button
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: Service.buttonTitleFontSize)
        self.setTitleColor(Service.buttonTitleColor, for: .normal)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = Service.buttonCornerRadius
        self.backgroundColor = UIColor (red: 0/255.0, green: 122/255.0, blue: 255/255.0, alpha: 1.0)
        self.tintColor = .white
        self.contentMode = .scaleAspectFit
    }
}



