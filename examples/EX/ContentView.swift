import SwiftUI
import DebugKit
import ResourceKit

struct ContentView: View {
  var body: some View {
    VStack {
      Text(ResourceKit.greetings() ?? "N/A").font(.title)
      Form {
        Section("Resources") {
          labledContent("ResourceKit.bundle", ResourceKit.bundle.relativePath)
          labledContent("DebugKit.bundle", DebugKit.bundle.relativePath)
          labledContent("DebugKit.token", DebugKit.loadToken())
        }
        .font(.footnote)
      }
    }
  }

  private func labledContent(_ label: String, _ value: String) -> some View {
    LabeledContent {
      Text(value)
        .multilineTextAlignment(.trailing)
        .foregroundStyle(value.contains("Frameworks/") ? .green : .gray)
    } label: {
      Text(label)
    }
  }
}

#Preview {
  ContentView()
}
