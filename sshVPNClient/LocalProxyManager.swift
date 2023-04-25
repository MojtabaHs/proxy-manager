//
//  Manager.swift
//  sshVPNClient
//
//  Created by Malekmatin Ziraksaz on 2/22/23.
//

import SwiftUI
import Foundation
import CoreFoundation
import SystemConfiguration

class LocalProxyManager {
    var networkName = "Wi-Fi"
    var host = "127.0.0.1"
    var port = "1234"
    var state: LocalProxyConnectionState? {
        didSet {
            guard let state else { return }
            switch state {
            case .enabled(.wrong):
                showError = true
                print("enabled wrong")
            case .disabled(.wrong):
                showError = true
                print("disabled wrong")
            default:
                showError = false
                print("else")
            }
            onStateChange?(state)
        }
    }

    var showError: Bool = false {
        didSet {
            showErrorChange?(showError)
        }
    }

    var showErrorChange: ((Bool) -> ())?
    var onStateChange: ((LocalProxyConnectionState) -> ())?

    static let instance = LocalProxyManager()

    func setProxyOn() {
        shell("networksetup -setsocksfirewallproxy \(networkName) \(host) \(port)")
        checkState()
    }

    func setProxyOff() {
        shell("networksetup -setsocksfirewallproxystate Wi-Fi off")
        checkState()
    }

    func saveProxy(host: String, port: String) {
        UserDefaults.standard.set(host, forKey: "localProxyHost")
        UserDefaults.standard.set(port, forKey: "localProxyPort")
        checkState()
    }

    func checkState() -> LocalProxyConnectionState {
        let result = shell("networksetup -getsocksfirewallproxy Wi-Fi")
        let lines = result.split(separator: "\n").map({ String($0) })
        let configs = lines.map { $0.split(separator: ": ").map { String($0) } }
        let configModel = createConfig(strings: configs)
        let dataState = checkDataState(config: configModel)
        let connectionState: LocalProxyConnectionState = configModel.enabled ? .enabled(dataState) : .disabled(dataState)
        state = connectionState
        return connectionState
    }

    func checkDataState(config: LocalProxyConfig) -> LocalProxyDataState {
        UserDefaults.standard.string(forKey: "localProxyHost") == config.server &&
        UserDefaults.standard.string(forKey: "localProxyPort") == config.port
        ? .correct
        : .wrong
    }

    func dataBase() -> (host: String?, port: String?) {
        (
            host: UserDefaults.standard.string(forKey: "localProxyHost"),
            port: UserDefaults.standard.string(forKey: "localProxyPort")
        )
    }

    func createConfig(strings: [[String]]) -> LocalProxyConfig {
        var config = LocalProxyConfig()
        let keyValues = strings.map {
            let key = $0.first!
            let value = $0.last!
            return (key: key, value: value)
        }

        keyValues.forEach {
            switch $0.key {
            case "Enabled":
                config.enabled = $0.value == "Yes"
            case "Server":
                config.server = $0.value
            case "Port":
                config.port = $0.value
            default: return
            }
        }
        return config
    }
}

struct LocalProxyConfig {
    var enabled: Bool = false
    var server: String = ""
    var port: String = ""
}

enum LocalProxyConnectionState {
    case enabled(LocalProxyDataState)
    case disabled(LocalProxyDataState)
}

enum LocalProxyDataState {
    case correct
    case wrong
}
