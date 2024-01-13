//
//  wallmanApp.swift
//  wallman
//
//  Created by d on 2024-01-03.
//

import SwiftUI


@main
struct WallmanApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("lockFilePath") private var lockFilePath: String = ""
    @AppStorage("unlockFilePath") private var unlockFilePath: String = ""
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
            SettingsView(lockFilePath: $lockFilePath, unlockFilePath: $unlockFilePath)
        }
    }
    
    func setDesktopImage(filePath: String) {
        do {
            print(filePath)
            let imgurl = NSURL.fileURL(withPath: filePath)
            
            let workspace = NSWorkspace.shared
            if let screen = NSScreen.main  {
                try workspace.setDesktopImageURL(imgurl, for: screen, options: [:])
            }
        } catch {
            print(error)
        }
    }
    
    init() {
        NSLog("Init")
        appDelegate.app = self
    }
    
    func onStart() {
        print("onStart")
        
        let dnc = DistributedNotificationCenter.default()

        dnc.addObserver(forName: .init("com.apple.screenIsLocked"),
                                       object: nil, queue: .main) { _ in
            NSLog("Screen Locked")
            if (enabled) {
                setDesktopImage(filePath: lockFilePath)
            }
        }

        dnc.addObserver(forName: .init("com.apple.screenIsUnlocked"),
                                         object: nil, queue: .main) { _ in
            NSLog("Screen Unlocked")
            if (enabled) {
                setDesktopImage(filePath: unlockFilePath)
            }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var app: WallmanApp? = nil
    var aboutBoxWindowController: NSWindowController?
    
    func applicationWillFinishLaunching(_ notification: Notification) {
        print("Delegate")
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
