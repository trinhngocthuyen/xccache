import SwiftUI
import ResourceKit

struct ContentView: View {
  var body: some View {
    VStack {
      Spacer()
      Text(ResourceKit.greetings() ?? "N/A").font(.title)
      Spacer()
      Text("ResourceKit.bundle = \(ResourceKit.bundle.bundlePath)").font(.footnote)
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
