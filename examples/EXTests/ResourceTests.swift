import Testing
import ResourceKit

struct PkgResourceTests {
  @Test func checkPkgResources() {
    #expect(ResourceKit.greetings() == "Hi from xccache!")
  }
}
