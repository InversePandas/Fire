//
//  ContactManager.swift
//  Fire
//
//  Created by Eden on 12/6/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

//import Foundation

import UIKit
import CoreData

//used to be journal_entries
var contact_entries = [NSManagedObject]()

//used to be Wave Mgr
var ContactMgr: ContactManager = ContactManager()

// used to be name, desc
struct contact {
    var name = "Un-Named"
    var phone = "Un-Described"
}

class ContactManager: NSObject {
    var contacts = [contact]()
    func addContact (name: String, phone: String) {
        contacts.append(contact(name:name, phone:phone))
    }
}
