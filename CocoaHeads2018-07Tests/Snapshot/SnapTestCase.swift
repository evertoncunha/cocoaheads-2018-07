//
//  SnapTestCase.swift
//  CocoaHeads2018-07
//
//  Created by Everton Cunha on 25/07/2018.
//  Copyright © 2018 Everton Cunha. All rights reserved.
//

import XCTest
import FBSnapshotTestCase

class SnapTestCase: FBSnapshotTestCase {
  override func setUp() {
    super.setUp()
    
    continueAfterFailure = false
    recordMode = false
    
    CurrentTestCaseTracker.shared.currentTestCase = self
  }
  override func tearDown() {
    super.tearDown()
    CurrentTestCaseTracker.shared.currentTestCase = nil
  }
}
extension SnapTestCase {
  func snapshot(_ identifier: String? = nil, file: StaticString = #file, line: UInt = #line) {
    var snapshotName = sanitizedTestName(nil)
    var referenceImageDirectory = getDefaultReferenceDirectory(file.description)
    
    let iden = identifier != nil ? "_\(identifier!)" : ""
    
    snapshotName = "\(snapshotName)\(iden)_\(modelIdentifierAndSystemVersion())"
    
    let fileName = file.description.components(separatedBy: "/").last?.components(separatedBy: ".").first ?? ""
    
    let pathCheck = referenceImageDirectory.appending("/\(fileName)/\(snapshotName)@\(Int(UIScreen.main.scale))x.png")
    if FileManager.default.fileExists(atPath: pathCheck) == false {
      recordMode = true
      continueAfterFailure = true
      referenceImageDirectory = referenceImageDirectory.replacingOccurrences(of: "ReferenceImages", with: "NewImages")
    }
    
    let result = FBSnapshotTest.compareSnapshot(rootView(), isDeviceAgnostic: false, usesDrawRect: true, snapshot: snapshotName, record: recordMode, referenceDirectory: referenceImageDirectory, tolerance: FBSnapshotTest.sharedInstance.tolerance, filename: file.description, identifier: nil)
    if result == false {
      XCTFail(recordMode ? "PROBLEM RECORDING \(name)" : "expected a matching snapshot in \(name)", file: file, line: line)
    } else if recordMode == true {
      XCTFail("snapshot \(name) successfully recorded", file: file, line: line)
    }
  }
  fileprivate func modelIdentifierAndSystemVersion() -> String {
    var systemVersion = UIDevice.current.systemVersion
    systemVersion = String(systemVersion[..<systemVersion.range(of: ".")!.lowerBound])
    return UIDevice.current.modelName.replacingOccurrences(of: " ", with: "") + "_" + systemVersion
  }
}
