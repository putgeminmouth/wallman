import SwiftUI
import OSLog

@main
struct WallmanApp: App {
    let logger = Logger(subsystem: "Wallman", category: "App")
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("walls") private var walls: [Wall] = []
    @AppStorage("enabled") private var enabled: Bool = true

    var hasAppeared = false
    var body: some Scene {
        MenuBarExtra("WallMan", image: "MenuIcon") {
            Button("About") {
                appDelegate.showAboutPanel()
            }
            SettingsLink()
            Toggle(isOn: $enabled) {
                Text("Enabled")
            }
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        Settings {
            SettingsView(walls: $walls)
        }
    }
    
    func setDesktopImages(picker: (Wall) -> String?) {
        NSScreen.screens.forEach { screen in
            var screenId = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
            if let wall = (walls.first{ $0.screenId == screenId as? UInt32}) {
                if !(wall.enabled) {
                    return
                }
                if let image = picker(wall) {
                    setDesktopImage(screen: screen, filePath: image)
                }
            }
        }
    }
    func setDesktopImage(screen: NSScreen, filePath: String) {
        do {
            logger.debug("\(filePath)")
            let imgurl = NSURL.fileURL(withPath: filePath)
            
            let workspace = NSWorkspace.shared
            try workspace.setDesktopImageURL(imgurl, for: screen, options: [:])
        } catch {
            logger.error("Failed to set desktop image: \(error)")
        }
    }
    
    init() {
        logger.debug("Init")
        appDelegate.app = self
    }
    
    func onStart() {
        logger.debug("onStart")
        
        let dnc = DistributedNotificationCenter.default()

        dnc.addObserver(forName: .init("com.apple.screenIsLocked"),
                        object: nil, queue: .main) { _ in
            logger.debug("Screen Locked")
            if (enabled) {
                setDesktopImages{$0.locked}
            }
        }

        dnc.addObserver(forName: .init("com.apple.screenIsUnlocked"),
                        object: nil, queue: .main) { _ in
            logger.debug("Screen Unlocked")
            if (enabled) {
                setDesktopImages{$0.unlocked}
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var app: WallmanApp? = nil
    var aboutBoxWindowController: NSWindowController?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        app!.onStart()
    }
    
    func showAboutPanel() {
        if aboutBoxWindowController == nil {
            let styleMask: NSWindow.StyleMask = [.closable, .miniaturizable,/* .resizable,*/ .titled]
            let window = NSWindow()
            window.styleMask = styleMask
            window.title = "About: Wallpaper Manager"
            window.contentView = NSHostingView(rootView: AboutView())
            aboutBoxWindowController = NSWindowController(window: window)
        }
        
        aboutBoxWindowController?.showWindow(aboutBoxWindowController?.window)
        aboutBoxWindowController?.window?.orderFrontRegardless()
    }
    
}
