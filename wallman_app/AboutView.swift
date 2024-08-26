import SwiftUI
import UniformTypeIdentifiers
import OSLog

struct AboutView: View {
    let logger = Logger(subsystem: "Wallman", category: "About")
    var body: some View {
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        let version = "1.\(bundleVersion)"

        VStack {
            Image("AboutImage")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
            Text("WallMan: Wallpaper Manager")
            Text("Version \(version)")
            Text("[Github](https://github.com/putgeminmouth/wallman)")
        }
        .frame(minHeight: 570)
    }
}
