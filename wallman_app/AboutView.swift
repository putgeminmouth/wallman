import SwiftUI
import UniformTypeIdentifiers
import OSLog

struct AboutView: View {
    let logger = Logger(subsystem: "Wallman", category: "About")
    var body: some View {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        VStack {
            Image("AboutImage")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
            Text("WallMan: Wallpaper Manager")
            Text("Version \(version ?? "unknown")")
            Text("[Github](https://github.com/putgeminmouth/wallman)")
        }
        .frame(minHeight: 570)
    }
}
