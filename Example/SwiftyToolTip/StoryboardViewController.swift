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
    // UIViews
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    
    @IBAction func buttonAction(_ sender: Any) {
        print("Button was pressed")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.addToolTip(description: "This is a label that says label", gesture: .longPress)
        button.addToolTip(description: "This is a button that does some stuff and things", gesture: .longPress)
        segmentedControl.addToolTip(description: "Choose between option one and two so you can do more stuff.", gesture: .longPress)
        progressView.addToolTip(description: "This show the progress of a task such as downloading an video, processing a image filter and many more.", gesture: .doubleTap)
        slider.addToolTip(description: "You can have very long description that could explain the functionality or content of the view presented to the user in great detail and so enlightening the user with the most up to date information just a gesture away. Don't even hesitate and start using SwiftyToolTip to help your users understand your app better", gesture: .longPress)
        
        
//        self.navigationController?.navigationBar.addToolTip(description: "This is the navigation bar", gesture: .longPress)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

