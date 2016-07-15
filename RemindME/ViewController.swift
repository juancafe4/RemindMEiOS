//
//  ViewController.swift
//  RemindME
//
//  Created by Juan Carlos Ferrel on 2/12/16.
//  Copyright © 2016 Juan Carlos Ferrel. All rights reserved.
//

import UIKit
import CoreData
import SwiftDate

class tableViewController: UITableViewController, ModalControllerDelegate{
    
    var sliderHours = UISlider()
    var labelSlider = UILabel()
    var labelHours = UILabel()
    
    //Current Local Time
    let current = Region(timeZoneName: TimeZoneName.Local)
    //Array of Tasks
    var fetchTasks = [Task]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //Refresh content
        let rc = UIRefreshControl()
        rc.addTarget(self, action: "refresh", forControlEvents: .ValueChanged)
        self.refreshControl = rc
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: Selector("addItem"))
    }
    
    func refresh() {
        fetchTasks = []

        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Task")
    
        do {
            let fetchData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Task]
            for task in fetchData {
                if task.finished == false && NSDate() <= task.dueDate {
                    fetchTasks.append(task)
                }
            }
            self.tableView.reloadData()
        }
        catch let error as NSError{
            print(error)
        }
        
        refreshControl?.endRefreshing()
    }
    
    func addItem() {
        self.performSegueWithIdentifier("Modal", sender: nil)
    }
    
    func saveData(data :String, points :Int, dueDate :NSDate) {

        //Settig up core data
        let appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
        let manageControl = appDelagate.managedObjectContext
        let entity = NSEntityDescription.entityForName("Task", inManagedObjectContext: manageControl)
        
        let item = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: manageControl)
        
        item.setValue(false, forKey: "finished")
        item.setValue(data, forKey: "detail")
        item.setValue(points, forKey: "points")
        item.setValue(NSDate(), forKey: "dateCompleted")
        item.setValue(dueDate, forKey: "dueDate")
        
        do {
            try manageControl.save()
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        fetchTasks = []
        super.viewWillAppear(animated)
        let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        // Create a new fetch request using the LogItem entity
        let fetchRequest = NSFetchRequest(entityName: "Task")
        
        do {
            let fetchData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Task]
            for task in fetchData {
                if task.finished == false && NSDate() <= task.dueDate {
                    fetchTasks.append(task)
                }
                if task.finished == false && NSDate() > task.dueDate {
                    managedObjectContext.deleteObject(task)
                }
            }
            try managedObjectContext.save()
            self.tableView.reloadData()
        }
        catch let error as NSError{
            print(error)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fetchTasks.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Tasks")! as UITableViewCell
    
        if let taskDescriprion :UILabel = cell.contentView.viewWithTag(10) as? UILabel{
            taskDescriprion.text = "Task: " + fetchTasks[indexPath.row].detail!
        }
        
        if let points :UILabel = cell.contentView.viewWithTag(101) as? UILabel{
            points.text = "Points: "  + String (fetchTasks[indexPath.row].points!)
        }
        
        if let time = cell.contentView.viewWithTag(102) as? UILabel {
            time.text = "Due in: " + (fetchTasks[indexPath.row].dueDate?.inRegion(current).toShortString(date: true, time: true))!
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let markList = UITableViewRowAction(style: .Default, title: "Mark Task", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            
            /*do {
                try managedObjectContext.save()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }*/

            // Create a new fetch request using the LogItem entity
            let fetchRequest = NSFetchRequest(entityName: "Task")
            var manageObject :NSManagedObject!
            do {
                let fetchData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Task]
                for task in fetchData {
                    if task.detail == self.fetchTasks[indexPath.row].detail {
                        manageObject = task
                    }
                }
                
            }
            catch let error as NSError{
                print(error)
            }
            
            //Change Data 
            manageObject.setValue(1, forKey: "finished")
            manageObject.setValue(NSDate(), forKey: "dateCompleted")
            do {
                try managedObjectContext.save()
                
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }
            self.fetchTasks.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        })
        markList.backgroundColor = UIColor.greenColor()

        return [markList]
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "Modal"){
            let vc :ModalController = segue.destinationViewController as! ModalController
            vc.delegate = self
            vc.modalPresentationStyle = UIModalPresentationStyle.FormSheet
            vc.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            //This will be the size you want
            vc.preferredContentSize = CGSizeMake(350, 450)
        }
        
        
    }
    
    
}

