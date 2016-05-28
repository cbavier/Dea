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

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var results :NSArray?
  var selectedRow:Int?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: Add to base view controller class!
    self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0/255, green: 175/255, blue: 255/255, alpha: 1)
    self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    
    let clearAllBtn = UIBarButtonItem.init(title: "Clear all", style:UIBarButtonItemStyle.Plain, target: self, action: #selector(clearHistory))
    self.navigationItem.rightBarButtonItem = clearAllBtn
    
    loadHistory()
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    loadHistory()
    self.tableView.reloadData()
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.navigationItem.leftBarButtonItem = nil
  }

  func saveWordsToFavorites() throws {
      
    // Set Favorite navigation item to not favorited
    let indexPath: NSIndexPath = NSIndexPath(forRow: self.selectedRow!, inSection: 0)
    self.navigationItem.leftBarButtonItem = nil
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    // Store words in core data to use in the favorites view
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    let newWords = NSEntityDescription.insertNewObjectForEntityForName("WordFavorites", inManagedObjectContext: context)
    let data = results![selectedRow!]
    
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
      "word_count":results!.count
      ])
    
    for bas: AnyObject in results! {
      context.deleteObject(bas as! NSManagedObject)
    }
    
    do {
      try context.save()
    } catch {}
    
    results = []
    self.tableView.reloadData()
  }
  
  func showFavoriteBtn() {
    let favoriteBtn = UIBarButtonItem.init(image: UIImage.init(imageLiteral: "favorite"), style: .Plain, target: self, action: #selector(saveWordsToFavorites))
    self.navigationItem.leftBarButtonItem = favoriteBtn
  }
  
  // MARK: - Table View Delegate Methods

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "HistoryIdentifier")
    
    let data = results![indexPath.row] as! NSManagedObject
    
    let firstWord = data.valueForKey("firstWord") as? String
    let secondWord = data.valueForKey("secondWord") as? String
    let thirdWord = data.valueForKey("thirdWord") as? String
    
    cell.textLabel?.text = firstWord! + " " + secondWord! + " " + thirdWord!
    
    return cell
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results!.count
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedRow = indexPath.row
    showFavoriteBtn()
    //self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
}

