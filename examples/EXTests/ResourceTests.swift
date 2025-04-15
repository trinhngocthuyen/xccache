import Testing
import DebugKit
import ResourceKit

struct PkgResourceTests {
  @Test func checkPkgResources() {
    #expect(ResourceKit.greetings() == "Hi from xccache!")
    #expect(DebugKit.loadToken() == "12345")
  }
}
