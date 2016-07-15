//
//  PeekandPopController.swift
//  RemindME
//
//  Created by Juan Carlos Ferrel on 3/16/16.
//  Copyright © 2016 Juan Carlos Ferrel. All rights reserved.
//

import UIKit
import CoreData
import SwiftDate

class PeekandPopController: UIViewController {
    var actualDate :String = ""
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    @IBOutlet weak var journalBody: UILabel!
    @IBOutlet weak var journalTtitle: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        journalTtitle.text = "Journal Entry of " + actualDate
        
        if chenckEntry() == false {
            journalBody.text = "No Journal at " + actualDate
        }
    }

    func chenckEntry() -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "Journal")
        do {
            let fetchData = try managedObjectContext.executeFetchRequest(fetchRequest) as! [Journal]
            for entry in fetchData {
                print(entry.entry)
                let date = entry.dateCreated!.inRegion(Region(timeZoneName: TimeZoneName.Local)).toShortString(date: true, time: false)
                if  date == actualDate {
                    journalBody.text = entry.entry
                    return true
                }
            }
        }
        catch let error as NSError{
            print(error)
        }
        
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
