//
//  LauncControlManager.swift
//  sshVPNClient
//
//  Created by Malekmatin Ziraksaz on 4/25/23.
//

import Foundation

class LaunchControlManager {
    static let instance = LaunchControlManager()
    let configLocation = "~/Library/LaunchAgents/com.napsternet.proxy.plist"
    private init() {}

    var state: LaunchAgentState = .doesNotContainConfigFile

    func checkState() {
        guard hasConfigFile() else { state = .doesNotContainConfigFile; return }
        let launchedAgents = shell("launchctl list").split(separator: "\n").map { String($0) }
        let isUp = launchedAgents.contains(where: { $0.contains("com.napsternet.proxy") })
        state = isUp ? .loaded : .notLoaded
    }

    func load() {
        shell("launchctl load \(configLocation)")
        checkState()
    }

    func unload() {
        shell("launchctl unload \(configLocation)")
        checkState()
    }

    func hasConfigFile() -> Bool {
        shell("test -f \(configLocation) && echo \"exists\"") == "exists"
    }
}


enum LaunchAgentState {
    case doesNotContainConfigFile
    case notLoaded
    case loaded
}
