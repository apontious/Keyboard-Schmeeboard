//
//  ViewController.swift
//  Corrected Keyboard Schmeeboard4 http://github.com/apontious/Keyboard-Schmeeboard/
//
//  Created by Andrew Pontious on 1/5/17.
//  Copyright © 2017 Andrew Pontious.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//

import UIKit

// http://stackoverflow.com/questions/32125653/ios-foreign-language-keyboard-heights

typealias FrameBeginRect = CGRect
typealias FrameEndRect = CGRect
typealias AnimationDuration = Double

class ViewController: UIViewController {
	
	@IBOutlet weak var grayView: UIView!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
	
	private var inRotation: Bool = false
	
	// Convenience method to turn keyboard notification into usable parameters.
	private func handleKeyboardNotification(_ notification: NSNotification,
	                                        handler: (FrameBeginRect, FrameEndRect, AnimationDuration, UIViewAnimationOptions) -> Void) {
		
		// Too giant of a guard statement?
		// I couldn't find a way to combine the check-for-type line and the assign line.
		// I tried a "where" clause (which might not do what I want anyway), but compiler complained.
		// Compiler requires me to use "as!" a.k.a. forced conversion, so I want to test that it's valid beforehand.
		
		guard let userInfo = notification.userInfo,
			// UIKeyboardFrameBeginUserInfoKey
			userInfo[UIKeyboardFrameBeginUserInfoKey] is NSValue?,
			let frameBegin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue?)?.cgRectValue,
			// UIKeyboardFrameEndUserInfoKey
			userInfo[UIKeyboardFrameEndUserInfoKey] is NSValue?,
			let frameEnd = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue?)?.cgRectValue,
			// UIKeyboardAnimationDurationUserInfoKey
			userInfo[UIKeyboardAnimationDurationUserInfoKey] is NSNumber?,
			let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber?)?.doubleValue,
			// UIKeyboardAnimationDurationUserInfoKey
			userInfo[UIKeyboardAnimationDurationUserInfoKey] is NSNumber?,
			let animationCurveInteger = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber?)?.intValue,
			let animationCurve = UIViewAnimationCurve(rawValue: animationCurveInteger)
			else {
				return
		}
		
		var animationOptions: UIViewAnimationOptions
		
		switch(animationCurve) {
		case .easeInOut:
			animationOptions = [.curveEaseInOut]
		case .easeIn:
			animationOptions = [.curveEaseIn]
		case .easeOut:
			animationOptions = [.curveEaseOut]
		case .linear:
			animationOptions = [.curveLinear]
		}
		
		handler(frameBegin, frameEnd, animationDuration, animationOptions)
	}
	
	func handleTap() {
		textField.resignFirstResponder()
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		if view.bounds.size.height == size.width && view.bounds.size.width == size.height {
			inRotation = true
		}
		coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
		}) { (context: UIViewControllerTransitionCoordinatorContext) in
			self.inRotation = false
		}
	}
	
	func willShowKeyboard(_ notification: NSNotification) {
		handleKeyboardNotification(notification) { (frameBegin: CGRect, frameEnd: CGRect, animationDuration: Double, animationOptions: UIViewAnimationOptions) in
			
			let modifiedAnimationOptions = animationOptions.union([.beginFromCurrentState]);
			// http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
			view.layoutIfNeeded()
			
			UIView.animate(withDuration: animationDuration, delay: 0, options: modifiedAnimationOptions, animations: {
				self.bottomLayoutConstraint.constant = self.view.bounds.height - frameEnd.minY
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
	func willHideKeyboard(_ notification: NSNotification) {
		handleKeyboardNotification(notification) { (frameBegin: CGRect, frameEnd: CGRect, animationDuration: Double, animationOptions: UIViewAnimationOptions) in
			if self.inRotation {
				return
			}
			self.view.layoutIfNeeded()
			
			UIView.animate(withDuration: animationDuration, delay: 0, options: animationOptions, animations: {
				self.bottomLayoutConstraint.constant = self.view.bounds.height - frameEnd.minY
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap))
		self.view.addGestureRecognizer(tapGestureRecognizer)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let center = NotificationCenter.default;
		center.addObserver(self, selector: #selector(ViewController.willShowKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		center.addObserver(self, selector: #selector(ViewController.willHideKeyboard(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		let center = NotificationCenter.default;
		center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		center.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}
	
	override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		get {
			return .all
		}
	}
}
