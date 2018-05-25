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
    let senderType: SenderTypes
    let isEnabled: Bool
    
    init(description: String,
         gesture: ViewDescriptionGestures = .longPress,
         senderType: SenderTypes,
         isEnabled: Bool = true) {
        self.text = description
        self.gesture = gesture
        self.senderType = senderType
        self.isEnabled = isEnabled
    }
}

// Used for keeping track on which button in the tabbar the tool tip has to display
class TabBarToolTip {
    let tabBar: UITabBar
    var tooltips: [Int: ViewDescription]?
    
    init(tabBar: UITabBar, tooltips: [Int: ViewDescription]?) {
        self.tabBar = tabBar
        self.tooltips = tooltips
    }

    func addToolTipAtIndex(index: Int, viewDescription: ViewDescription) {
        if tooltips != nil {
            self.tooltips![index] = viewDescription
        } else {
            self.tooltips = [index: viewDescription]
        }
    }
    
    func removeToolTipAtIndex(index: Int) -> ViewDescription? {
        if var tooltips = tooltips {
            return tooltips.removeValue(forKey: index)
        } else {
            return nil
        }
    }
    
    func getToolTip(index: Int) -> ViewDescription? {
        if let tooltips = tooltips {
            return tooltips[index]
        } else {
            return nil
        }
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

public enum SenderTypes {
    case UIView
    case UIBarButtonItem
    case UITabBar
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
    
    // Keeps track of the active descriptions on UIViews and holds their configuration
    private var activeToolTipsViews: [UIView: ViewDescription] = [:]
    
    // Keeps track of the active descriptions on UIBarButtonItems and holds their configuration
    private var activeToolTipsBarButtons: [UIBarButtonItem: ViewDescription] = [:]
    
    // Keeps track of the active descriptions on UITabBars and holds their configuration
    private var activeToolTipsTabBar: [UITabBar: TabBarToolTip] = [:]
    
    // Preferences
    var font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    var textColor: UIColor = .black
    var backgroundColor: UIColor? = nil
    
    // SHOW
    // Gets the description text for the given view from activeToolTipsViews if available. And displays the tooltip
    fileprivate func showToolTip(sender: UIView) {
        guard let description = getToolTip(view: sender) else {
            // TODO: Handle error
            print("View has no description")
            return
        }
        
        if description.isEnabled {
            toolTipWindow.show(sender, senderBarButton: nil, description: description.text)
        }
    }
    
    // Gets the description text for the given view from activeToolTipsBarButtons if available. And displays the tooltip
    fileprivate func showToolTip(sender: UIBarButtonItem) {
        guard let description = getToolTip(barbutton: sender) else {
            // TODO: Handle error
            print("View has no description")
            return
        }
        
        if description.isEnabled {
            toolTipWindow.show(nil, senderBarButton: sender, description: description.text)
        }
    }
    
    fileprivate func showToolTip(sender: UIView, tabBar: UITabBar, index: Int) {
        
        guard let toolTipInfo = getToolTip(tabbar: tabBar, index: index) else {
            // TODO: Handle error
            print("View has no description - TabBar")
            return
        }
        
        if toolTipInfo.isEnabled {
            toolTipWindow.show(sender, senderBarButton: nil, description: toolTipInfo.text)
        }
    }
    
    // Add
    // Adds a new description to the activeToolTipsViews dictionary
    fileprivate func addActiveToolTip(view: UIView,
                                      description: String,
                                      gesture: ViewDescriptionGestures,
                                      isEnabled: Bool = true) {
        activeToolTipsViews[view] = ViewDescription(description: description, gesture: gesture, senderType: .UIView)
    }
    
    // Adds a new description to the activeToolTipsBarButtons dictionary
    fileprivate func addActiveToolTip(barButton: UIBarButtonItem,
                                      description: String,
                                      gesture: ViewDescriptionGestures,
                                      isEnabled: Bool = true) {
        activeToolTipsBarButtons[barButton] = ViewDescription(description: description, gesture: gesture, senderType: .UIBarButtonItem)
    }
    
    fileprivate func addActiveToolTipAtIndex(tabBar: UITabBar,
                                      index: Int,
                                      description: String,
                                      gesture: ViewDescriptionGestures,
                                      isEnabled: Bool = true) {
        let description = ViewDescription(description: description, gesture: gesture, senderType: .UITabBar, isEnabled: isEnabled)
        
        if let tooltips = activeToolTipsTabBar[tabBar] {
            tooltips.addToolTipAtIndex(index: index, viewDescription: description)
        } else {
            let tabbarToolTip = TabBarToolTip(tabBar: tabBar, tooltips: [index: description])
            activeToolTipsTabBar[tabBar] = tabbarToolTip
        }
    }
    
    // Remove
    // Removes the description from the given view from the activeToolTipsViews
    fileprivate func removeToolTip(view: UIView) -> ViewDescription? {
        return activeToolTipsViews.removeValue(forKey: view)
    }
    
    // Removes the description from the given barbutton from the activeToolTipsBarButtons
    fileprivate func removeToolTip(barButton: UIBarButtonItem) -> ViewDescription? {
        return activeToolTipsBarButtons.removeValue(forKey: barButton)
    }
    
    // Removes the description from the given tabbarButton from the active tooltips
    fileprivate func removeToolTip(tabbar: UITabBar, index: Int?) -> ViewDescription? {
        // If the index is given removes the tooltip at index
        if let index = index {
            var tabBarToolTips = activeToolTipsTabBar[tabbar]
            return tabBarToolTips?.removeToolTipAtIndex(index: index)
        // Else remove all tooltips of that tabbar
        } else {
            let isRemoved = activeToolTipsTabBar.removeValue(forKey: tabbar)
            guard isRemoved != nil else {
                return nil
            }
            return ViewDescription(description: "Removed all tootips of tabbar", gesture: .longPress, senderType: .UITabBar, isEnabled: true)
        }
    }
    
    // GET 1
    // Returns the configutation for a given view
    fileprivate func getToolTip(view: UIView) -> ViewDescription? {
        return activeToolTipsViews[view]
    }
    
    // Returns the configutation for a given bar button
    fileprivate func getToolTip(barbutton: UIBarButtonItem) -> ViewDescription? {
        return activeToolTipsBarButtons[barbutton]
    }
    
    // Returns the configuration for the given tabbarbutton
    fileprivate func getToolTip(tabbar: UITabBar, index: Int) -> ViewDescription? {
        return activeToolTipsTabBar[tabbar]?.getToolTip(index: index)
    }
    
    // Getter function to get all active descriptions and configuration on views
    public func getToolTipsViews() -> [UIView: ViewDescription] {
        return self.activeToolTipsViews
    }
    
    // GET all
    // Getter function to get all active descriptions and configuration on bar buttons
    public func getToolTipsBarButtons() -> [UIBarButtonItem: ViewDescription] {
        return self.activeToolTipsBarButtons
    }
    
    // Getter function to get all active descriptions and configuration on tabbar buttons
    public func getToolTipsTabbar() -> [UITabBar: TabBarToolTip] {
        return self.activeToolTipsTabBar
    }
    
    // Preferences
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
    func show(_ senderView: UIView?, senderBarButton: UIBarButtonItem?, description: String) {
        guard let toolTipVC = self.rootViewController as? ToolTipViewController else {
            print("Error: Description window rootVC is not of type DescriptionViewController")
            return
        }
        
        self.isHidden = false
        toolTipVC.presentPopOver(senderView, senderBarButton: senderBarButton, description: description)
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
    func presentPopOver(_ senderView: UIView?, senderBarButton: UIBarButtonItem?, description: String) {
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
            
            if let senderView = senderView {
                ppc?.sourceRect = senderView.bounds
                ppc?.sourceView = senderView
            } else if let senderBarButton = senderBarButton {
                ppc?.barButtonItem = senderBarButton
            }
            
            
            
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
    /**
     Adds a tooltip to the ToolTipManager and sets up the gesture to activate the tooltip on the view.
     
     - parameter description: This is the text displayed in the tool tip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     */
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
    
    /*
     Displays the tooltip from self
     */
    @objc public func showToolTip() {
        SwiftyToolTipManager.instance.showToolTip(sender: self)
    }
    
    /*
     Removes the tooltip from the Tooltip manager and removes the gesture from the view.
     
     - parameter isUserInteractive: Allows you to disable the userinteractivity after removing the gesture. Use this to keep buttons clickable and make sure the view does not contain other gesture recognizers. Default = true
     */
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

// MARK: UIBarButtonItem+Extension

extension UIBarButtonItem {
    /*
     Make sure the tooltip is called in ViewDidAppear as the BarButtonItem has to be on screen and loaded.
     */
    public func addToolTip(description: String,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) {
        SwiftyToolTipManager.instance.addActiveToolTip(barButton: self, description: description, gesture: gesture, isEnabled: isEnabled)
        
        let buttonItemView = self.value(forKey: "view") as? UIView
        if let view = buttonItemView {
            view.isUserInteractionEnabled = true
            
            switch gesture {
            case .longPress:
                let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(showToolTip))
                if #available(iOS 11.0, *) {
                    longGesture.name = "ToolTipGesture"
                }
                view.addGestureRecognizer(longGesture)
            case .doubleTap:
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showToolTip))
                if #available(iOS 11.0, *) {
                    tapGesture.name = "ToolTipGesture"
                }
                tapGesture.numberOfTapsRequired = 2
                
                view.addGestureRecognizer(tapGesture)
            }
        } else {
            print("Could not get view from UIBarButtonItem, Check if you added the tooltip in ViewDidAppear.")
        }
    }
    
    @objc func showToolTip() {
        SwiftyToolTipManager.instance.showToolTip(sender: self)
    }
    
    /*
     Removes the tooltip from the Tooltip manager and removes the gesture from the view.
     Make sure the tooltip is called in ViewDidAppear as the BarButtonItem has to be on screen and loaded.
     */
    public func removeToolTip() {
        // Remove description from manager return value if there was a tooltip
        if let toolTipInfo = SwiftyToolTipManager.instance.removeToolTip(barButton: self) {
            // Get view from BarButtonItem
            let buttonItemView = self.value(forKey: "view") as? UIView
            if let view = buttonItemView {
                if let gestures = view.gestureRecognizers {
                    // If there was a tooltip and there is only 1 gesture recognizer we can remove that one.
                    if gestures.count == 1 {
                        view.gestureRecognizers?.remove(at: 0)
                    } else {
                        // Check all gestures on view and remove the DescriptionGesture
                        for (index, gesture) in gestures.enumerated() {
                            // in iOS 11 we can use name to check what gesture recognizer we need to use
                            if #available(iOS 11.0, *) {
                                if gesture.name == "ToolTipGesture" {
                                    view.gestureRecognizers?.remove(at: index)
                                }
                                // Before iOS 11 I check the type/class of the gesture recognizer to see which one to remove. Will include note in the documentation to watch out for duplicate gestures
                            } else {
                                switch toolTipInfo.gesture {
                                case .doubleTap:
                                    if gesture.self === UITapGestureRecognizer.self {
                                        view.gestureRecognizers?.remove(at: index)
                                    }
                                case .longPress:
                                    if gesture.self === UILongPressGestureRecognizer.self {
                                        view.gestureRecognizers?.remove(at: index)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: UITapBar

extension UITabBar {
    public func addToolTip(at index: Int,
                           description: String,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) {

        SwiftyToolTipManager.instance.addActiveToolTipAtIndex(tabBar: self, index: index, description: description, gesture: gesture, isEnabled: isEnabled)

        
        switch gesture {
        case .longPress:
            let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(showToolTip(recognizer:)))
            if #available(iOS 11.0, *) {
                longGesture.name = "ToolTipGesture"
            }
            self.addGestureRecognizer(longGesture)
        case .doubleTap:
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showToolTip(recognizer:)))
            if #available(iOS 11.0, *) {
                tapGesture.name = "ToolTipGesture"
            }
            tapGesture.numberOfTapsRequired = 2
            self.addGestureRecognizer(tapGesture)
        }
    }

    @objc public func showToolTip(recognizer: UIGestureRecognizer) {
        guard recognizer.state == .began else { return }
        guard let tabBar = recognizer.view as? UITabBar else { return }
        guard let tabBarItems = tabBar.items else { return }

        let loc = recognizer.location(in: tabBar)

        for (index, item) in tabBarItems.enumerated() {
            guard let view = item.value(forKey: "view") as? UIView else { continue }
            guard view.frame.contains(loc) else { continue }

            SwiftyToolTipManager.instance.showToolTip(sender: view, tabBar: self, index: index)
            break
        }
    }

//    /*
//     Use this one on UITabbar not the one without the index
//     */
//    @objc public func showToolTip(index: Int) {
//
//        SwiftyToolTipManager.instance.showToolTip(sender: self, index: index)
//    }
}



