//
//  SettingsViewController.swift
//  TinderTest
//
//  Created by Apple on 22/05/18.
//  Copyright © 2018 David Seek. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import FBSDKLoginKit
import CoreLocation

class SettingsViewController: UIViewController,CLLocationManagerDelegate {

    @IBOutlet var currentLocationLbl: UILabel!
    @IBOutlet weak var menLbl: UILabel!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var ageShowLbl: UILabel!
    @IBOutlet weak var ageSlider: UISlider!
    @IBOutlet weak var kilometreSlider: UISlider!
    @IBOutlet weak var kilometreShowLbl: UILabel!
    var lattitudeSetVC: String? = ""
    var longitudeSetVC: String? = ""
    var last_time = true
    var passRange : Int!
    var locManagerSetVC:CLLocationManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Designs
       logoutBtn.cornerRoundButton()
       fetchingLocationSetVC()
    }
    
    func fetchingLocationSetVC(){
            locManagerSetVC = CLLocationManager()
            locManagerSetVC.delegate = self
            locManagerSetVC.desiredAccuracy = kCLLocationAccuracyBest
            locManagerSetVC.requestAlwaysAuthorization()
            locManagerSetVC.startUpdatingLocation()
            last_time = true
            locManagerSetVC.startUpdatingLocation()
    }
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations.last as! CLLocation
        if self.last_time {
            self.last_time = false
            self.locManagerSetVC.stopUpdatingLocation()
        }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
        if (error != nil){
                    print("error in reverseGeocode")
                }
                let geocoder = CLGeocoder()
                geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
                    if (error != nil){
                        print("error in reverseGeocode")
                    }
                    let placemark = placemarks!.last
                    print(placemark!.locality!)
                    print(placemark!.administrativeArea)
                    print(placemark!.country)
                    print("\(placemark!.locality), \(placemark!.administrativeArea), \(placemark!.country)")
                    self.currentLocationLbl.text = "\(placemark!.locality!), \(placemark!.administrativeArea!), \(placemark!.country!)"
                }
            }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }

    @IBAction func kilometreSliderAction(_ sender: UISlider) {
        let currentValue = Int(kilometreSlider.value)
        kilometreShowLbl.text = ("\(currentValue)km.")
        passRange = currentValue
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ageSliderAction(_ sender: UISlider) {
        let currentAge = Int(ageSlider.value)
        ageShowLbl.text = ("\(currentAge)-55")
    }
    @IBAction func doneBtnSettings(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
//        let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
//        let newController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
//        newController.getRangeValue = passRange
//        self.present(newController, animated: true, completion: nil)
    }
    
    
    @IBAction func menWomenBtnAction(_ sender: UIButton) {
        
//        let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
//        let newController = storyboard.instantiateViewController(withIdentifier: "MenWomenTableViewController") as! MenWomenTableViewController
//        self.present(newController, animated: true, completion: nil)
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        handleSignOutButtonTapped()
    }
    func handleSignOutButtonTapped() {
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            let login = FBSDKLoginManager()
            FBSDKAccessToken.setCurrent(nil)
            if Auth.auth().currentUser != nil {
                login.logOut()
                UserDefaults.standard.removeObject(forKey: "userDetails")
                
              // self.dismiss(animated: true, completion: nil)
            let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
            let newController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(newController, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        Service.showAlert(on: self, style: .actionSheet, title: nil, message: nil, actions: [signOutAction, cancelAction], completion: nil)
    }

}
