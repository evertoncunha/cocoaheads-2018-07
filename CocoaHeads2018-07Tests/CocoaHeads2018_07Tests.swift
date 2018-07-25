//
//  CocoaHeads2018_07Tests.swift
//  CocoaHeads2018-07Tests
//
//  Created by Everton Cunha on 24/07/2018.
//  Copyright © 2018 Everton Cunha. All rights reserved.
//

import XCTest
@testable import CocoaHeads2018_07

class CocoaHeads2018_07Tests: SnapTestCase {
  
  func loadViewUI()
  {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let rootViewController = storyboard.instantiateInitialViewController()
    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = rootViewController
  }
  
  func test_snap_first() {
    loadViewUI()
    snapshot()
  }
  
  func test_snap_second() {
    loadViewUI()
  }
}

func rootView() -> UIView {
  return (UIApplication.shared.delegate as! AppDelegate).window!
}

