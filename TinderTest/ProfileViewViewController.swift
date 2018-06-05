//
//  ProfileViewViewController.swift
//  TinderTest
//
//  Created by Apple on 17/05/18.
//  Copyright © 2018 David Seek. All rights reserved.
//

import UIKit

class ProfileViewViewController: UIViewController {

    @IBOutlet weak var imageViewProfileVC: UIImageView!
    @IBOutlet weak var editInfoBtn: UIButton!
    
    @IBOutlet weak var userNameProfileVC: UILabel!
    var profileImageProVC: UIImage?
    var profileNameProVC: String = ""
    
    @IBOutlet weak var backProVCBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Assigning the value
        self.userNameProfileVC.text = profileNameProVC
        self.imageViewProfileVC.image = profileImageProVC
        
       
        backProVCBtn.rounddesignButton()
        
        editInfoBtn.cornerRoundButton()
        
        
        

    }
    
    @IBAction func backbtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editinfoAction(_ sender: UIButton) {
//        let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
//        let newController = storyboard.instantiateViewController(withIdentifier: "EditInfoViewController") as! EditInfoViewController
//      //  self.present(newController, animated: true, completion: nil)
//        self.navigationController?.pushViewController(newController, animated: true)
        
//        self.performSegue(withIdentifier: "editInfoPVVCSegue", sender: self)
        // create the alert
     /*   let alert = UIAlertController(title: "UIAlertController", message: "Would you like to continue learning how to use iOS alerts?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)*/
    }
    
    

}
extension UIButton{
    func cornerRoundButton() {
        self.layer.cornerRadius = self.frame.size.height / 2
        self.layer.borderWidth = 0
        self.layer.borderColor = UIColor.darkGray.cgColor
        self.layer.shadowColor = UIColor.white.cgColor
        self.clipsToBounds = true
    }
}
