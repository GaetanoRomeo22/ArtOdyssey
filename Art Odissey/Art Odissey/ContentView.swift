import SwiftUI
import AVFoundation

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack {
                HomeView()
                    .preferredColorScheme(.light) // light mode
            }
        }
    }
}

#Preview {
    ContentView()
}

