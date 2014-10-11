//
//  LoginViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //let testObject = PFObject(className: "TestObject")
        //testObject["foo"] = "bar"
        //testObject.saveInBackground()
    }
    
    @IBAction func onLogin(sender: AnyObject) {
        
        let containerViewController = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
        self.presentViewController(containerViewController, animated: true, completion: { () -> Void in
            NSLog("Successfully pushed the container view")
        })
    }
    
}
