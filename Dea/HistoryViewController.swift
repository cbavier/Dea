//
//  HistoryViewController.swift
//  Idea Generator
//
//  Created by Cameron Bavier on 5/23/16.
//  Copyright © 2016 Cameron Bavier. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class HistoryViewController: CBViewController, UITableViewDelegate, UITableViewDataSource {
  
  var results :Array<AnyObject> = []
  var selectedRow:Int?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadHistory()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    loadHistory()
    self.tableView.reloadData()
    
    if results.count > 0 {
      let clearAllBtn = UIBarButtonItem.init(title: "Clear all", style:UIBarButtonItemStyle.Plain, target: self, action: #selector(showClearHistoryAlert))
      self.navigationItem.rightBarButtonItem = clearAllBtn
    } else {
      self.navigationItem.rightBarButtonItem = nil
    }
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.navigationItem.leftBarButtonItem = nil
  }

  func saveWordsToFavorites() throws {
      
    // Set Favorite navigation item to not favorited
    let indexPath: NSIndexPath = NSIndexPath(forRow: self.selectedRow!, inSection: 0)
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    // Set Favorite navigation item to favorited
    let favoriteBtn = UIBarButtonItem.init(image: UIImage.init(imageLiteral: "favorited"), style: .Plain, target: self, action: #selector(saveWordsToFavorites))
    self.navigationItem.leftBarButtonItem = favoriteBtn
    
    let icon = UIImage(named: "favorited")
    let iconSize = CGRect(origin: CGPointZero, size: icon!.size)
    let iconButton = UIButton(frame: iconSize)
    iconButton.setBackgroundImage(icon, forState: .Normal)
    iconButton.setBackgroundImage(icon, forState: .Highlighted)
    favoriteBtn.customView = iconButton
    favoriteBtn.customView!.transform = CGAffineTransformMakeScale(0.6, 0.6)
    
    UIView.animateWithDuration(1.0,
                               delay: 0.0,
                               usingSpringWithDamping: 0.3,
                               initialSpringVelocity: 10,
                               options: .CurveLinear,
                               animations: {
                                favoriteBtn.customView!.transform = CGAffineTransformIdentity
      },
                               completion: nil
    )
    
    // Store words in core data to use in the favorites view
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    let newWords = NSEntityDescription.insertNewObjectForEntityForName("WordFavorites", inManagedObjectContext: context)
    let data = results[selectedRow!]
    
    let firstWord = data.valueForKey("firstWord") as? String
    let secondWord = data.valueForKey("secondWord") as? String
    let thirdWord = data.valueForKey("thirdWord") as? String
    newWords.setValue(firstWord, forKey: "firstWord")
    newWords.setValue(secondWord, forKey: "secondWord")
    newWords.setValue(thirdWord, forKey: "thirdWord")
    
    try context.save()
  }
  
  func loadHistory() {
    // Retrieve stored words in core data to use
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    let request = NSFetchRequest(entityName: "WordHistory")
    request.returnsObjectsAsFaults = false
    
    do {
      results = try context.executeFetchRequest(request).reverse()
    } catch {}
  }
  
  func clearHistory() {
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    // Send Clear History Event
    FIRAnalytics.logEventWithName("clear_history", parameters: [
      "word_count":results.count
      ])
    
    for bas: AnyObject in results {
      context.deleteObject(bas as! NSManagedObject)
    }
    
    do {
      try context.save()
    } catch {}
    
    results = []
    self.tableView.reloadData()
    self.navigationItem.rightBarButtonItem = nil
  }
  
  func showClearHistoryAlert() {
    let actionSheetController: UIAlertController = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .ActionSheet)
    
    let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { (UIAlertAction) in
      // Dismiss
    }
    actionSheetController.addAction(cancelAction)
    
    let confirmAction: UIAlertAction = UIAlertAction(title: "Clear all", style: .Destructive) { (UIAlertAction) in
      self.clearHistory()
    }
    actionSheetController.addAction(confirmAction)
    
    self.presentViewController(actionSheetController, animated: true, completion: nil)
  }
  
  func showFavoriteBtn() {
    let favoriteBtn = UIBarButtonItem.init(image: UIImage.init(imageLiteral: "favorite"), style: .Plain, target: self, action: #selector(saveWordsToFavorites))
    self.navigationItem.leftBarButtonItem = favoriteBtn
  }
  
  // Check if favorite already exists
  func checkForFavorite(row: Int) {
    
    let historyIdea = results[row]
    
    // Retrieve stored favorited words
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    let request = NSFetchRequest(entityName: "WordFavorites")
    request.returnsObjectsAsFaults = false
    
    var favorites: Array<AnyObject> = []
    do {
      favorites = try context.executeFetchRequest(request)
    } catch {}
    
    for favorite in favorites {
      let firstWordFav = favorite.valueForKey("firstWord") as? String
      let secondWordFav = favorite.valueForKey("secondWord") as? String
      let thirdWordFav = favorite.valueForKey("thirdWord") as? String
      
      let firstWord = historyIdea.valueForKey("firstWord") as? String
      let secondWord = historyIdea.valueForKey("secondWord") as? String
      let thirdWord = historyIdea.valueForKey("thirdWord") as? String
      
      if firstWordFav == firstWord && secondWordFav == secondWord && thirdWordFav == thirdWord {
        let favoriteBtn = UIBarButtonItem.init(image: UIImage.init(imageLiteral: "favorited"), style: .Plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = favoriteBtn
        
        let icon = UIImage(named: "favorited")
        let iconSize = CGRect(origin: CGPointZero, size: icon!.size)
        let iconButton = UIButton(frame: iconSize)
        iconButton.setBackgroundImage(icon, forState: .Normal)
        iconButton.setBackgroundImage(icon, forState: .Highlighted)
        favoriteBtn.customView = iconButton
        
        return
      }
    }
    showFavoriteBtn()
  }
  
  // MARK: - Table View Delegate Methods

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "HistoryIdentifier")
    
    let data = results[indexPath.row] as! NSManagedObject
    
    let firstWord = data.valueForKey("firstWord") as? String
    let secondWord = data.valueForKey("secondWord") as? String
    let thirdWord = data.valueForKey("thirdWord") as? String
    
    cell.textLabel?.text = firstWord! + " " + secondWord! + " " + thirdWord!
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedRow = indexPath.row
    //showFavoriteBtn()
    //self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    checkForFavorite(indexPath.row)
  }
}

