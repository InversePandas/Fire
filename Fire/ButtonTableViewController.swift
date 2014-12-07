 
//
//  ButtonTableViewController.swift
//  Fire
//
//  Created by Karen Kennedy on 12/6/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

import Foundation

import UIKit
import CoreData
import MessageUI
import CoreLocation
 
class ButtonTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate{
    
    @IBOutlet var buttonTableView: UITableView!
    var locationManager: CLLocationManager!
    var retrievedLocation: Bool = false
    var locData: CLLocationCoordinate2D!
    
    var buttons = [NSManagedObject]()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        // self.navigationItem.rightBarButtonItem = addButton
        
        // load the location manager to start querying for data
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        fetchLog()
    }
    
    func fetchLog() {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        // 2
        let fetchRequest = NSFetchRequest(entityName:"Buttons")
        
        //3
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            buttons = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        buttonTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* func insertNewObject(sender: AnyObject) {
    objects.insertObject(NSDate(), atIndex: 0)
    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
    self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    } */
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            /*if let indexPath = self.tableView.indexPathForSelectedRow() {
            let object = objects[indexPath.row] as NSDate
            (segue.destinationViewController as DetailViewController).detailItem = object
            } */
        }
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
    
    // MARK: - Table View
    
    // returning to view
    override func viewWillAppear(animated: Bool) {
        fetchLog()
    }
    
    // allow deletes
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            //1
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            
            //2 - find contact_entries object user is trying to delete
            let itemToDelete = buttons[indexPath.row]
            
            //3 - delete it from managedContext and sync contact_entries
            managedContext.deleteObject(itemToDelete)
            self.fetchLog()
            
            //4 - tell table view to reload table
            buttonTableView.reloadData()
        }
        
    }
    
    // get button - return button buttonPhoneNumbers as a list and buttonMessage
    func getButton(forRowAtIndexPath indexPath: NSIndexPath) -> (phoneNumbers: [AnyObject], message: String) {
        
        var buttonPhoneNumbers = buttons[indexPath.row].valueForKey("buttonPhoneNumbers") as String
        
        var explodedPhoneNumbers = buttonPhoneNumbers.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).componentsSeparatedByString(",")
        
        var buttonMessage = buttons[indexPath.row].valueForKey("buttonMessage") as String
        
        var phoneNumbers: NSMutableArray = NSMutableArray()
        for number in explodedPhoneNumbers {
            phoneNumbers.addObject(number)
        }
        
        return (phoneNumbers, buttonMessage)
    }
    
    // Queries for a location if available and returns a URL to pin on map
    func getLocationURL() -> String {
        if (retrievedLocation){
            return "https://maps.google.com/maps?saddr=Current+Location&daddr=\(self.locData.latitude),\(self.locData.longitude)"
        }
        else {
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        var button = getButton(forRowAtIndexPath: indexPath)
        
        var messageVC = MFMessageComposeViewController()
        
        messageVC.recipients = button.phoneNumbers
        messageVC.body = button.message + getLocationURL()
        messageVC.messageComposeDelegate = self;
        
        self.presentViewController(messageVC, animated: false, completion: nil)

    }
    
    // UITableViewDataSource
    // tells table how many rows to render
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttons.count
    }
    
    // build a cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Default")

        cell.textLabel.text = buttons[indexPath.row].valueForKey("buttonName") as String?
        cell.detailTextLabel!.text = buttons[indexPath.row].valueForKey("buttonPhoneNumbers") as String?
        
        return cell;
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
    
    // let object = objects[indexPath.row] as NSDate
    // cell.textLabel.text = object.description
    return cell
    }*/
    
    // Needed to implement CLLocationManagerDelegate
    // this function is called ass soon as the Location has been updated
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[AnyObject]) {
        // store the updated location in the class
        self.locData = manager.location.coordinate
        retrievedLocation = true
    }

    
}

