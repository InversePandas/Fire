 
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

class ButtonTableViewController: UITableViewController, MFMessageComposeViewControllerDelegate{
    
    @IBOutlet var tblContacts: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        // self.navigationItem.rightBarButtonItem = addButton
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
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"Buttons")
        
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
        
        tblContacts.reloadData();
    }
    
    // allow deletes
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            ContactMgr.contacts.removeAtIndex(indexPath.row)
            // reload table data
            tblContacts.reloadData()
        }
        
    }
    
    // get contact numbers
    func getContactNumbers() -> NSMutableArray{
        
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
            contact_entries = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
        
        var phoneNumbers: NSMutableArray = NSMutableArray()
        for entry in contact_entries {
            var phone: String = entry.valueForKey("text") as String
            phoneNumbers.addObject(phone)
        }
        
        return phoneNumbers
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let row = indexPath.row
        println(row)
        
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Enter a message";
        messageVC.recipients = getContactNumbers()
        messageVC.messageComposeDelegate = self;
        
        
        self.presentViewController(messageVC, animated: false, completion: nil)
        
        //let vc:BillInfoViewController = BillInfoViewController()
        //let vc = self.storyboard.instantiateViewControllerWithIdentifier("billInfo") as UINavigationController
        
        //self.presentViewController(vc, animated: true, completion: nil)
    }
    
    // UITableViewDataSource
    // tells table how many rows to render
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contact_entries.count
    }
    
    // build a cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Default")
        
        //        cell.textLabel.text = WaveMgr.waves[indexPath.row].name
        //        cell.detailTextLabel!.text = WaveMgr.waves[indexPath.row].desc
        //
        cell.textLabel.text = contact_entries[indexPath.row].valueForKey("buttonName") as String?
        cell.detailTextLabel!.text = contact_entries[indexPath.row].valueForKey("buttonPhoneNumbers") as String?
        
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
    
    
    
}

