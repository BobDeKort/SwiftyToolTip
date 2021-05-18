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
public class TooltipInfo {
    public var text: String? = nil                        // Text displayed in Tooltip
    public var font: UIFont! = nil
    public var textColor: UIColor? = nil
    public var attributedText: NSAttributedString? = nil
    public var textAlignment: NSTextAlignment = .natural;
    public var backgroundColor : UIColor?;
    public var paddings: UIEdgeInsets = .init(top: 10, left: 10, bottom: 10, right: 10);
    let gesture: ViewDescriptionGestures    // Gesture used to active Tooltip
    let senderType: SenderTypes             // Used to identify how to display the toolTip
    public var isEnabled: Bool                     // Will prevent the displaying of the Tooltip
    
    init(text: String,
         font: UIFont? = nil,
         textColor: UIColor? = nil,
         backgroundColor: UIColor? = nil,
         gesture: ViewDescriptionGestures = .longPress,
         senderType: SenderTypes,
         isEnabled: Bool = true) {
        self.text = text
        self.font = font;
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.gesture = gesture
        self.senderType = senderType
        self.isEnabled = isEnabled
    }
    
    init(attributedText: NSAttributedString,
         backgroundColor: UIColor? = nil,
         gesture: ViewDescriptionGestures = .longPress,
         senderType: SenderTypes,
         isEnabled: Bool = true) {
        self.attributedText = attributedText
        self.backgroundColor = backgroundColor
        self.gesture = gesture
        self.senderType = senderType
        self.isEnabled = isEnabled
    }
    
    public func setPaddings(_ value: UIEdgeInsets) -> Self{
        self.paddings = value;
        return self;
    }
    
    public func setPaddings(left: CGFloat? = nil, top: CGFloat? = nil, right: CGFloat? = nil, bottom: CGFloat?) -> Self{
        if let left = left{
            self.paddings.left = left;
        }
        
        if let top = top{
            self.paddings.top = top;
        }
        
        if let right = right{
            self.paddings.right = right;
        }
        
        if let bottom = bottom{
            self.paddings.bottom = bottom;
        }
        
        return self;
    }
    
    public func setTextAlignment(_ value: NSTextAlignment) -> Self{
        self.textAlignment = value;
        return self;
    }
}

// Structure to keep track of what index of the tabbar has a Tooltip and the ViewDescription of the Tooltip
class TabBarToolTip {
    let tabBar: UITabBar
    var tooltips: [Int: TooltipInfo]?       // Map index with a ViewDesccript
    
    init(tabBar: UITabBar, tooltips: [Int: TooltipInfo]?) {
        self.tabBar = tabBar
        self.tooltips = tooltips
    }

    
    // Adds a Tooltip to the TabBarButton at the given index
    func addToolTipAtIndex(index: Int, info: TooltipInfo) {
        if tooltips != nil {
            self.tooltips![index] = info
        } else {
            self.tooltips = [index: info]
        }
    }
    
    // Removes the Tooltip on the given index
    func removeToolTipAtIndex(index: Int) -> TooltipInfo? {
        if var tooltips = tooltips {
            return tooltips.removeValue(forKey: index)
        } else {
            return nil
        }
    }
    
    // Get the tooltip from a given index
    func getToolTip(index: Int) -> TooltipInfo? {
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

// Used to indentify how to display the Tooltip
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
    private var activeToolTipsViews: [UIView: TooltipInfo] = [:]
    
    // Keeps track of the active descriptions on UIBarButtonItems and holds their configuration
    private var activeToolTipsBarButtons: [UIBarButtonItem: TooltipInfo] = [:]
    
    // Keeps track of the active descriptions on UITabBars and holds their configuration
    private var activeToolTipsTabBar: [UITabBar: TabBarToolTip] = [:]
    
    // Preferences
    var font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    var textColor: UIColor = .black
    var backgroundColor: UIColor? = nil
    
    // SHOW
    // Gets the description text for the given view from activeToolTipsViews if available. And displays the tooltip
    func showToolTip(sender: UIView) {
        guard let info = getToolTip(view: sender) else {
            // TODO: Handle error
            print("View has no description")
            return
        }
        
        if info.isEnabled {
            toolTipWindow.show(sender, senderBarButton: nil, info: info)
        }
    }
    
    // Gets the description text for the given view from activeToolTipsBarButtons if available. And displays the tooltip
    func showToolTip(sender: UIBarButtonItem) {
        guard let info = getToolTip(barbutton: sender) else {
            // TODO: Handle error
            print("View has no description")
            return
        }
        
        if info.isEnabled {
            toolTipWindow.show(nil, senderBarButton: sender, info: info)
        }
    }
    
    func showToolTip(sender: UIView, tabBar: UITabBar, index: Int) {
        
        guard let info = getToolTip(tabbar: tabBar, index: index) else {
            // TODO: Handle error
            print("View has no description - TabBar")
            return
        }
        
        if info.isEnabled {
            toolTipWindow.show(sender, senderBarButton: nil, info: info);
        }
    }
    
    // Add
    // Adds a new description to the activeToolTipsViews dictionary
    fileprivate func addActiveToolTip(view: UIView,
                                      text: String,
                                      backgroundColor: UIColor? = nil,
                                      gesture: ViewDescriptionGestures,
                                      isEnabled: Bool = true) -> TooltipInfo{
        let value = TooltipInfo(text: text, backgroundColor: backgroundColor, gesture: gesture, senderType: .UIView);
        activeToolTipsViews[view] = value;
        
        return value;
    }
    
    fileprivate func addActiveToolTip(view: UIView,
                                      attributedText: NSAttributedString,
                                      backgroundColor: UIColor? = nil,
                                      gesture: ViewDescriptionGestures,
                                      isEnabled: Bool = true) -> TooltipInfo{
        let value = TooltipInfo(attributedText: attributedText, backgroundColor: backgroundColor, gesture: gesture, senderType: .UIView);
        activeToolTipsViews[view] = value;
        
        return value;
    }
    
    // Adds a new description to the activeToolTipsBarButtons dictionary
    fileprivate func addActiveToolTip(barButton: UIBarButtonItem,
                                      text: String,
                                      gesture: ViewDescriptionGestures,
                                      backgroundColor: UIColor? = nil,
                                      isEnabled: Bool = true) -> TooltipInfo{
        let value = TooltipInfo(text: text, backgroundColor: backgroundColor, gesture: gesture, senderType: .UIBarButtonItem)
        activeToolTipsBarButtons[barButton] = value;
        
        return value;
    }
    
    fileprivate func addActiveToolTip(barButton: UIBarButtonItem,
                                      attributedText: NSAttributedString,
                                      backgroundColor: UIColor? = nil,
                                      gesture: ViewDescriptionGestures,
                                      isEnabled: Bool = true) -> TooltipInfo{
        let value = TooltipInfo(attributedText: attributedText, backgroundColor: backgroundColor, gesture: gesture, senderType: .UIBarButtonItem);
        activeToolTipsBarButtons[barButton] = value;
        
        return value;
    }
    
    fileprivate func addActiveToolTipAtIndex(tabBar: UITabBar,
                                      index: Int,
                                      text: String,
                                      backgroundColor: UIColor? = nil,
                                      gesture: ViewDescriptionGestures,
                                      isEnabled: Bool = true) -> TooltipInfo{
        let value = TooltipInfo.init(text: text, backgroundColor: backgroundColor, gesture: gesture, senderType: .UITabBar);
        
        if let tooltips = activeToolTipsTabBar[tabBar] {
            tooltips.addToolTipAtIndex(index: index, info: value)
        } else {
            let tabbarToolTip = TabBarToolTip(tabBar: tabBar, tooltips: [index: value])
            activeToolTipsTabBar[tabBar] = tabbarToolTip
        }
        
        return value;
    }
    
    fileprivate func addActiveToolTipAtIndex(tabBar: UITabBar,
                                      index: Int,
                                      attributedText: NSAttributedString,
                                      backgroundColor: UIColor? = nil,
                                      gesture: ViewDescriptionGestures,
                                      isEnabled: Bool = true) -> TooltipInfo{
        let value = TooltipInfo.init(attributedText: attributedText, backgroundColor: backgroundColor, gesture: gesture, senderType: .UITabBar);
        
        if let tooltips = activeToolTipsTabBar[tabBar] {
            tooltips.addToolTipAtIndex(index: index, info: value)
        } else {
            let tabbarToolTip = TabBarToolTip(tabBar: tabBar, tooltips: [index: value])
            activeToolTipsTabBar[tabBar] = tabbarToolTip
        }
        
        return value;
    }
    
    // Remove
    // Removes the description from the given view from the activeToolTipsViews
    fileprivate func removeToolTip(view: UIView) -> TooltipInfo? {
        return activeToolTipsViews.removeValue(forKey: view)
    }
    
    // Removes the description from the given barbutton from the activeToolTipsBarButtons
    fileprivate func removeToolTip(barButton: UIBarButtonItem) -> TooltipInfo? {
        return activeToolTipsBarButtons.removeValue(forKey: barButton)
    }
    
    // Removes the description from the given tabbarButton from the active tooltips
    fileprivate func removeToolTip(tabbar: UITabBar, index: Int?) -> TooltipInfo? {
        // If the index is given removes the tooltip at index
        if let index = index {
            let tabBarToolTips = activeToolTipsTabBar[tabbar]
            return tabBarToolTips?.removeToolTipAtIndex(index: index)
        // Else remove all tooltips of that tabbar
        } else {
            let isRemoved = activeToolTipsTabBar.removeValue(forKey: tabbar)
            guard isRemoved != nil else {
                return nil
            }
            return TooltipInfo(text: "Removed all tootips of tabbar", gesture: .longPress, senderType: .UITabBar, isEnabled: true)
        }
    }
    
    // GET 1
    // Returns the configutation for a given view
    fileprivate func getToolTip(view: UIView) -> TooltipInfo? {
        return activeToolTipsViews[view]
    }
    
    // Returns the configutation for a given bar button
    fileprivate func getToolTip(barbutton: UIBarButtonItem) -> TooltipInfo? {
        return activeToolTipsBarButtons[barbutton]
    }
    
    // Returns the configuration for the given tabbarbutton
    fileprivate func getToolTip(tabbar: UITabBar, index: Int) -> TooltipInfo? {
        return activeToolTipsTabBar[tabbar]?.getToolTip(index: index)
    }
    
    // Getter function to get all active descriptions and configuration on views
    public func getToolTipsViews() -> [UIView: TooltipInfo] {
        return self.activeToolTipsViews
    }
    
    // GET all
    // Getter function to get all active descriptions and configuration on bar buttons
    public func getToolTipsBarButtons() -> [UIBarButtonItem: TooltipInfo] {
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
    func show(_ senderView: UIView?, senderBarButton: UIBarButtonItem?, info: TooltipInfo) {
        guard let toolTipVC = self.rootViewController as? ToolTipViewController else {
            print("Error: Description window rootVC is not of type DescriptionViewController")
            return
        }
        
        self.isHidden = false
        toolTipVC.presentPopOver(senderView, senderBarButton: senderBarButton, info: info);
    }
}

// MARK: DescriptionViewController
/*
 Displays the actual popover viewcontroller with the description label
 */
private class ToolTipViewController: UIViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate {
    
    var info : TooltipInfo?;
    
    var popOverVC: UIViewController?
    var window: ToolTipWindow!
    var descriptionLabel: UILabel?
    
    // Getters to facilitate accessing the preferences
    var font: UIFont {
        return self.info?.font ?? SwiftyToolTipManager.instance.font
    }
    var textColor: UIColor {
        return self.info?.textColor ?? SwiftyToolTipManager.instance.textColor
    }
    var backgroundColor: UIColor? {
        return self.info?.backgroundColor ?? SwiftyToolTipManager.instance.backgroundColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        // Setup dismiss gesture recognizer
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
//        tap.delegate = self
//        view.addGestureRecognizer(tap)
//        view.backgroundColor = .yellow;
//        view.alpha = 1;
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
    func presentPopOver(_ senderView: UIView?, senderBarButton: UIBarButtonItem?, info: TooltipInfo) {
        self.info = info;
        
        // Check if there is another popover presenting
        if popOverVC == nil, let info = self.info {
            // Setup popover view
            popOverVC = UIViewController()
            popOverVC?.modalPresentationStyle = .popover
            
            // Setup description label
            descriptionLabel = UILabel()
            descriptionLabel?.backgroundColor = .clear
            descriptionLabel?.translatesAutoresizingMaskIntoConstraints = false
            descriptionLabel?.numberOfLines = 0
            descriptionLabel?.textAlignment = info.textAlignment;
            if let attributedText = info.attributedText{
                descriptionLabel?.attributedText = attributedText
            }else if let text = info.text{
                descriptionLabel?.font = self.font
                descriptionLabel?.textColor = self.textColor
                descriptionLabel?.text = text
            }
            
            // Add and constrain description label
            let popOverView : UIView! = popOverVC?.view;
            popOverView.addSubview(descriptionLabel!)
            if #available(iOS 9.0, *) {
                popOverView.addConstraints([descriptionLabel!.topAnchor.constraint(equalTo: popOverView.topAnchor, constant: info.paddings.top),
                                                descriptionLabel!.leftAnchor.constraint(equalTo: popOverView.leftAnchor, constant: info.paddings.left),
                                                descriptionLabel!.rightAnchor.constraint(equalTo: popOverView.rightAnchor, constant: -info.paddings.right),
                                                descriptionLabel!.bottomAnchor.constraint(equalTo: popOverView.bottomAnchor, constant: -12 - info.paddings.bottom)])
            } else {
                // Fallback on earlier versions
                // TODO: Add new contraint
            }
            
            // Calculate size based on description text size
            popOverVC?.preferredContentSize =
                CGSize(width: (descriptionLabel!.intrinsicContentSize.width >
                    self.window.frame.width * 0.75) ?
                        self.window.frame.width * 0.75 :
                        descriptionLabel!.intrinsicContentSize.width + 20 + info.paddings.left + info.paddings.right,
                       height: description.height(withConstrainedWidth: self.window.frame.width * 0.75,
                                                  font: self.font) + info.paddings.top + info.paddings.bottom)
            
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
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        self.popOverVC = nil
        self.descriptionLabel = nil
        self.window.isHidden = true
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
     
     - parameter text: String for ToolTip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     */
    fileprivate func addToolTip(text: String,
                                backgroundColor: UIColor? = nil,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) -> TooltipInfo{
        return self._addToolTip(text: text, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
    }
    
    /**
     Adds a tooltip to the ToolTipManager and sets up the gesture to activate the tooltip on the view.
     
     - parameter attributedText: Attributed String for ToolTip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     */
    fileprivate func addToolTip(attributedText: NSAttributedString? = nil,
                                backgroundColor: UIColor? = nil,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) -> TooltipInfo{
        return self._addToolTip(attributedText: attributedText, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled);
    }
    
    /**
     Adds a tooltip to the ToolTipManager and sets up the gesture to activate the tooltip on the view.
     
     - parameter text: String for ToolTip
     - parameter attributedText: Attributed String for ToolTip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     */
    fileprivate func _addToolTip(text: String? = nil,
                           attributedText: NSAttributedString? = nil,
                           backgroundColor: UIColor? = nil,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) -> TooltipInfo{
        var value : TooltipInfo!
        if let text = text{
            value = SwiftyToolTipManager.instance.addActiveToolTip(view: self, text: text, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
        }else if let attributedText = attributedText{
            value = SwiftyToolTipManager.instance.addActiveToolTip(view: self, attributedText: attributedText, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
        }
        
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
        
        return value;
    }
    
    /*
     Displays the tooltip from self
     */
    @objc func showToolTip() {
        SwiftyToolTipManager.instance.showToolTip(sender: self)
    }
    
    /*
     Removes the tooltip from the Tooltip manager and removes the gesture from the view.
     
     - parameter isUserInteractive: Allows you to disable the userinteractivity after removing the gesture. Use this to keep buttons clickable and make sure the view does not contain other gesture recognizers. Default = true
     */
    func removeToolTip(isUserInteractive: Bool = true) {
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
    /**
     Adds a tooltip to the ToolTipManager and sets up the gesture to activate the tooltip on the BarButtonItem.
     
     - parameter description: This is the text displayed in the tool tip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     
     Notice: Make sure the tooltip is called in ViewDidAppear as the BarButtonItem has to be on screen and loaded.
     */
    public func addToolTip(text: String,
                           gesture: ViewDescriptionGestures = .longPress,
                           backgroundColor: UIColor? = nil,
                           isEnabled: Bool = true) -> TooltipInfo{
        return self._addToolTip(text: text, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
    }
    
    /**
     Adds a tooltip to the ToolTipManager and sets up the gesture to activate the tooltip on the BarButtonItem.
     
     - parameter attributedText: Attributed String for Tooltip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     
     Notice: Make sure the tooltip is called in ViewDidAppear as the BarButtonItem has to be on screen and loaded.
     */
    public func addToolTip(attributedText: NSAttributedString,
                           gesture: ViewDescriptionGestures = .longPress,
                           backgroundColor: UIColor? = nil,
                           isEnabled: Bool = true) -> TooltipInfo{
        return self._addToolTip(attributedText: attributedText, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
    }
    
    /**
     Adds a tooltip to the ToolTipManager and sets up the gesture to activate the tooltip on the BarButtonItem.
     
     - parameter text: String for Tooltip
     - parameter attributedText: Attributed String for Tooltip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     
     Notice: Make sure the tooltip is called in ViewDidAppear as the BarButtonItem has to be on screen and loaded.
     */
    fileprivate func _addToolTip(text: String? = nil,
                           attributedText: NSAttributedString? = nil,
                           backgroundColor: UIColor? = nil,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) -> TooltipInfo{
        var value : TooltipInfo!;
        
        if let text = text{
            value = SwiftyToolTipManager.instance.addActiveToolTip(barButton: self, text: text, gesture: gesture, backgroundColor: backgroundColor, isEnabled: isEnabled)
        }else if let attributedText = attributedText{
            value = SwiftyToolTipManager.instance.addActiveToolTip(barButton: self, attributedText: attributedText, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
        }
        
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
        
        return value;
    }
    
    /*
     Displays the tooltip from self
     */
    @objc public func showToolTip() {
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
    /**
     Adds a tooltip to the ToolTipManager and sets up the gesture to activate the tooltip on the TabBarButton.
     
     - parameter text: String for Tooltip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     
     Notice: Make sure the tooltip is called in ViewDidAppear as the BarButtonItem has to be on screen and loaded.
     */
    public func addToolTip(at index: Int,
                           text: String? = nil,
                           backgroundColor: UIColor? = nil,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) -> TooltipInfo{

        return self._addToolTip(at: index, text: text, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
    }
    
    /**
     Adds a tooltip to the ToolTipManager and sets up the gesture to activate the tooltip on the TabBarButton.
     
     - parameter attributedText: Attributed String for Tooltip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     
     Notice: Make sure the tooltip is called in ViewDidAppear as the BarButtonItem has to be on screen and loaded.
     */
    public func addToolTip(at index: Int,
                           attributedText: NSAttributedString? = nil,
                           backgroundColor: UIColor? = nil,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) -> TooltipInfo{

        return self._addToolTip(at: index, attributedText: attributedText, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
    }
    
    /**
     Adds a tooltip to the ToolTipManager and sets up the gesture to activate the tooltip on the TabBarButton.
     
     - parameter text: String for Tooltip
     - parameter attributedText: Attributed String for Tooltip
     - parameter gesture: The gesture used to show the tool tip. default = .longPress
     - parameter isEnabled: Disables or enables the gesture on the view
     
     Notice: Make sure the tooltip is called in ViewDidAppear as the BarButtonItem has to be on screen and loaded.
     */
    public func _addToolTip(at index: Int,
                           text: String? = nil,
                           attributedText: NSAttributedString? = nil,
                           backgroundColor: UIColor? = nil,
                           gesture: ViewDescriptionGestures = .longPress,
                           isEnabled: Bool = true) -> TooltipInfo{
        var value : TooltipInfo!;
        
        if let text = text{
            value = SwiftyToolTipManager.instance.addActiveToolTipAtIndex(tabBar: self, index: index, text: text, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
        }else if let attributedText = attributedText{
            value = SwiftyToolTipManager.instance.addActiveToolTipAtIndex(tabBar: self, index: index, attributedText: attributedText, backgroundColor: backgroundColor, gesture: gesture, isEnabled: isEnabled)
        }
        

        
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
        
        return value;
    }

    /*
     Displays the tooltip from the UITabBarButton
     */
    @objc public func showToolTip(recognizer: UIGestureRecognizer) {
        guard recognizer.state == .began else { return }
        guard let tabBar = recognizer.view as? UITabBar else { return }
        guard let tabBarItems = tabBar.items else { return }

        let loc = recognizer.location(in: tabBar)

        for (index, item) in tabBarItems.enumerated() {
            guard let view = item.itemView else { continue }
            guard view.frame.contains(loc) else { continue }

            SwiftyToolTipManager.instance.showToolTip(sender: view, tabBar: self, index: index)
            break
        }
    }
    
    public func showToolTip(index: Int) {
        guard let itemView = self.items?[index].itemView else {
            return;
        }
        
        SwiftyToolTipManager.instance.showToolTip(sender: itemView, tabBar: self, index: index);
    }
}

extension UITabBarItem{
    var itemView : UIView?{
        return self.value(forKey: "view") as? UIView;
    }
}



