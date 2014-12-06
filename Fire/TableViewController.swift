//
//  TableViewController.swift
//  Fire
//
//  Created by Eden on 12/6/14.
//  Copyright (c) 2014 Karen Kennedy. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tblContacts: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // returning to view
    override func viewWillAppear(animated: Bool) {
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        //2
        let fetchRequest = NSFetchRequest(entityName:"Entry")
        
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
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete)
        {
            ContactMgr.contacts.removeAtIndex(indexPath.row)
            // reload table data
            tblContacts.reloadData()
        }
    }
    
    // UITableViewDataSource
    // tells table how many rows to render
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contact_entries.count
    }
    
    // build a cell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Default")
        
        //        cell.textLabel.text = WaveMgr.waves[indexPath.row].name
        //        cell.detailTextLabel!.text = WaveMgr.waves[indexPath.row].desc
        //
        // cell.textLabel.text = contact_entries[indexPath.row].valueForKey("name") as String?
        cell.detailTextLabel!.text = contact_entries[indexPath.row].valueForKey("text") as String?
        
        
        return cell;
    }
    
    
}


