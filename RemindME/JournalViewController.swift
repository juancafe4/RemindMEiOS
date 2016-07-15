//
//  JournalViewController.swift
//  RemindME
//
//  Created by Juan Carlos Ferrel on 2/16/16.
//  Copyright © 2016 Juan Carlos Ferrel. All rights reserved.
//

import UIKit
import Social
import SwiftDate
import CoreData

class JournalViewController: UIViewController, UITextViewDelegate, UIPickerViewDelegate {
    
    @IBOutlet weak var journalPicker: UIPickerView!
    
    //Core Datastuff...
    var fetchTasks :[Task] = []
    var fetchJournal :[Journal] = []
    var manageObject :NSManagedObject!
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    var pickerVals :[String] = ["Yesterday", "Today", "Tomorrow"]
    var setPciker :String = "Yesterday"
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var journalEntry: UITextView!
    var userEntry = String()
    
    
    //minimum for date picker

    var minimumTask :Double!
    var minimumJournal :Double!
    
    @IBOutlet weak var journalLabel: UILabel!
    
    
    func checkOverlap(postDate : String) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "Journal")
        do {
            let fetchData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Journal]
            for entry in fetchData {
                if   postDate == entry.dateCreated!.inRegion(Region(timeZoneName: TimeZoneName.Local)).toShortString(date: true, time: false)! {
                    manageObject = entry
                    return true
                }
            }
            
        }
        catch let error as NSError{
            print(error)
        }
        return false
    }
    @IBAction func postBtn(sender: AnyObject) {
        
        var date :NSDate!
        if (journalEntry.text != "") {
            if setPciker == "Yesterday" {
                date = NSDate() - 1.days
            }
            if setPciker == "Today" {
                date = NSDate()
            }
            if setPciker == "Tomorrow" {
                date = NSDate() + 1.days
            }
            
            //Check first if a entry alredy exists in a specific date
            
            if (checkOverlap(date.inRegion(Region(timeZoneName: TimeZoneName.Local)).toShortString(date: true, time: false)!) == true ) {
                manageObject.setValue(journalEntry.text, forKey: "entry")
                manageObject.setValue(date, forKey: "dateCreated")
            }
            else {
                let entity = NSEntityDescription.entityForName("Journal", inManagedObjectContext: managedObjectContext)
                
                manageObject = NSManagedObject(entity: entity!,
                    insertIntoManagedObjectContext: managedObjectContext)
                manageObject.setValue(journalEntry.text, forKey: "entry")
                manageObject.setValue(date, forKey: "dateCreated")
            }
            
            do {
                try managedObjectContext.save()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            journalEntry.text = ""
        }
        else {
            
            let alertController = UIAlertController(title: "Error", message: "Enter your task descripton", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
  
    @IBAction func TwitterBtn(sender: AnyObject) {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            
            let tweetShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            tweetShare.setInitialText(self.journalEntry.text)
            self.presentViewController(tweetShare, animated: true, completion: nil)
             postBtn(self.journalEntry.text)
        } else {
            
            let alert = UIAlertController(title: "Account", message: "Please login to a Twitter account.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=TWITTER")!)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    @IBAction func moreInfo(sender: AnyObject) {
        
    }
    @IBAction func FacebookBtn(sender: AnyObject) {
       
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
            let fbShare:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            
            self.presentViewController(fbShare, animated: true, completion: {
                fbShare.setInitialText(self.journalEntry.text)
            })
            postBtn(self.journalEntry.text)
        } else {
            let alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook.", preferredStyle: UIAlertControllerStyle.Alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .Default) { (_) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string:"prefs:root=FACEBOOK")!)
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
            alert.addAction(settingsAction)
            alert.addAction(cancel)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        journalEntry.delegate = self
        
        journalPicker.delegate = self
        //journalPicker.dataSource = self
        
        journalPicker.tag = 200
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        journalEntry.delegate = self
        journalPicker.delegate = self
        datePicker.timeZone = NSTimeZone.localTimeZone()
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.maximumDate = NSDate()
        if fetchData() == true && findMinimalJournalTime() == true {
            if (minimumJournal > minimumTask) {
                datePicker.minimumDate = NSDate(timeIntervalSinceReferenceDate: minimumTask)
            }
            else {
                datePicker.minimumDate = NSDate(timeIntervalSinceReferenceDate: minimumJournal)
            }
            
        }
        else if (fetchData() == true) {
            datePicker.minimumDate = NSDate(timeIntervalSinceReferenceDate: minimumTask)
        }
        else if (findMinimalJournalTime() == true) {
            datePicker.minimumDate = NSDate(timeIntervalSinceReferenceDate: minimumJournal)
        }
        else {
            datePicker.minimumDate = NSDate()
        }
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if range.length + range.location > journalEntry.text.characters.count {
            return false
        }
        
        let newLenght = journalEntry.text.characters.count  + text.characters.count - range.length
        
        if newLenght > 300 {
            let alertView = UIAlertController(title: "Error", message: "Maximum characters allowed 300", preferredStyle: UIAlertControllerStyle.Alert  )
            alertView.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alertView, animated: true, completion: nil)
            return false
        }
        else {

            return true
        }
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int  {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if pickerView.tag == 200 {
            return pickerVals.count
        }
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        if pickerView.tag == 200 {
            return pickerVals[row]
        }
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)  {
        
        if pickerView.tag == 200 {
            setPciker = pickerVals[row]
        }
    }
    
    func findMinimalJournalTime() -> Bool {
        fetchJournal = []
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Journal")
        
        do {
            
            let fetchData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Journal]
            
            if fetchData.count == 0 {
                return false
            }
            for data in fetchData {
                fetchJournal.append(data)
            }
            var times :[Double] = []
            for time in fetchJournal {
                times.append((time.dateCreated?.timeIntervalSinceReferenceDate)!)
            }
            minimumJournal = times.minElement()
        }
        catch let error as NSError{
            print(error)
        }
        
        return true
    }
    func fetchData() -> Bool {
        fetchTasks = []
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        do {
            
            let fetchData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Task]
            
            if fetchData.count == 0 {
                return false
            }
            for data in fetchData {
                fetchTasks.append(data)
            }
            var times :[Double] = []
            for time in fetchTasks {
                times.append((time.dateCompleted?.timeIntervalSinceReferenceDate)!)
            }
            minimumTask = times.minElement()
        }
        catch let error as NSError{
            print(error)
        }
        
        return true
    }


    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "moreInfo" {
            let  vc :MoreInfoController = segue.destinationViewController as! MoreInfoController
            vc.actualDate = datePicker.date.inRegion(Region(timeZoneName: TimeZoneName.Local)).toShortString(date: true, time: false)!
        }
    }


}

