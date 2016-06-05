//
//  CBViewController.swift
//  Dea
//
//  Created by Cameron Bavier on 6/4/16.
//  Copyright © 2016 Cameron Bavier. All rights reserved.
//

import UIKit

class CBViewController: UIViewController {

  let deaColor = UIColor.init(red: 0/255, green: 175/255, blue: 255/255, alpha: 1)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Navigation Style
    self.navigationController?.navigationBar.barTintColor = deaColor
    self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    self.navigationController?.navigationBar.translucent = false
  }
}
