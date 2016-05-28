//
//  CBButton.swift
//  Idea Generator
//
//  Created by Cameron Bavier on 5/23/16.
//  Copyright © 2016 Cameron Bavier. All rights reserved.
//

import UIKit

class CBButton: UIButton {

  required init(coder aDecoder:NSCoder) {
    super.init(coder: aDecoder)!
    
    // Set default button background, corners, and text color
    
    self.backgroundColor = UIColor.init(red: 0/255, green: 175/255, blue: 255/255, alpha: 1)
    self.layer.cornerRadius = 22
    self.tintColor = UIColor.whiteColor()
    
//    self.backgroundColor = UIColor.clearColor()
//    self.layer.cornerRadius = 14
//    self.layer.borderWidth = 1
//    self.layer.borderColor = UIColor.init(red: 0/255, green: 175/255, blue: 255/255, alpha: 1).CGColor
//    self.tintColor = UIColor.init(red: 0/255, green: 175/255, blue: 255/255, alpha: 1)
  }
  
  override var highlighted: Bool {
    didSet {
      if (highlighted) {
        highlighted = false
        self.backgroundColor = UIColor.init(red: 0/255, green: 165/255, blue: 245/255, alpha: 1)
//        self.tintColor = UIColor.blackColor()
        UIView.animateWithDuration(0.07 ,
                                   delay: 0.0,
                                   options: .CurveEaseInOut,
                                   animations: {
                                    self.transform = CGAffineTransformMakeScale(0.75, 0.75)
          }, completion: { finished in
            
        })
      }
      else {
        self.backgroundColor = UIColor.init(red: 0/255, green: 175/255, blue: 255/255, alpha: 1)
        self.tintColor = UIColor.whiteColor()
        UIView.animateWithDuration(0.07 ,
                                   delay: 0.0,
                                   options: .CurveEaseInOut,
                                   animations: {
                                    self.transform = CGAffineTransformMakeScale(1, 1)
          }, completion: { finished in
            
        })
      }
      
    }
  }
  
}
