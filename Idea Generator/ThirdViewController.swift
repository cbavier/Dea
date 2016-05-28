//
//  ThirdViewController.swift
//  Idea Generator
//
//  Created by Cameron Bavier on 5/23/16.
//  Copyright © 2016 Cameron Bavier. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class ThirdViewController: UIViewController {

  var results :NSArray?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // TODO: Add to base view controller class!
    self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 0/255, green: 175/255, blue: 255/255, alpha: 1)
    self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
    self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
    
//    let clearAllBtn = UIBarButtonItem.init(title: "Clear all", style:UIBarButtonItemStyle.Plain, target: self, action: #selector(clearHistory))
//    self.navigationItem.rightBarButtonItem = clearAllBtn
    
    loadFavorites()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    loadFavorites()
    self.tableView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func loadFavorites() {
    // Retrieve stored words in core data to use
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    let request = NSFetchRequest(entityName: "WordFavorites")
    request.returnsObjectsAsFaults = false
    
    do {
      results = try context.executeFetchRequest(request)
    } catch {}
  }
  
  func deleteFavorite(row : Int) {
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    let favoriteWords = results![row]
    context.deleteObject(favoriteWords as! NSManagedObject)
    
    do {
      try context.save()
      let request = NSFetchRequest(entityName: "WordFavorites")
      results = try context.executeFetchRequest(request)
    } catch {}

  }
  
  // MARK: - Table View Delegate Methods
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results!.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "FavoritesIdentifier")
    
    let data = results![indexPath.row] as! NSManagedObject
    
    let firstWord = data.valueForKey("firstWord") as? String
    let secondWord = data.valueForKey("secondWord") as? String
    let thirdWord = data.valueForKey("thirdWord") as? String
    
    cell.textLabel?.text = firstWord! + " " + secondWord! + " " + thirdWord!
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      // handle delete (by removing the data from your array and updating the tableview)
      deleteFavorite(indexPath.row)
  
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

    }
  }
  
}
