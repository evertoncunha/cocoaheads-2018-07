//
//  HaveValidSnapshot.swift
//  CocoaHeads2018-07
//
//  Created by Everton Cunha on 25/07/2018.
//  Copyright © 2018 Everton Cunha. All rights reserved.
//

import Foundation
import FBSnapshotTestCase
import Foundation
import QuartzCore
import UIKit

@objc public protocol Snapshotable {
  var snapshotObject: UIView? { get }
}
extension UIViewController : Snapshotable {
  public var snapshotObject: UIView? {
    self.beginAppearanceTransition(true, animated: false)
    self.endAppearanceTransition()
    return view
  }
}
extension UIView : Snapshotable {
  public var snapshotObject: UIView? {
    return self
  }
}
@objc public class FBSnapshotTest: NSObject {
  var referenceImagesDirectory: String?
  var tolerance: CGFloat = 0.2
  static let sharedInstance = FBSnapshotTest()
  public class func setReferenceImagesDirectory(_ directory: String?) {
    sharedInstance.referenceImagesDirectory = directory
  }
  // swiftlint:disable:next function_parameter_count
  class func compareSnapshot(_ instance: Snapshotable, isDeviceAgnostic: Bool = false,
                             usesDrawRect: Bool = false, snapshot: String, record: Bool,
                             referenceDirectory: String, tolerance: CGFloat,
                             filename: String, identifier: String? = nil) -> Bool {
    let testName = parseFilename(filename: filename)
    let snapshotController: FBSnapshotTestController =
      FBSnapshotTestController(testName: testName)
    snapshotController.isDeviceAgnostic = isDeviceAgnostic
    snapshotController.recordMode = record
    snapshotController.referenceImagesDirectory = referenceDirectory
    snapshotController.usesDrawViewHierarchyInRect = usesDrawRect
    let reason = "Missing value for referenceImagesDirectory - " + "Call FBSnapshotTest.setReferenceImagesDirectory(FB_REFERENCE_IMAGE_DIR)"
    assert(snapshotController.referenceImagesDirectory != nil, reason)
    do {
      try snapshotController.compareSnapshot(ofViewOrLayer: instance.snapshotObject,
                                             selector: Selector(snapshot), identifier: identifier, tolerance: tolerance)
    } catch {
      return false
    }
    return true
  }
}
// Note that these must be lower case.
private var testFolderSuffixes = ["tests", "specs"]
func getDefaultReferenceDirectory(_ sourceFileName: String) -> String {
  if let globalReference = FBSnapshotTest.sharedInstance.referenceImagesDirectory {
    return globalReference
  }
  // Search the test file's path to find the first folder with a test suffix,
  // then append "/ReferenceImages" and use that.
  // Grab the file's path
  let pathComponents = (sourceFileName as NSString).pathComponents as NSArray
  // Find the directory in the path that ends with a test suffix.
  let testPath = pathComponents.first { component -> Bool in
    return !testFolderSuffixes.filter {
      (component as AnyObject).lowercased.hasSuffix($0)
      }.isEmpty
  }
  guard let testDirectory = testPath else {
    fatalError("Could not infer reference image folder – You should provide a reference dir using " + "FBSnapshotTest.setReferenceImagesDirectory(FB_REFERENCE_IMAGE_DIR)")
  }
  // Recombine the path components and append our own image directory.
  let currentIndex = pathComponents.index(of: testDirectory) + 1
  let folderPathComponents = pathComponents.subarray(with: NSRange(location: 0, length: currentIndex)) as NSArray
  let folderPath = folderPathComponents.componentsJoined(by: "/")
  return folderPath + "/ReferenceImages"
}
private func parseFilename(filename: String) -> String {
  let nsName = filename as NSString
  let type = ".\(nsName.pathExtension)"
  let sanitizedName = nsName.lastPathComponent.replacingOccurrences(of: type, with: "")
  return sanitizedName
}
func sanitizedTestName(_ name: String?) -> String {
  guard let testName = CurrentTestCaseTracker.shared.currentTestCase?.sanitizedName else {
    fatalError("Test matchers must be called from inside a test block")
  }
  var filename = name ?? testName
  filename = filename.replacingOccurrences(of: "root example group, ", with: "")
  let characterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")
  let components = filename.components(separatedBy: characterSet.inverted)
  let finalName = components.dropFirst().joined(separator: "_")
  if finalName.contains("test_snap_") == false {
    fatalError("Tests with snapshot should begin with test_snap_")
  }
  return finalName.replacingOccurrences(of: "test_snap_", with: "", options: .anchored)
}
