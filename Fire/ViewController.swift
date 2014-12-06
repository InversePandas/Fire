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


class ViewController: UIViewController, MFMessageComposeViewControllerDelegate {
   
    
    // location stuff
    
    @IBOutlet var label: UILabel!
    var msg = "test"
    
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
                
                self.label.text = loc.description
                self.msg = self.label.text!
                //var fullArr =
                println("self.label.text \(self.label.text)")
                //self.msg = self.label.text!
                //println(loc.description)
            } else if let err = error {
                self.label.text = err.localizedDescription
            }
            
            // destroy the object immediately to save memory
            self.manager = nil
        }
        println(self.label.text)
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
    
    @IBAction func sendMessage(sender: AnyObject) {
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Please help! I'm currently in a life threatening situation and you're my number one emergency contact. Find me at \(msg)";
        messageVC.recipients = ["1-408-561-0868", "1-936-250-0347"]
        messageVC.messageComposeDelegate = self;
        
        self.presentViewController(messageVC, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        println("this coming here?")
        //println(self.string)
        
        //
        // request the current location
        //
        
        // location stuff
        /*manager = OneShotLocationManager()
        manager!.fetchWithCompletion {location, error in
            
            // fetch location or an error
            if let loc = location {
                self.string = loc.description
                println(loc.description)
                println(self.string)
                self.label.text = loc.description
            } else if let err = error {
                self.label.text = err.localizedDescription
            }
            
            // destroy the object immediately to save memory
            self.manager = nil
        }*/
        /*var messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Enter a message";
        messageVC.recipients = ["1-408-561-0868", "1-936-250-0347"]
        messageVC.messageComposeDelegate = self;
        
        self.presentViewController(messageVC, animated: false, completion: nil) */
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}