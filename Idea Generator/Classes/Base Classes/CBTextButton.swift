//
//  CBTextButton.swift
//  Idea Generator
//
//  Created by Cameron Bavier on 5/23/16.
//  Copyright © 2016 Cameron Bavier. All rights reserved.
//

import UIKit

class CBTextButton: UIButton {
    
  required init(coder aDecoder:NSCoder) {
    super.init(coder: aDecoder)!
    
    // Set default text color
    self.tintColor = UIColor.init(red: 0/255, green: 175/255, blue: 255/255, alpha: 1)
  }
}
