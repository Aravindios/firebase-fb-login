//
//  TinderImageView.swift
//  TwitterProfileLBTA
//
//  Created by Brian Voong on 2/26/18.
//  Copyright © 2018 Brian Voong. All rights reserved.
//

import UIKit

class TinderImageView: UIImageView {
    
    let imageIndexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "SSS"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        
        label.layer.shadowOpacity = 0.7
        label.layer.shadowOffset = .zero
        
        
        return label
    }()
    
    @IBInspectable
    var imageIndex: NSNumber! {
        didSet {
            print(imageIndex)
            let imageName = "daenerys\(imageIndex.stringValue)"
            self.image = UIImage(named: imageName)
            
            layer.cornerRadius = 5
            imageIndexLabel.text = imageIndex.stringValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        addSubview(imageIndexLabel)
        imageIndexLabel.translatesAutoresizingMaskIntoConstraints = false
        imageIndexLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        imageIndexLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8).isActive = true
    }
}
