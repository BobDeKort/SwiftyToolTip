//
//  AddScreenViewController.swift
//  SwiftyToolTip_Example
//
//  Created by Bob De Kort on 5/17/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

class AddScreenViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.addToolTip(description: "You can also use it to add a description to images, add their copyrights or a funny caption.  ", gesture: .longPress)

        let view = backButton.value(forKey: "view") as? UIView
        view?.addToolTip(description: "This is a test", gesture: .longPress)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let button = self.navigationItem.leftBarButtonItem {
            button.addToolTip(description: "You can go back here.", gesture: .longPress, isEnabled: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
