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

// URL for FireServer
let FireURL: NSString = "http://actonadream.org/fireServer.php"

class ViewController: UIViewController, MFMessageComposeViewControllerDelegate,  CLLocationManagerDelegate {
   
    // (Lat,Long) of user is stored here as soon as it is received
    var locationManager: CLLocationManager!
    var firstLocation: Bool = true
    var locData: CLLocationCoordinate2D!
    var notificationSet: Bool = true
    
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
        
        // load the location manager to start querying for location data
        self.launchLocationManager()
        
        // setting a fire date for our notification
        let date_current = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components( .CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitDay | .CalendarUnitHour | .CalendarUnitMinute, fromDate: date_current)
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minutes = components.minute
        
        if notificationSet {
            var dateComp:NSDateComponents = NSDateComponents()
            dateComp.year = year;
            dateComp.month = month;
            dateComp.day = day;
            dateComp.hour = hour;
            dateComp.minute = (minutes + 1) % 60;
            dateComp.timeZone = NSTimeZone.systemTimeZone()
            
            var calender:NSCalendar! = NSCalendar(calendarIdentifier: NSGregorianCalendar)
            // defining our variable date made of our datecomponents shown above
            var date:NSDate! = calender.dateFromComponents(dateComp)
            
            
            var notification:UILocalNotification = UILocalNotification()
            notification.category = "FIRST_CATEGORY"
            notification.alertBody = "Are you doing ok? Swipe left to respond."
            notification.fireDate = date
            notification.repeatInterval = .CalendarUnitDay
            
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            notificationSet = false;
            
        }

    }
    
    // Runs once a memory warning is received
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*  Fire Button calls this function which attempt to send a request to the server (if online) or a
    *   text message to the list of contacts (if not online) for our single fire approach
    *   This function is also called the first time we acquire a valid location for the user (as soon as the
    *   app is launched.
    */
    @IBAction func sendMessage(sender: AnyObject) {
        // attempt contact with server to check internet connectivity
        self.post(["type": "connection"], url: FireURL) { (succeeded: Bool, reply: NSDictionary) -> ()
            in
            // we have internet access, so send the request to the server
            if (succeeded) {
                self.sendMsgToServer(self.constructTxtMsg(), phoneList: self.getContactNumbers())
                
                // TODO - set up the app to automatically update location (ie, send this message again) every X minutes/second/etc (just call this function again after a delay????)
            }
            // ask the user to send the message because we have no internet access
            else {
                self.presentViewController(self.constructMessageView(), animated: true, completion: nil)
                
                // TODO - should alert user that location will NOT be updated automatically
            }
        }
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
        if (self.firstLocation) {
            // don't present the view again unless it is the first location
            self.firstLocation = false
            // self.sendMessage([])
        }
    }

    /*********************** Useful Helper Functions **********************/
    /*
    *   Connects to remote server and sends the messageText to the phone numbers in the phoneList
    *   (or attempts to, the server currently does nothing)
    */
    func sendMsgToServer(messageText: String, phoneList: NSMutableArray) -> Bool {
     
        // sending
        self.post(["type": "message", "text": messageText, "phones": phoneList.componentsJoinedByString(",")], url: FireURL) { (succeeded: Bool, response: NSDictionary) -> () in

            var alert = UIAlertController(title: "Success!", message: "Empty!", preferredStyle: UIAlertControllerStyle.Alert)
            if(succeeded) {
                alert.title = "Success!"
                alert.message = response["msg"] as? String
                // we can also parse the server response here using response["json"] information
            }
            else {
                alert.title = "Failed : ("
                alert.message = response["msg"] as? String
            }
         
            // Move to the UI thread
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                // Show the alert
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
 
        return true
    }
    
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
        
        messageVC.body = self.constructTxtMsg()
        messageVC.recipients = self.getContactNumbers()
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
    func post(params : Dictionary<String, String>, url : String, postCompleted : (succeeded: Bool, response: NSDictionary) -> ()) {
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
                postCompleted(succeeded: false, response: ["msg": "Error in response."])
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    if let success = parseJSON["success"] as? Bool {
                        println("Success: \(success)")
                        postCompleted(succeeded: success, response: ["json" : parseJSON,
                                                                     "msg": "Connection Successful"])
                    }
                    return
                }
                else {
                    // Woa, okay the json object was nil, something went wrong. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                    postCompleted(succeeded: false, response: ["msg": "Error in connection"])
                }
            }
        })
        
        task.resume()
    }
}