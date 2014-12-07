//
//  ContactsViewController.swift
//  Fire
//
//  Created by Eden on 12/6/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

import UIKit
import CoreData

class ContactsViewController: ResponsiveTextFieldViewController, UITextFieldDelegate {
    
    @IBOutlet var txtName:UITextField!
    //@IBOutlet var txtDesc:UITextView!
    @IBOutlet var txtPhone:UITextField!
    var frameView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.frameView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height))
        
        
        // Keyboard stuff.
        var center: NSNotificationCenter = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func saveEntry(contactName: String, contactPhoneNumber: String) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let entity =  NSEntityDescription.entityForName("Contacts",
            inManagedObjectContext:
            managedContext)
        
        let entry = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext: managedContext)
        
        //3
        entry.setValue(contactPhoneNumber, forKey: "contactPhoneNumber")
        entry.setValue(contactName, forKey: "contactName")
        
        
        //4
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        //5
        // contact_entries.append(entry)
    }

    
    // events
    @IBAction func btnAddContact_Click (sender:UIButton){
        // ContactMgr.addContact(txtName.text, phone: txtPhone.text)
        self.saveEntry(txtName.text, contactPhoneNumber: txtPhone.text)
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
    
    // magic keyboard
    
    
}
