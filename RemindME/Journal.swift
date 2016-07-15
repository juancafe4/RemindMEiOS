//
//  Journal.swift
//  RemindME
//
//  Created by Juan Carlos Ferrel on 3/15/16.
//  Copyright © 2016 Juan Carlos Ferrel. All rights reserved.
//

import Foundation
import CoreData


class Journal: NSManagedObject {
    @NSManaged var dateCreated: NSDate?
    @NSManaged var entry: String?
// Insert code here to add functionality to your managed object subclass

}
