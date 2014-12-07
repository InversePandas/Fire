//
//  TodayViewController.swift
//  FireWidget
//
//  Created by Karen Kennedy on 12/6/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

import Foundation

import UIKit
import MessageUI
import NotificationCenter
import CoreData
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate{
    
    var locationManager: CLLocationManager!
    var retrievedLocation: Bool = false
    var locData: CLLocationCoordinate2D!
    
    // used to store results from databse
    var contact_entries = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.

        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        completionHandler(NCUpdateResult.NewData)
    }
    
    // MFMessageComposeViewControllerDelegate functionality
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
    
    // Queries for a location if available and returns a URL to pin on map
    func constructTxtMsg() -> String {
        var mapURL = ""
        if (self.locData != nil) {
            mapURL += "You can find me here: https://maps.google.com/maps?saddr=Current+Location&daddr=\(self.locData.latitude),\(self.locData.longitude)"
        }
        var msg = "Please help! I'm currently in a life threatening situation and you're my number one emergency contact.";
        return msg + mapURL
    }
    
    // Needed to implement CLLocationManagerDelegate
    // this function is called ass soon as the Location has been updated
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        // store the updated location in the class
        self.locData = manager.location.coordinate
        retrievedLocation = true
    }
    
    @IBAction func emergencyWidget(sender: AnyObject) {
        
    }
    
    func constructMessageView() -> MFMessageComposeViewController {
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = constructTxtMsg()
        messageVC.recipients = ["1-936-250-0347"]
        messageVC.messageComposeDelegate = self;
        
        return messageVC
    }
    
    // Useful Helper Functions
    /*func getContactNumbers() -> NSMutableArray{
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = UIApplication.sharedApplication().delegate.managedObjectContext!
        
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
*/

    
}
