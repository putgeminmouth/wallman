//
//  ContentView.swift
//  wallman
//
//  Created by d on 2024-01-03.
//

import SwiftUI
import UniformTypeIdentifiers
import ServiceManagement

struct SettingsView: View {
    @Binding var lockFilePath: String
    @Binding var unlockFilePath: String
    @AppStorage("launchAtStartup") var launchAtStartup: Bool = false
    @State private var lockFilePickerPresented = false
    @State private var unlockFilePickerPresented = false

    var body: some View {
        Form {
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
                                    print(error)
                                }
                            } else {
                                do {
                                    try SMAppService.mainApp.unregister()
                                } catch {
                                    print(error)
                                }
                            }
                        }
                    Divider()
                    Text("Images to set as wallpaper when the screen is")
                    HStack {
                        TextField("Locked", text: $lockFilePath, prompt: nil)
                        Button("...") {
                            lockFilePickerPresented = true
                        }.fileImporter(isPresented: $lockFilePickerPresented, allowedContentTypes: [UTType("public.item")!]) { result in
                            do {
                                let url = try result.get()
                                lockFilePath = url.path
                                
                            } catch {}
                        }
                    }
                    HStack {
                        TextField("Unlocked", text: $unlockFilePath, prompt: nil)
                        Button("...") {
                            unlockFilePickerPresented = true
                        }.fileImporter(isPresented: $unlockFilePickerPresented, allowedContentTypes: [UTType("public.item")!]) { result in
                            do {
                                let url = try result.get()
                                unlockFilePath = url.path
                            } catch {}
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings: Wallpaper Manager")
        .padding()
        .onAppear() {
            NSApp.activate()
            for w in NSApplication.shared.windows {
                w.orderFrontRegardless()
            }
        }
    }
}
