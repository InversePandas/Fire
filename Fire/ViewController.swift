//
//  ViewController.swift
//  Fire
//
//  Created by Karen Kennedy on 12/5/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation
import CoreData
import Foundation


class ViewController: UIViewController, MFMessageComposeViewControllerDelegate {
   
    @IBOutlet var txtTest:UITextField!
    
    // (Lat,Long) of user
    var locData: CLLocationCoordinate2D!
    
    var manager: OneShotLocationManager?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //
        // request the current location
        //
        manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            
            // fetch location or an error
            if let loc = location {
                self.locData = loc.coordinate
                //self.msg = self.label.text!
                //println(loc.description)
            } else if let err = error {
                println(err.localizedDescription)
            }
            
            // destroy the object immediately to save memory
            self.manager = nil
        }
    }
    
    // end location stuff
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        switch (result.value) {
        case MessageComposeResultCancelled.value:
            println("Message was cancelled")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultFailed.value:
            println("Message failed")
            self.dismissViewControllerAnimated(true, completion: nil)
        case MessageComposeResultSent.value:
            println("Message was sent")
            self.dismissViewControllerAnimated(true, completion: nil)
        default:
            break;
        }
    }
    
    /* 
     * Constructs a message
    */
    func constructTxtMsg() -> String {
        var mapURL = "https://maps.google.com/maps?saddr=Current+Location&daddr=\(self.locData.latitude),\(self.locData.longitude)"
        var msg = "Please help! I'm currently in a life threatening situation and you're my number one emergency contact. You can find me here: ";
        return msg + mapURL
    }
    
    
    func getContactNumbers() -> NSMutableArray{
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        // 2
        let fetchRequest = NSFetchRequest(entityName:"Contacts")
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            contact_entries = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        var phoneNumbers: NSMutableArray = NSMutableArray()
        for entry in contact_entries {
            var phone: String = entry.valueForKey("contactPhoneNumber") as String
            phoneNumbers.addObject(phone)
        }
        
        return phoneNumbers
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = constructTxtMsg()
        messageVC.recipients = getContactNumbers()
        messageVC.messageComposeDelegate = self;
        
        self.presentViewController(messageVC, animated: false, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Enter a message";
        messageVC.recipients = getContactNumbers()
        messageVC.messageComposeDelegate = self;
        
        
        // self.presentViewController(messageVC, animated: false, completion: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}