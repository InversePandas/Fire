//
//  ContactsViewController.swift
//  Fire
//
//  Created by Eden on 12/6/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

import UIKit
import CoreData

class ContactsViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtName:UITextField!
    //@IBOutlet var txtDesc:UITextView!
    @IBOutlet var txtPhone:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func saveEntry(name: String, text: String) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entityForName("Entry",
            inManagedObjectContext:
            managedContext)
        
        let entry = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //3
        entry.setValue(text, forKey: "text")
        entry.setValue(name, forKey: "name")
        
        
        
        //4
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        //5
        //println("here")
        contact_entries.append(entry)
    }

    
    // events
    @IBAction func btnAddContact_Click (sender:UIButton){
        // ContactMgr.addContact(txtName.text, phone: txtPhone.text)
        self.saveEntry(txtName.text, text: txtPhone.text)
        self.view.endEditing(true)
        
        
        // reset field to empty
        txtName.text = ""
        txtPhone.text = ""
    }
    
    // iOS Touch function
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.view.endEditing(true);
    }
    
    // what happens if returns
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        // keyboard go away
        textField.resignFirstResponder();
        return true;
    }
    
}
