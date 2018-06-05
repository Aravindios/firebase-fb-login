//
//  TwoVC.swift
//  TinderTest
//
//  Created by David Seek on 10/27/16.
//  Copyright © 2016 David Seek. All rights reserved.
//

import UIKit
import SLPagingViewSwift_Swift3
import Koloda
import pop
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import JGProgressHUD
import SDWebImage
import SwiftyJSON
import NVActivityIndicatorView
import GeoFire
import SwiftyJSON

//private var numberOfCards: Int = 5

class TwoVC: UIViewController, CLLocationManagerDelegate, NVActivityIndicatorViewable {

    @IBOutlet var likeBtn: UIButton!
    var locManagerTwoVC:CLLocationManager!
    var LattitudeTwoVC : Double!
    var LongitudeTwoVC : Double!
        //String? = ""
    var lat : CLLocationDegrees!
    var lng : CLLocationDegrees!
    var dataImage : UIImage?
    var fetchImage = [UIImage]()
   var dataSource = [UIImage]()
    var currentUser : String? = ""
    var numberofcards : Int!
    var userAlllocationArray = [NSString]()
    let imageCache = NSCache<NSString, AnyObject>()
    var useritems = [User]()
    //var fetchAllKeys : String? = ""
    var keyArray = [String]()
    var fetchkeyArray = [String]()
    var last_time = true
    var uidsnap : String? = ""
    var userLikeArray = [UIImage]()
    var userLikeArrayIndex : Int!
    var userNopeArray = [NSString]()
    var userLikeCopy = [UIImage]()
    var userLikeCopyIndex : Int!
    
    
    var geoFireRef: DatabaseReference?
    var geoFire: GeoFire?
    var myQuery: GFQuery?
 
    @IBOutlet weak var activatorView: NVActivityIndicatorView!
    
    @IBOutlet weak var kolodaView: KolodaView!

//    fileprivate var dataSource: [UIImage] = {
//        var array: [UIImage] = []
//        for index in 0..<5 {
//            array.append(UIImage(named: "Card_like_\(index + 1)")!)
//        }
//
//        return array
//    }()

    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activatorView.isHidden = true
        currentUser = Auth.auth().currentUser?.uid
       // geoFire?.removeKey("users")
        fetchingLocationTwoVC()
        //fetchUsers()
        //nearbyUsers()
}
    func fetchingLocationTwoVC(){
        locManagerTwoVC = CLLocationManager()
        locManagerTwoVC.desiredAccuracy = kCLLocationAccuracyBest
        locManagerTwoVC.distanceFilter = kCLDistanceFilterNone
        locManagerTwoVC.pausesLocationUpdatesAutomatically = false
        locManagerTwoVC.delegate = self
        locManagerTwoVC.desiredAccuracy = kCLLocationAccuracyBest
        locManagerTwoVC.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            last_time = true
            locManagerTwoVC.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocationTwoVC :CLLocation = locations.last!
       
        print("user TwoVClatitude = \(userLocationTwoVC.coordinate.latitude)")
        print("user Twolongitude = \(userLocationTwoVC.coordinate.longitude)")
        LattitudeTwoVC = userLocationTwoVC.coordinate.latitude
        LongitudeTwoVC = userLocationTwoVC.coordinate.longitude
        if last_time {
            self.last_time = false
            self.locManagerTwoVC.stopUpdatingLocation()
            self.saveUserLocationintoFirebaseDatabase()
            self.nearbyUsers()
        }
       
    }
   
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    func saveUserLocationintoFirebaseDatabase() {
        guard let uid = Auth.auth().currentUser?.uid,
            let lattitudetwovc = LattitudeTwoVC,
            let longitudetwovc = LongitudeTwoVC
            else {
                print("Error")
                //Service.dismissHud(hud, text: "Error", detailText: "Failed to save user.", delay: 3);
                return
        }
        let fileName = UUID().uuidString
            let dictionaryValues = [
                                    "lattitude": lattitudetwovc,
                                    "longitude": longitudetwovc] as Dictionary
            let values = [uid : dictionaryValues]
        Database.database().reference().child("users").child(uid).updateChildValues(["lattitude": lattitudetwovc])
        Database.database().reference().child("users").child(uid).updateChildValues(["longitude": longitudetwovc])
         print("Successfully saved user info into Firebase database")
    }
    
        func nearbyUsers() {
            let geofireRef = Database.database().reference().child("users_locations")
            let geoFire = GeoFire(firebaseRef: geofireRef)
            geoFire.setLocation(CLLocation(latitude: self.LattitudeTwoVC!, longitude: self.LongitudeTwoVC!), forKey: currentUser!)
    
            let center = CLLocation(latitude: self.LattitudeTwoVC!, longitude: self.LongitudeTwoVC!)
            let circleQuery = geoFire.query(at: center, withRadius: 5)
            var allKeys = [AnyHashable: Any]()
            var queryHandle = circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
                print("Key '\(key!)' entered the search area and is at location '\(location!)'")
                let fetchKey : String = key as String
                self.keyArray.insert(fetchKey, at: 0)
                allKeys[key] = location
            })
            circleQuery.observeReady({
                for fetchIndex in 0..<self.keyArray.count{
                if self.currentUser != self.keyArray[fetchIndex] {
                    let fetchkeyArr : String = self.keyArray[fetchIndex]
                    self.fetchkeyArray.insert(fetchkeyArr, at: 0)
                }
            }
            // Create an immutable copy of the keys in the query
            var valueData = allKeys
            print("All keys within a query: \(valueData)")
                let ref = Database.database().reference()
                let usersRef = ref.child("users")
                usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    self.currentUser = Auth.auth().currentUser?.uid
                    for snap in snapshot.children {
                        let userSnap = snap as! DataSnapshot
                        self.uidsnap = userSnap.key //the uid of each user
                        let userDict = userSnap.value as! [String:AnyObject]
                        if self.currentUser != self.uidsnap {
                            for index in 0..<self.fetchkeyArray.count {
                                if self.uidsnap == self.fetchkeyArray[index] {
                                                 print("UID:\(self.uidsnap!) --Name:\(userDict["name"]!) --index \(index):\(self.fetchkeyArray[index])")
                                    //                    let userDict = userSnap.value as! [String:AnyObject] //child data
                                    let name = userDict["name"] as! String
                                    let imgurl = userDict["profileImageUrl"] as! String
                                    let email = userDict["email"] as! String
                                    let lat = userDict["latitude"] as? Double
                                    let long = userDict["longitude"] as? Double
                                    let url = URL(string:imgurl)
                                    print(url)
                                    if let data = try? Data(contentsOf: url!)
                                    {
                                        let image: UIImage = UIImage(data: data)!
                                        self.dataImage = image
                                    }
                                    self.dataSource.insert(self.dataImage!, at: 0)
                                    self.numberofcards = self.dataSource.count
                                }
                            }
                        }
                        else {
                            debugPrint("Current user filtered")
                        }
                    }
                    self.kolodaView.dataSource = self
                    self.kolodaView.delegate = self
                    self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
                })
            })
        }
    
    // MARK: IBActions
    @IBAction func leftButtonTapped() {
        
        kolodaView?.swipe(.left)
        
        let ref = Database.database().reference().child("userwishlists").child("nope").child(currentUser!)
    }
    @IBAction func rightButtonTapped() {
        kolodaView?.swipe(.right)
        if self.userLikeArray.count != 0 {
            self.userLikeCopy.append(userLikeArray[self.userLikeArrayIndex])
        }
        else {
            print("Index is Zero")
        }
        let ref = Database.database().reference().child("userwishlists").child("like").child(currentUser!)
        
        
    }
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
}

// MARK: KolodaViewDelegate

extension TwoVC: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        let position = kolodaView.currentCardIndex
        if position == numberofcards {
            self.activatorView.isHidden = false
            self.activatorView.startAnimating()
        }
        else {
            self.activatorView.isHidden = true
            self.activatorView.stopAnimating()
        }
    }
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        //UIApplication.shared.openURL(URL(string: "https://yalantis.com/")!)
//        let storyboard : UIStoryboard = UIStoryboard (name :"Main", bundle: nil)
//         let newController = storyboard.instantiateViewController(withIdentifier: "ThreeVC") as! ThreeVC
//         //self.present(newController, animated: true, completion: nil)
//         self.navigationController?.pushViewController(newController, animated: true)
    }
}

// MARK: KolodaViewDataSource

extension TwoVC: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
         self.activatorView.isHidden = true
       
            print("INDEX:\(index)")
            nopeFunction(index: index)
      
        return UIImageView(image: dataSource[Int(index)])
    }
    func nopeFunction(index: Int) {
        print("FUNCTION INDEX:\(index)")
        
        self.userLikeArrayIndex = index
        print("UIIMAGE: \(dataSource[index])")
        self.userLikeArray.append(dataSource[index])
    }
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("OverlayView", owner: self, options: nil)?[0] as? OverlayView
    }
}


//    func nearbyUsers() {
//        let geofireRef = Database.database().reference().child("users_locations")
//        let geoFire = GeoFire(firebaseRef: geofireRef)
//        geoFire.setLocation(CLLocation(latitude: self.LattitudeTwoVC!, longitude: self.LongitudeTwoVC!), forKey: currentUser!)
//
//        let center = CLLocation(latitude: self.LattitudeTwoVC!, longitude: self.LongitudeTwoVC!)
//        let circleQuery = geoFire.query(at: center, withRadius: 5)
//        var allKeys = [AnyHashable: Any]()
//        var queryHandle = circleQuery.observe(.keyEntered, with: { (key: String!, location: CLLocation!) in
//            print("Key '\(key!)' entered the search area and is at location '\(location!)'")
//            allKeys[key] = location
//        })
//        circleQuery.observeReady({
//            // Create an immutable copy of the keys in the query
//            var valueData = allKeys
//            print("All keys within a query: \(valueData)")
//
//        })
//    }


//    func fetchUsers() {
//
//        let ref = Database.database().reference()
//        let usersRef = ref.child("users")
//        usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
//            self.currentUser = Auth.auth().currentUser?.uid
//            for snap in snapshot.children {
//                let userSnap = snap as! DataSnapshot
//                let uid = userSnap.key //the uid of each user
//                if self.currentUser != uid {
//                    let userDict = userSnap.value as! [String:AnyObject] //child data
//                    let name = userDict["name"] as! String
//                    let imgurl = userDict["profileImageUrl"] as! String
//                    let email = userDict["email"] as! String
//                    let lat = userDict["latitude"] as? Double
//                    let long = userDict["longitude"] as? Double
//                    let url = URL(string:imgurl)
//                    print(url)
//                    if let data = try? Data(contentsOf: url!)
//                    {
//                        let image: UIImage = UIImage(data: data)!
//                        self.dataImage = image
//                    }
//
//                    self.dataSource.insert(self.dataImage!, at: 0)
//                    self.numberofcards = self.dataSource.count
//                    //let location = userDict["Location"] as! String
//                    //print("key = \(uid) is at location = \(location)")
//
//
//
//                }
//                else {
//                    debugPrint("Current user filtered")
//                }
//            }
//            self.kolodaView.dataSource = self
//            self.kolodaView.delegate = self
//            self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
//        })
//    }
