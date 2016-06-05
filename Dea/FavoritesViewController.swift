//
//  FavoritesViewController.swift
//  Idea Generator
//
//  Created by Cameron Bavier on 5/23/16.
//  Copyright © 2016 Cameron Bavier. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class FavoritesViewController: CBViewController {

  var results :Array<AnyObject> = []
  var selectedRow:Int?
  
  @IBOutlet weak var emtpyFavoritesView: UIView!
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadFavorites()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    loadFavorites()
    emptyTableCheck()
    self.tableView.reloadData()
  }
  
  override func viewDidDisappear(animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.navigationItem.rightBarButtonItem = nil
  }
  
  func emptyTableCheck() {
    self.emtpyFavoritesView.alpha = self.results.count == 0 ? 1.0 : 0.0
  }
  
  func animateEmptyTable() {
    UIView.animateWithDuration(0.5,
                               delay: 0.0,
                               options: .CurveLinear,
                               animations: {
                                self.emtpyFavoritesView.alpha = 1.0
      },
                               completion: nil
    )
  }
  
  func loadFavorites() {
    // Retrieve stored words in core data to use
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    let request = NSFetchRequest(entityName: "WordFavorites")
    request.returnsObjectsAsFaults = false
    
    do {
      results = try context.executeFetchRequest(request).reverse()
    } catch {}
  }
  
  func deleteFavorite(row : Int) {
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    context.deleteObject(results[row] as! NSManagedObject)
    results.removeAtIndex(row)
    
    do {
      try context.save()
      if results.count == 0 {animateEmptyTable()}
    } catch {}

  }
  
  func showShareBtn() {
    let shareBtn = UIBarButtonItem.init(barButtonSystemItem: .Action, target: self, action: #selector(shareWords))
    self.navigationItem.rightBarButtonItem = shareBtn
  }
  
  func shareWords(sender : AnyObject) {
    
    let data = results[selectedRow!]
    
    let firstWord = data.valueForKey("firstWord") as? String
    let secondWord = data.valueForKey("secondWord") as? String
    let thirdWord = data.valueForKey("thirdWord") as? String
    
    let words:String = firstWord! + " " + secondWord! + " " + thirdWord!
    let activityVC = UIActivityViewController(activityItems:[words], applicationActivities: nil)
    
    activityVC.completionWithItemsHandler = { activity, success, items, error in
      // If sucessful we need to hide the share button and deselect the row
      if success {
        let indexPath: NSIndexPath = NSIndexPath(forRow: self.selectedRow!, inSection: 0)
        
        self.navigationItem.rightBarButtonItem = nil
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
      }
      
    }
    
    activityVC.popoverPresentationController?.sourceView = sender.view
    self.presentViewController(activityVC, animated: true, completion: nil)
    
  }
  
  // MARK: - Table View Delegate Methods
  
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell.init(style: .Default, reuseIdentifier: "FavoritesIdentifier")
    
    let data = results[indexPath.row] as! NSManagedObject
    
    let firstWord = data.valueForKey("firstWord") as? String
    let secondWord = data.valueForKey("secondWord") as? String
    let thirdWord = data.valueForKey("thirdWord") as? String
    
    cell.textLabel?.text = firstWord! + " " + secondWord! + " " + thirdWord!
    
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    selectedRow = indexPath.row
//    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    showShareBtn()
  }
  
  func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if (editingStyle == UITableViewCellEditingStyle.Delete) {
      // handle delete (by removing the data from your array and updating the tableview)
      deleteFavorite(indexPath.row)
  
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

    }
  }
  
}
