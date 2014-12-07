//
//  AddButtonViewController.swift
//  Fire
//
//  Created by Karen Kennedy on 12/6/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

import Foundation

import UIKit
import CoreData

class AddButtonViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var txtName:UITextField!
    
    @IBOutlet var txtDescription:UITextField!
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
    
    
    func saveEntry(buttonName: String, buttonMessage: String, buttonPhoneNumbers: String) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entityForName("Buttons",
            inManagedObjectContext:
            managedContext)
        
        let entry = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        
        //3
        entry.setValue(buttonMessage, forKey: "buttonMessage")
        entry.setValue(buttonName, forKey: "buttonName")
        entry.setValue(buttonPhoneNumbers, forKey: "buttonPhoneNumbers")
        
        
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
        // TODO: Need to verify user input (in some way....)
        
        // ContactMgr.addContact(txtName.text, phone: txtPhone.text)
        self.saveEntry(txtName.text, buttonMessage: txtDescription.text, buttonPhoneNumbers: txtPhone.text)
        self.view.endEditing(true)
        
        
        // reset field to empty
        txtName.text = ""
        txtPhone.text = ""
        txtDescription.text = ""
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
