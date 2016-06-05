//
//  GenerateViewController.swift
//  Idea Generator
//
//  Created by Cameron Bavier on 5/23/16.
//  Copyright © 2016 Cameron Bavier. All rights reserved.
//

import UIKit
import CoreData

class GenerateViewController: CBViewController {

  @IBOutlet weak var refreshWord: UIButton!
  @IBOutlet weak var displayTypeSegment: UISegmentedControl!
  
  @IBOutlet weak var totalIdeasGenerated: UILabel!
  @IBOutlet weak var wordDisplay: UILabel!
  
  let userPrefs = NSUserDefaults.standardUserDefaults()
  
  var firstWord:String = ""
  var secondWord:String = ""
  var thirdWord:String = ""
  var ideaCount:Int = 0
  
  var isSaved = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    wordDisplay.adjustsFontSizeToFitWidth = true
    wordDisplay.minimumScaleFactor = 0.5
    
    displayTypeSegment.tintColor = deaColor
    
    refreshWord.addTarget(self, action: #selector(refreshWords) , forControlEvents: .TouchUpInside)
    
    // Create Nav Buttons
    let shareBtn = UIBarButtonItem.init(barButtonSystemItem: .Action, target: self, action: #selector(shareWords))
    self.navigationItem.rightBarButtonItem = shareBtn
    
    let favoriteBtn = UIBarButtonItem.init(image: UIImage.init(imageLiteral: "favorite"), style: .Plain, target: self, action: #selector(saveWordsToFavorites))
    self.navigationItem.leftBarButtonItem = favoriteBtn
    
    ideaCount = userPrefs.integerForKey("ideaGenerationCount")
    
    // TODO: Refactor
    do {
      try refreshWords()
    } catch {
      // handle error
    }
  
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func shareWords(sender : AnyObject) {

    let words:String = wordDisplay.text!
      let activityVC = UIActivityViewController(activityItems:[words], applicationActivities: nil)
      
      activityVC.popoverPresentationController?.sourceView = sender.view
      self.presentViewController(activityVC, animated: true, completion: nil)
    
  }
  
  func saveWordsToFavorites() throws {
    if !isSaved {
      isSaved = true
      
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
      newWords.setValue(firstWord, forKey: "firstWord")
      newWords.setValue(secondWord, forKey: "secondWord")
      newWords.setValue(thirdWord, forKey: "thirdWord")
      
      try context.save()
    }
  }
  
  func refreshWords() throws {
    isSaved = false
    ideaCount += 1
    userPrefs.setValue(ideaCount, forKey: "ideaGenerationCount")
    // Set Favorite navigation item to not favorited
    let favoriteBtn = UIBarButtonItem.init(image: UIImage.init(imageLiteral: "favorite"), style: .Plain, target: self, action: #selector(saveWordsToFavorites))
    self.navigationItem.leftBarButtonItem = favoriteBtn
    
    firstWord = getRandomIdea()
    secondWord = getRandomIdea()
    thirdWord = getRandomIdea()
    let words: String = firstWord + " " + secondWord + " " + thirdWord
    
    wordDisplay.fadeTransition(0.15)
    wordDisplay.text = words
    
    let formatter = NSNumberFormatter()
    formatter.numberStyle = .DecimalStyle
    let totalIdeasString = formatter.stringFromNumber(ideaCount)
    totalIdeasGenerated.text =  totalIdeasString
    
    // Store words in core data to use in the history view
    let appDel:AppDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
    let context:NSManagedObjectContext = appDel.managedObjectContext
    
    let newWords = NSEntityDescription.insertNewObjectForEntityForName("WordHistory", inManagedObjectContext: context)
    newWords.setValue(firstWord, forKey: "firstWord")
    newWords.setValue(secondWord, forKey: "secondWord")
    newWords.setValue(thirdWord, forKey: "thirdWord")
    
    try context.save()
  }
  
  func getRandomIdea() -> String {
    
    var randomIdea = ""
    
    switch displayTypeSegment.selectedSegmentIndex {
    case 0:
      randomIdea = getRandomWord()
    case 1:
      randomIdea = getRandomEmoji()
    case 2:
      let randomWordOrEmoji = arc4random_uniform(2)
      if randomWordOrEmoji == 0 {
        randomIdea = getRandomWord()
      } else {
        randomIdea = getRandomEmoji()
      }
    default:
      break
    }
    
    return randomIdea
  }

  func getRandomWord() -> String {
    let path = NSBundle.mainBundle().pathForResource("Words", ofType:"plist")
    let words = NSArray(contentsOfFile:path!)
    
    let randomWordIndex = arc4random_uniform(UInt32(words!.count))
    let randomWord = words![Int(randomWordIndex)] as! String
    
    return randomWord
  }
  
  func getRandomEmoji() -> String {
    let path = NSBundle.mainBundle().pathForResource("Emoji", ofType:"plist")
    let emoji = NSArray(contentsOfFile:path!)
    let randomEmojiIndex = arc4random_uniform(UInt32(emoji!.count))
    let randomEmoji = emoji![Int(randomEmojiIndex)] as! String
    
    return randomEmoji
  }
  
  // MARK: Shake to refresh words
  
  override func canBecomeFirstResponder() -> Bool {
    return true
  }
  
  override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
    if motion == .MotionShake {
      // TODO: Refactor
      do {
        try refreshWords()
      } catch {
        // handle error
      }
    }
  }
}

// Animations
extension UIView {
  func fadeTransition(duration:CFTimeInterval) {
    let animation:CATransition = CATransition()
    animation.timingFunction = CAMediaTimingFunction(name:
      kCAMediaTimingFunctionEaseInEaseOut)
    animation.type = kCATransitionFade
    animation.duration = duration
    self.layer.addAnimation(animation, forKey: kCATransitionFade)
  }
}
