//
//  ViewController.swift
//  TinderTest
//
//  Created by David Seek on 10/27/16.
//  Copyright © 2016 David Seek. All rights reserved.
//

import UIKit
import SLPagingViewSwift_Swift3
import FirebaseDatabase
import FirebaseAuth
import JGProgressHUD
import SwiftyJSON
import CoreLocation
//import FirebaseMessaging

class OneVC: UIViewController{

    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
     var proImage: UIImage?
     var proname: String? = ""
    var getRangeValue : Int!

    @IBOutlet weak var designOuterTwo: UIImageView!
    @IBOutlet weak var designOuterOne: UIImageView!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var editInfoBtn: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //status checked
        checkLoggedInUserStatus()
       
        //Fetch User Profile
        handleFetchUserButtonTapped()

        //Design
        editInfoBtn.rounddesignButton()
       settingsBtn.rounddesignButton()
        designOuterTwo.rounddesignImageView()
        designOuterOne.rounddesignImageView()
        
        //profileImg.rounddesignImageView()
        settingsView.rounddesignView()
        editView.rounddesignView()
        profileBtn.rounddesignButton()
        profileImageView.rounddesignImageView()
    }
    
    fileprivate func checkLoggedInUserStatus() {
        if Auth.auth().currentUser == nil {
            
            DispatchQueue.main.async {
                let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
                let newController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(newController, animated: false, completion: nil)
                return
            }
        }

    }
    
    func handleFetchUserButtonTapped() {
        //hud.textLabel.text = "Fetching user..."
        hud.show(in: view, animated: true)
        if Auth.auth().currentUser != nil {
            guard let uid = Auth.auth().currentUser?.uid else {
                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3);
                return
            }
            Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : Any] else {
                    Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user.", delay: 3);
                    return
                }
                let user = CurrentUser(uid: uid, dictionary: dictionary)
                self.proname = user.name
                self.usernameLabel.text = self.proname
                let url = URL(string:user.profileImageUrl)
                if url != nil{
                    if let data = try? Data(contentsOf: url!)
                    {
                        let image: UIImage = UIImage(data: data)!
                        self.proImage = image
                        self.profileImageView.image = self.proImage
                    }
                } else {
                    print("URL NIL")
                }
                print(self.usernameLabel)
                print(self.profileImageView)
                Service.dismissHud(self.hud, text: "Success", detailText: "User fetched!", delay: 1)

            }, withCancel: { (err) in
                Service.dismissHud(self.hud, text: "Error", detailText: "Failed to fetch user with error: \(err)", delay: 3)
            })
        }
        
    }
    
    @IBAction func profileBtnAction(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
                let newController = storyboard.instantiateViewController(withIdentifier: "ProfileViewViewController") as! ProfileViewViewController
        newController.profileImageProVC = proImage
        newController.profileNameProVC = proname!
        
                self.present(newController, animated: true, completion: nil)
    }
    @IBAction func settingsBtnAction(_ sender: UIButton) {
      /*  let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
          //self.present(newController, animated: true, completion: nil)
        self.navigationController?.pushViewController(newController, animated: true)*/
        self.performSegue(withIdentifier: "SettingsSegue", sender: self)
        
    }
    @IBAction func editBtnAction(_ sender: UIButton) {
        /*let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
        let newController = storyboard.instantiateViewController(withIdentifier: "EditInfoViewController") as! EditInfoViewController
          self.present(newController, animated: true, completion: nil)
       // self.navigationController?.pushViewController(newController, animated: true)*/
        
        //self.performSegue(withIdentifier: "EditInfoSegue", sender: self)
        // create the alert
        let alert = UIAlertController(title: "UIAlertController", message: "This is my Message", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension UIView{
    func rounddesignView() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 0
}
}
extension UIImageView{
        func rounddesignImageView() {
            self.layer.cornerRadius = self.frame.size.width / 2
            self.clipsToBounds = true
            self.layer.borderWidth = 0
        }
}
extension UIButton{
    func rounddesignButton() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 0
        
    }
    
}

