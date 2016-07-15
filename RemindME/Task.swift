//
//  Task.swift
//  RemindME
//
//  Created by Juan Carlos Ferrel on 3/10/16.
//  Copyright © 2016 Juan Carlos Ferrel. All rights reserved.
//

import Foundation
import CoreData


class Task: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    @NSManaged var dateCompleted: NSDate?
    @NSManaged var detail: String?
    @NSManaged var dueDate: NSDate?
    @NSManaged var finished: NSNumber?
    @NSManaged var points: NSNumber?

}
