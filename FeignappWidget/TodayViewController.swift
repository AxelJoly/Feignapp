//
//  TodayViewController.swift
//  FeignappWidget
//
//  Created by Joly Axel on 28/02/2018.
//  Copyright © 2018 Axel Joly. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var label: UILabel!
    var counter = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = "\(counter)"
        // Do any additional setup after loading the view from its nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func test(_ sender: Any) {
       self.counter = self.counter + 1
       label.text = "\(counter)"
    }
    
    // Url request to SNCF api and set data in TravelStruct object.
 
}
