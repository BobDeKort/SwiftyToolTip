//
//  AddScreenViewController.swift
//  SwiftyToolTip_Example
//
//  Created by Bob De Kort on 5/17/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class AddScreenViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var slider: UISlider!
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        
        // Working on a cleaner way of presenting a one time tooltip
        imageView.removeToolTip()
        imageView.addToolTip(description: "You can also present the tooltips in code when you want it.")
        imageView.showToolTip()
        imageView.removeToolTip()
        imageView.addToolTip(description: Description.ImageView.defaultImageView, gesture: .longPress)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Adding tooltips to UIView elements and subclasses
        imageView.addToolTip(description: Description.ImageView.defaultImageView, gesture: .longPress)
        button.addToolTip(description: Description.Button.defaultButton , gesture: .longPress)
        label.addToolTip(description: Description.Label.defaultLabel, gesture: .longPress, isEnabled: false)
        segmentedControl.addToolTip(description: Description.OtherUIElements.segmentedControl, gesture: .longPress)
        slider.addToolTip(description: Description.OtherUIElements.slider, gesture: .longPress)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Adding tooltip to UIBarButtonItem class and subclasses
        // 1 way to get a reference to the BarButtonItem and add a tool tip
        if let button = self.navigationItem.leftBarButtonItem {
            button.addToolTip(description: Description.BarButtonItems.backButton, gesture: .longPress, isEnabled: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
