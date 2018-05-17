//
//  SwiftyToolTip.swift
//  FBSnapshotTestCase
//
//  Created by Bob De Kort on 5/17/18.
//

import Foundation
import UIKit

// MARK: Supporting structures

// Contains everything we need to setup an display the tooltip
public struct ViewDescription {
    let text: String
    let gesture: ViewDescriptionGestures
    let isEnabled: Bool
    
    init(description: String, gesture: ViewDescriptionGestures, isEnabled: Bool = true) {
        self.text = description
        self.gesture = gesture
        self.isEnabled = isEnabled
    }
}

/*
 Possible gestures to activate tooltip
 TODO: Think of clean way to just use UIGestureRecognizer
 */
public enum ViewDescriptionGestures {
    case doubleTap
    case longPress
}

/*
 Possible ways of customizing the tooltip
 */
public enum ViewDescriptionPreferences {
    case font
    case fontColor
    case backGroundColor
}

// MARK: SwiftyToolTipManager
/*
 A manager that holds:
 - The presentation window,
 - Preferences for the tooltip appearance
 - All active tooltips
 */
class SwiftyToolTipManager {
    // Singleton
    static let instance = SwiftyToolTipManager()
    
    // Displays the tooltip in a window above all views
    private let toolTipWindow: ToolTipWindow = ToolTipWindow(frame: UIScreen.main.bounds)
    
    // Keeps track of the active descriptions and holds their configuration
    private var activeToolTips: [UIView: ViewDescription] = [:]
    
    // Preferences
    var font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    var textColor: UIColor = .black
    var backgroundColor: UIColor? = nil
    
    // Gets the description text for the given view from activeToolTips if available. And displays the tooltip
    fileprivate func showToolTip(sender: UIView) {
        guard let description = getToolTip(view: sender) else {
            // TODO: Handle error
            print("View has no description")
            return
        }
        
        if description.isEnabled {
            toolTipWindow.show(sender, description: description.text)
        }
    }
    
    // Adds a new description to the activeDescriptions dictionary
    fileprivate func addActiveToolTip(view: UIView,
                                      description: String,
                                      gesture: ViewDescriptionGestures,
                                      isEnabled: Bool = true) {
        activeToolTips[view] = ViewDescription(description: description, gesture: gesture)
    }
    
    // Removes the description from the given view from the active descriptions
    fileprivate func removeToolTip(view: UIView) -> ViewDescription? {
        return activeToolTips.removeValue(forKey: view)
    }
    
    // Returns the configutation for a given view
    fileprivate func getToolTip(view: UIView) -> ViewDescription? {
        return activeToolTips[view]
    }
    
    // Getter function to get all active descriptions and configuration
    public func getToolTips() -> [UIView: ViewDescription] {
        return self.activeToolTips
    }
    
    // Takes in an dictionary of preferences and sets them in the singleton
    func setPreferences(preferences: [ViewDescriptionPreferences: Any]) {
        for preference in preferences {
            switch preference.key {
            case .font:
                SwiftyToolTipManager.instance.font = preference.value as! UIFont
            case .backGroundColor:
                SwiftyToolTipManager.instance.backgroundColor = preference.value as? UIColor
            case .fontColor:
                SwiftyToolTipManager.instance.textColor = preference.value as! UIColor
            }
        }
    }
}


// MARK: Description Window
/*
 A subclass from UIWindow that houses a DescriptionViewController as the root view controller and manages presenting and dismissing the popovers
 */
private class ToolTipWindow: UIWindow {
    
    // Make sure the DescriptionViewController is setup in any init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setToolTipViewControllerAsRoot()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setToolTipViewControllerAsRoot()
    }
    
    private func setToolTipViewControllerAsRoot() {
        let toolTipVC = ToolTipViewController()
        toolTipVC.window = self
        self.rootViewController = toolTipVC
        self.windowLevel = UIWindowLevelAlert + 1
    }
    
    // Asks descriptionViewController to present description popover
    func show(_ sender: UIView, description: String) {
        guard let toolTipVC = self.rootViewController as? ToolTipViewController else {
            print("Error: Description window rootVC is not of type DescriptionViewController")
            return
        }
        
        self.isHidden = false
        toolTipVC.presentPopOver(sender, description: description)
    }
}

// MARK: DescriptionViewController
/*
 Displays the actual popover viewcontroller with the description label
 */
private class ToolTipViewController: UIViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate {
    
    var popOverVC: UIViewController?
    var window: ToolTipWindow!
    var descriptionLabel: UILabel?
    
    // Getters to facilitate accessing the preferences
    var font: UIFont {
        return SwiftyToolTipManager.instance.font
    }
    var textColor: UIColor {
        return SwiftyToolTipManager.instance.textColor
    }
    var backgroundColor: UIColor? {
        return SwiftyToolTipManager.instance.backgroundColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        // Setup dismiss gesture recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    // Handles dismiss tap
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        self.popOverVC?.dismiss(animated: true, completion: {
            self.popOverVC = nil
            self.descriptionLabel = nil
            self.window.isHidden = true
        })
    }
    
    // Sets up the popOverVC and displays it
    func presentPopOver(_ sender: UIView, description: String) {
        // Check if there is another popover presenting
        if popOverVC == nil {
            // Setup popover view
            popOverVC = UIViewController()
            popOverVC?.modalPresentationStyle = .popover
            
            // Setup description label
            descriptionLabel = UILabel()
            descriptionLabel?.backgroundColor = .clear
            descriptionLabel?.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel?.numberOfLines = 0
            descriptionLabel?.font = self.font
            descriptionLabel?.textColor = self.textColor
            descriptionLabel?.text = description
            
            // Add and constrain description label
            popOverVC?.view.addSubview(descriptionLabel!)
            if #available(iOS 9.0, *) {
                popOverVC?.view.addConstraints([
                    descriptionLabel!.topAnchor.constraint(equalTo: popOverVC!.view.topAnchor, constant: 10),
                    descriptionLabel!.leftAnchor.constraint(equalTo: popOverVC!.view.leftAnchor, constant: 10),
                    descriptionLabel!.rightAnchor.constraint(equalTo: popOverVC!.view.rightAnchor, constant: -10),
                    descriptionLabel!.bottomAnchor.constraint(equalTo: popOverVC!.view.bottomAnchor, constant: -10)])
            } else {
                // Fallback on earlier versions
                // TODO: Add new contraint
            }
            
            // Calculate size based on description text size
            popOverVC?.preferredContentSize =
                CGSize(width: descriptionLabel!.intrinsicContentSize.width >
                    self.window.frame.width * 0.75 ?
                        self.window.frame.width * 0.75 :
                    descriptionLabel!.intrinsicContentSize.width + 20,
                       height: description.height(withConstrainedWidth: self.window.frame.width * 0.75,
                                                  font: self.font) + 20)
            
            // Setup PopoverPresentationController
            let ppc = popOverVC?.popoverPresentationController
            ppc?.backgroundColor = self.backgroundColor
            ppc?.permittedArrowDirections = .any
            ppc?.delegate = self
            ppc?.sourceRect = sender.bounds
            ppc?.sourceView = sender
            
            // Present Popover
            present(popOverVC!, animated: true, completion: nil)
        }
    }
    
    // This function allows us to display the popover the same on the iPhone and the iPad
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// Used to calculate the height of the text constrained by a given width
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

// MARK: UIView+Extension
/*
 This extension is what the developer should interact with.
 */
public extension UIView {
    public func addToolTip(description: String,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) {
        SwiftyToolTipManager.instance.addActiveToolTip(view: self, description: description, gesture: gesture, isEnabled: isEnabled)
        
        self.isUserInteractionEnabled = true
        
        switch gesture {
        case .longPress:
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(showToolTip))
            if #available(iOS 11.0, *) {
                longGesture.name = "ToolTipGesture"
            }
            self.addGestureRecognizer(longGesture)
        case .doubleTap:
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showToolTip))
            if #available(iOS 11.0, *) {
                tapGesture.name = "ToolTipGesture"
            }
            tapGesture.numberOfTapsRequired = 2
            self.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc public func showToolTip() {
        SwiftyToolTipManager.instance.showToolTip(sender: self)
    }
    
    public func removeToolTip(isUserInteractive: Bool = true) {
        // Remove description from manager return value if there was a tooltip
        if let toolTipInfo = SwiftyToolTipManager.instance.removeToolTip(view: self) {
            if let gestures = self.gestureRecognizers {
                // If there was a tooltip and there is only 1 gesture recognizer we can remove that one.
                if gestures.count == 1 {
                    self.gestureRecognizers?.remove(at: 0)
                } else {
                    // Check all gestures on view and remove the DescriptionGesture
                    for (index, gesture) in gestures.enumerated() {
                        // in iOS 11 we can use name to check what gesture recognizer we need to use
                        if #available(iOS 11.0, *) {
                            if gesture.name == "ToolTipGesture" {
                                self.gestureRecognizers?.remove(at: index)
                            }
                            // Before iOS 11 I check the type/class of the gesture recognizer to see which one to remove. Will include note in the documentation to watch out for duplicate gestures
                        } else {
                            switch toolTipInfo.gesture {
                            case .doubleTap:
                                if gesture.self === UITapGestureRecognizer.self {
                                    self.gestureRecognizers?.remove(at: index)
                                }
                            case .longPress:
                                if gesture.self === UILongPressGestureRecognizer.self {
                                    self.gestureRecognizers?.remove(at: index)
                                }
                            }
                        }
                        self.isUserInteractionEnabled = isUserInteractive
                    }
                }
            }
        }
    }
}

