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

class TodayViewController: UIViewController, NCWidgetProviding {
    
    // used to store results from databse
    var contact_entries = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    // Launches the host application for this widget - for reference:
    // http://stackoverflow.com/questions/24019820/today-app-extension-widget-tap-to-open-containing-app
    // Input: sender (no idea what this is?)
    // Output: None
    @IBAction func launchHostApp(sender: AnyObject) {
        
        // NSURL *pjURL = [NSURL URLWithString:@"fire://home"];
        //NSURL pjURL = "fire://home"
        //[self.extensionContext openURL:pjURL completionHandler:nil]
    }
}
