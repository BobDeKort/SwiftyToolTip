//
//  ViewController.swift
//  SwiftyToolTip
//
//  Created by BobDeKort on 05/17/2018.
//  Copyright (c) 2018 BobDeKort. All rights reserved.
//

import UIKit
import SwiftyToolTip

class StoryboardViewController: UIViewController {
    
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    
    @IBAction func buttonAction(_ sender: Any) {
        print("Button was pressed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        barButtonItem.addToolTip(description: Description.BarButtonItems.addButton, gesture: .longPress)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

