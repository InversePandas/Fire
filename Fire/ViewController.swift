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


class ViewController: UIViewController, MFMessageComposeViewControllerDelegate,  CLLocationManagerDelegate {
   
    @IBOutlet var txtTest:UITextField!
    
    // (Lat,Long) of user is stored here as soon as it is received
    var locationManager: CLLocationManager!
    var firstLocation: Bool = true
    var locData: CLLocationCoordinate2D!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // load the location manager to start querying for data
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func sendMessage(sender: AnyObject) {
        self.presentViewController(constructMessageView(), animated: false, completion: nil)
    }
    
    /* 
     * Constructs a message to place into the message sent from this phone
    */
    func constructTxtMsg() -> String {
        var mapURL = "https://maps.google.com/maps?saddr=Current+Location&daddr=\(self.locData.latitude),\(self.locData.longitude)"
        var msg = "Please help! I'm currently in a life threatening situation and you're my number one emergency contact. You can find me here: ";
        return msg + mapURL
    }
    
    // Needed to implement MFMessageComposeViewControllerDelelage
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
    
    // Needed to implement CLLocationManagerDelegate
    
    // this function is called ass soon as the Location has been updated
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        // store the updated location in the class
        self.locData = manager.location.coordinate
        
        // first time we see the location
        if (firstLocation) {
            // don't present the view again unless it is the first location
           firstLocation = true
            self.presentViewController(constructMessageView(), animated: false, completion: nil)
        }
        println("locations = \(locations)")
        
    }

    // Useful Helper Functions
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
    
    func constructMessageView() -> MFMessageComposeViewController {
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = constructTxtMsg()
        messageVC.recipients = getContactNumbers()
        messageVC.messageComposeDelegate = self;
        
        return messageVC
    }
}