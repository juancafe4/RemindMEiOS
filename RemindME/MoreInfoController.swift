//
//  MoreInfoController.swift
//  RemindME
//
//  Created by Juan Carlos Ferrel on 3/14/16.
//  Copyright © 2016 Juan Carlos Ferrel. All rights reserved.
//

import UIKit
import CoreData
import SwiftDate

class MoreInfoController: UITableViewController{
    var actualDate :String = ""
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var myList :[Task] = []
    let none :String = "No tasks completed "
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest(entityName: "Task")
        do {
            let fetchData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Task]
            for task in fetchData {
                let date = task.dateCompleted!.inRegion(Region(timeZoneName: TimeZoneName.Local)).toShortString(date: true, time: false)
                if task.finished == true && actualDate == date {
                    myList.append(task)
                }
            }
            
        }
        catch let error as NSError{
            print(error)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (myList.count == 0) {
            return 1
        }
        return myList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("more")! as UITableViewCell
        
        
        if myList.count == 0 {
            cell.textLabel?.text = none + "in " + actualDate
        }
        else {
            if let taskDescriprion :UILabel = cell.contentView.viewWithTag(20) as? UILabel{
                taskDescriprion.text = "Task: " + myList[indexPath.row].detail!
            }
    
            if let points :UILabel = cell.contentView.viewWithTag(21) as? UILabel{
                points.text = "Points: "  + String (myList[indexPath.row].points!)
            }
        }
        return cell
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "moreInfo") {
            let  vc :PeekandPopController = segue.destinationViewController as! PeekandPopController
            vc.actualDate = actualDate
        }
    }

}
