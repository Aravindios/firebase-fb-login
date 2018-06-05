//
//  EditInfoViewController.swift
//  TinderTest
//
//  Created by Apple on 17/05/18.
//  Copyright © 2018 David Seek. All rights reserved.
//

import UIKit

@available(iOS 11.0, *)
class EditInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var window = UIWindow()
        window.makeKeyAndVisible()
        
//        let profileController = ProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        let profileController = ProfileController(collectionViewLayout: UICollectionViewFlowLayout())
        window.rootViewController = UINavigationController(rootViewController: profileController)
    }

    @IBAction func doneBtnActionEditProfile(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
