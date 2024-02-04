import SwiftUI
import UniformTypeIdentifiers
import OSLog

struct AboutView: View {
    let logger = Logger(subsystem: "Wallman", category: "About")
    var body: some View {
        Image("AboutImage")
            .resizable()
            .scaledToFit()
            .frame(width: 500, height: 500)
            .onAppear() {
                logger.debug("AboutView.appear")
            }
            .onDisappear() {
                logger.debug("AboutView.disappear")
            }
    }
}
