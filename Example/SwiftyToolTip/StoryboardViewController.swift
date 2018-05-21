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
                         "SwiftyToolTip"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 100
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Adding a tool tip to a UIBarButtonItem has to happen in the viewDidAppear
        barButtonItem.addToolTip(description: Description.BarButtonItems.addButton, gesture: .longPress)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
        
        cell.textLabel?.text = tableViewData[indexPath.row]
        // Adding a tooltip to the label in the cell
        cell.textLabel?.addToolTip(description: Description.Label.defaultLabel, gesture: .longPress)
        // Adding a tooltip to the cell itself
        // Make sure to use a different gesture recognizer for elements inside the cell and the cell itself.
        cell.addToolTip(description: "This is a UITableViewCell", gesture: .doubleTap)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

