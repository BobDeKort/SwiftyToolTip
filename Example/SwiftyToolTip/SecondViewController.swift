//
//  SecondViewController.swift
//  SwiftyToolTip_Example
//
//  Created by Bob De Kort on 6/5/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit
import SwiftyToolTip

class SecondViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.addToolTip(description: Description.Label.justMore)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
