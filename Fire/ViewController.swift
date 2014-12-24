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
   
    // (Lat,Long) of user is stored here as soon as it is received
    var locationManager: CLLocationManager!
    var firstLocation: Bool = true
    var locData: CLLocationCoordinate2D!
    
    // used to store results from databse
    var contact_entries = [NSManagedObject]()
    
    /*********************** UIViewController Functions **********************/
    
    // Runs once the view has appeared
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // Runs once the view has loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // load the location manager to start querying for data
        self.launchLocationManager()

    }
    
    // Runs once a memory warning is received
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Fire Button calls this function
    @IBAction func sendMessage(sender: AnyObject) {
        self.presentViewController(self.constructMessageView(), animated: true, completion: nil)
    }
    
    /*********************** MFMessageComposeViewController functions **********************/
    
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
    
    /*********************** CLLocationManagerDelegate Functions **********************/
    
    /*
    * This function is called as soon as the Location has been updated
    */
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        // store the updated location in the class
        self.locData = manager.location.coordinate
        
        // first time we see the location
        if (firstLocation) {
            // don't present the view again unless it is the first location
           firstLocation = false
            // self.presentViewController(constructMessageView(), animated: false, completion: nil)
        }
    }

    /*********************** Useful Helper Functions **********************/
    
    /*
    *  Connects to the contact database and returns an array of phone
    * numbers to whom the text message should be sent!
    */
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
    
    /*
    * Constructs a message to place into the message sent from this phone
    */
    func constructTxtMsg() -> String {
        var mapURL = ""
        if (self.locData != nil) {
            mapURL += "You can find me here: https://maps.google.com/maps?saddr=Current+Location&daddr=\(self.locData.latitude),\(self.locData.longitude)"
        }
        var msg = "Please help! I'm currently in a life threatening situation and you're my number one emergency contact.";
        return msg + mapURL
    }
    
    /*
    *   Constructs a new message view with the contact numbers
    *   required for this button - currently, this means the default 
    *   button.
    */
    func constructMessageView() -> MFMessageComposeViewController {
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = constructTxtMsg()
        messageVC.recipients = getContactNumbers()
        messageVC.messageComposeDelegate = self;
        
        return messageVC
    }
    
    /*
    *   Starts the location manager aspect of the class so GPS 
    *   coordinates can be stored in self.locationManager
    */
    func launchLocationManager () -> Void {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    /* 
    *   Source: http://jamesonquave.com/blog/making-a-post-request-in-swift/
    *   Sends a post request with params to the specified url
    */
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, msg: String) -> ()) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        
        var err: NSError?
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &err)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            var msg = "No message"
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
                postCompleted(succeeded: false, msg: "Error")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Succes: \(success)")
                        postCompleted(succeeded: success, msg: "Logged in.")
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, msg: "Error")
                }
            }
        })
        
        task.resume()
    }
}