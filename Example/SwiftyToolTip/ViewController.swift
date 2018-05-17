//
//  ViewController.swift
//  SwiftyToolTip
//
//  Created by BobDeKort on 05/17/2018.
//  Copyright (c) 2018 BobDeKort. All rights reserved.
//

import UIKit
import SwiftyToolTip

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.addToolTip(description: "This is a label that says label", gesture: .longPress, isEnabled: true)
        button.addToolTip(description: "This is a button that executes some stuff and things", gesture: .doubleTap, isEnabled: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

