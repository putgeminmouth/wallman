import SwiftUI
import UniformTypeIdentifiers
import ServiceManagement
import OSLog

func bindOpt<T>(lhs: Binding<Optional<T>>, rhs: T) -> Binding<T> {
    Binding(
        get: { lhs.wrappedValue ?? rhs },
        set: { lhs.wrappedValue = $0 }
    )
}

struct SettingsView: View {
    let logger = Logger(subsystem: "Wallman", category: "Settings")

    @Binding var walls: [Wall]
    @AppStorage("launchAtStartup") var launchAtStartup: Bool = false
    @State private var lockFilePickerPresented: [Int: Bool] = [:]
    @State private var unlockFilePickerPresented: [Int: Bool] = [:]

    func synchronizeWallsWithScreens() {
        // update existing
        walls.indices.forEach { index in
            let screenOpt = NSScreen.screens.first{ $0.displayId == walls[index].screenId }
            logger.debug("Updating wall \(walls[index].displayName)")
            
            if let screen = screenOpt {
                walls[index].displayName = screen.localizedName
                walls[index].connected = true
            } else {
                walls[index].connected = false
            }
        }

        // add new
        NSScreen.screens.forEach { screen in
            guard (walls.first{ $0.screenId == screen.displayId } == nil) else { return }
            guard let displayId = screen.displayId else { return }
            logger.debug("New Screens \(screen.localizedName)")
            let w = Wall(screenId: displayId, displayName: screen.localizedName, connected: true, enabled: false)
            walls.append(w)
        }
    }
    
    var body: some View {
        ZStack {
            Image("AboutImage")
                .resizable()
                .scaledToFit()
                .frame(width: 500, height: 500)
                .blur(radius: 20)
                .opacity(0.080)

            VStack(alignment: .leading) {
                Toggle("Launch at startup", isOn: $launchAtStartup)
                    .onChange(of: launchAtStartup) {
                        if (launchAtStartup) {
                            do {
                                try SMAppService.mainApp.register()
                            } catch {
                                logger.error("Failed to register service \(error)")
                            }
                        } else {
                            do {
                                try SMAppService.mainApp.unregister()
                            } catch {
                                logger.error("Failed to unregister service \(error)")
                            }
                        }
                    }
                Divider()

                ForEach($walls, id: \.screenId) {
                    let wall = $0.wrappedValue
                    let index: Int = walls.firstIndex{$0 == wall}!
                    let displayName = wall.displayName
                    let screenId = wall.screenId

                    GroupBox("\(displayName) (\(String(format: "%d", screenId)))") {
                        ZStack(alignment:.top) {
                            if (wall.connected) {
                                Button(action: {
                                    walls[index] = Wall(screenId: wall.screenId, displayName: wall.displayName, connected: true, enabled: false)
                                }) {
                                    Image(systemName: "arrow.uturn.backward")
                                }.buttonStyle(PlainButtonStyle())
                                    .padding(5)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .help("Clear this configuration. You cannot remove connected screens, but you can disable them.")
                            } else {
                                Button(action: {
                                    walls.remove(at: index)
                                }) {
                                    Image(systemName: "trash")
                                }.buttonStyle(PlainButtonStyle())
                                    .padding(5)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                    .help("Remove this screen, it will show again if reconnected.")
                            }
                            
                            VStack(alignment: .leading) {
                                Toggle("Screen is connected", isOn: $walls[index].connected)
                                    .disabled(true)
                                Toggle("Enable for this screen", isOn: $walls[index].enabled)
                                Text("Images to set as wallpaper when the screen is")

                                HStack {
                                    TextField("Locked", text: bindOpt(lhs: $walls[index].locked, rhs: "")/*Binding(get: wall.locked, set: wall.locked=$0)*/, prompt: nil)
                                    Button("...") {
                                        lockFilePickerPresented[index] = true
                                    }.fileImporter(isPresented: Binding(get: {(lockFilePickerPresented[index] ?? false)}, set: {lockFilePickerPresented[index] = $0}), allowedContentTypes: [UTType("public.item")!]) { result in
                                        do {
                                            let url = try result.get()
                                            walls[index].locked = url.path
                                        } catch {}
                                    }
                                }
                                HStack {
                                    TextField("Unlocked", text: bindOpt(lhs: $walls[index].unlocked, rhs: ""), prompt: nil)
                                    Button("...") {
                                        unlockFilePickerPresented[index] = true
                                    }.fileImporter(isPresented: Binding(get: {(unlockFilePickerPresented[index] ?? false)}, set: {unlockFilePickerPresented[index] = $0}), allowedContentTypes: [UTType("public.item")!]) { result in
                                        do {
                                            let url = try result.get()
                                            walls[index].unlocked = url.path
                                        } catch {}
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings: Wallpaper Manager")
        .padding()
        .onAppear() {
            logger.debug("SettingsView.appear")

            synchronizeWallsWithScreens()

            NSApp.activate()
            for w in NSApplication.shared.windows {
                w.orderFrontRegardless()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didChangeScreenParametersNotification), perform: { _ in
            synchronizeWallsWithScreens()
        })
    }
}
