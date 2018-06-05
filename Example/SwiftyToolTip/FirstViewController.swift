//
//  ViewController.swift
//  SwiftyToolTip
//
//  Created by BobDeKort on 05/17/2018.
//  Copyright (c) 2018 BobDeKort. All rights reserved.
//

import UIKit
import SwiftyToolTip

class StoryboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    
    let tableViewData = ["These cells",
                         "are just an example",
                         "on how you might use",
                         "SwiftyToolTip",
                         "Double tap the cell",
                         "Or long press on the label",
                         "and image"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
        
        // Here we add tool tips to individual tabbarbuttons
        // Double tap does not work on tabbarButtons (Not sure why, yet!)
        tabBarController?.tabBar.addToolTip(at: 0, description: Description.tabBar.storyboardViewController, gesture: .longPress, isEnabled: true)
        tabBarController?.tabBar.addToolTip(at: 1, description: Description.tabBar.otherViewcontroller, gesture: .longPress, isEnabled: true)
        
        // This is a tooltip for the whole tabbar, added using the UIView implementation of Swifty tool tip
        tabBarController?.tabBar.addToolTip(description: Description.tabBar.tabbar, gesture: .doubleTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Adding a tool tip to a UIBarButtonItem has to happen in the viewDidAppear
        barButtonItem.addToolTip(description: "Add a new item to some list")
        barButtonItem.addToolTip(description: Description.BarButtonItems.addButton, gesture: .longPress)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
        
        cell.imageView?.image = #imageLiteral(resourceName: "IMG_0354 copy")
        cell.imageView?.contentMode = .scaleAspectFit
        
        cell.imageView?.addToolTip(description: "This is an ImageView", gesture: .longPress, isEnabled: true)
        
        cell.textLabel?.text = tableViewData[indexPath.row]
        // Adding a tooltip to the label in the cell
        cell.textLabel?.addToolTip(description: Description.Label.defaultLabel, gesture: .longPress)
        // Adding a tooltip to the cell itself
        // Make sure to use a different gesture recognizer for elements inside the cell and the cell itself.
        cell.addToolTip(description: "This is a UITableViewCell", gesture: .doubleTap)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

