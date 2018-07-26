//
//  EarlGreyExtensions.swift
//  CocoaHeads2018-07Tests
//
//  Created by Everton Cunha on 26/07/2018.
//  Copyright © 2018 Everton Cunha. All rights reserved.
//

import EarlGrey
import XCTest

extension XCTestCase {
  func element(_ accessibilityID: String) -> GREYInteraction {
    return EarlGrey.selectElement(with: grey_accessibilityID(accessibilityID))
  }
  func interactable(_ aClass: AnyClass, index: UInt)-> GREYInteraction {
    return EarlGrey.selectElement(with: grey_allOf([grey_kindOfClass(aClass), grey_interactable()])).atIndex(index)
  }
  func waitKeyWindow() {
    EarlGrey.selectElement(with: grey_keyWindow()).assert(grey_notNil())
  }
}

extension GREYInteraction {
  
  func clearCursor() {
    let action = GREYActionBlock.action(withName: "tint clear") { (obj, _) -> Bool in
      if let txt = obj as? UITextField {
        txt.tintColor = UIColor.clear
      }
      return true
    }
    perform(action)
  }
  
  func type(_ text: String) {
    clearCursor()
    perform(grey_typeText(text))
  }
  
  func tap() {
    perform(grey_tap())
  }
  
  @discardableResult func exists() -> GREYInteraction {
    return assert(grey_notNil())
  }
  
  func textEquals(_ text: String) {
    assert(grey_textFieldValue(text))
  }
}
