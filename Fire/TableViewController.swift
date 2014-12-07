//
//  TableViewController2.swift
//  Fire
//
//  Created by Eden on 12/6/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

import Foundation

import UIKit
import CoreData


class TableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    // Create table view as soon as loads
    @IBOutlet var tblContacts: UITableView!

    var contact_entries = [NSManagedObject]()
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        // self.navigationItem.rightBarButtonItem = addButton
        
        fetchLog()
    }
    
    func fetchLog() {
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"Contacts")
        
        //3
        var error: NSError?
        
        let fetchedResults = managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        // Copying database into contact_entries
        if let results = fetchedResults {
            contact_entries = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            /*if let indexPath = self.tableView.indexPathForSelectedRow() {
            let object = objects[indexPath.row] as NSDate
            (segue.destinationViewController as DetailViewController).detailItem = object
            } */
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
            let itemToDelete = contact_entries[indexPath.row]
            
            //3 - delete it from managedContext and sync contact_entries
            managedContext.deleteObject(itemToDelete)
            self.fetchLog()
            
            //4 - tell table view to reload table
            tblContacts.reloadData()
        }
    }

    // MARK : UITableViewDataSource
    // tells table how many rows to render
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contact_entries.count
    }
    
    // build a cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Default")
        // set title of cell to be the title of contact_entries
        cell.textLabel.text = contact_entries[indexPath.row].valueForKey("contactName") as String?
        cell.detailTextLabel!.text = contact_entries[indexPath.row].valueForKey("contactPhoneNumber") as String?
        return cell;
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // allows us to edit (in particular, delete) cells
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
}

