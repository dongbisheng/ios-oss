import XCTest
@testable import Library

final class EnvironmentVariablesTests: XCTestCase {
  func testKoalaTrackingVariable() {
    var processInfo = MockProcessInfo()
    XCTAssertFalse(EnvironmentVariables().kaoalaTrackingIsOn)

    processInfo = MockProcessInfo(environment: [VariableName.koalaTracking.rawValue: "giberish"])
    XCTAssertFalse(EnvironmentVariables(processInfo: processInfo).kaoalaTrackingIsOn)

    processInfo = MockProcessInfo(environment: [VariableName.koalaTracking.rawValue: "false"])
    XCTAssertFalse(EnvironmentVariables(processInfo: processInfo).kaoalaTrackingIsOn)

    processInfo = MockProcessInfo(environment: [VariableName.koalaTracking.rawValue: "true"])
    XCTAssertTrue(EnvironmentVariables(processInfo: processInfo).kaoalaTrackingIsOn)
  }
}

private struct MockProcessInfo: ProcessInfoType {
  let environment: [String: String]

  internal init (environment: [String: String] = [:]) {
    self.environment = environment
  }
}
