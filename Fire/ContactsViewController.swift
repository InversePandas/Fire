//
//  ContactsViewController.swift
//  Fire
//
//  Created by Eden on 12/6/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

import UIKit

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
    
    
    // events
    @IBAction func btnAddContact_Click (sender:UIButton){
        ContactMgr.addContact(txtName.text, phone: txtPhone.text)
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
