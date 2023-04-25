//
//  sshVPNClientApp.swift
//  sshVPNClient
//
//  Created by Malekmatin Ziraksaz on 2/16/23.
//

import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillUpdate(_ notification: Notification) {
        if let menu = NSApplication.shared.mainMenu {
            menu.items.removeAll { $0.title == "Edit" }
            menu.items.removeAll { $0.title == "File" }
            menu.items.removeAll { $0.title == "Window" }
            menu.items.removeAll { $0.title == "View" }
        }
    }
}

@main
struct swiftui_menu_barApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State var currentState: String = "proxy on"
    @Environment(\.openWindow) var openWindow

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 350, minHeight: 350)
                .onAppear {
                    switch LocalProxyManager.instance.checkState() {
                    case .enabled: currentState = "proxy on"
                    case .disabled: currentState = "proxy off"
                    }
                }
        }.commands {
            Menus()
        }

        // 2
        MenuBarExtra(currentState) {
            // 3
            Button("proxy on") {
                currentState = "proxy on"
                LocalProxyManager.instance.setProxyOn()
            }
            
            Button("proxy off") {
                currentState = "proxy off"
                LocalProxyManager.instance.setProxyOff()
            }
            Button("check") {
                switch LocalProxyManager.instance.checkState() {
                case .disabled: currentState = "proxy off"
                case .enabled: currentState = "proxy on"
                }
            }
            Button("open") {

            }
        }
    }
}


struct Menus: Commands {
    var body: some Commands {
        CommandGroup(before: .appInfo) {
            Button("nemidanam") {
                print("etelaa E andaram")
            }
        }
    }
}
