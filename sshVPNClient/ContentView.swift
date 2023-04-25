//
//  ContentView.swift
//  sshVPNClient
//
//  Created by Malekmatin Ziraksaz on 2/16/23.
//

import SwiftUI

struct ContentView: View {
    @State var host: String = ""
    @State var port: String = ""
    @State var username: String = ""
    @State var password: String = ""
    @State var localPort: String = ""

    @State var showError: Bool = false
    @State var isConnected: Bool = false

    var body: some View {
        VStack {

            if isConnected {
                Text("Connected")
                    .foregroundColor(.green)
            } else {
                Text("Disconnected")
                    .foregroundColor(.red)
            }

            TextField("host", text: $host)
                .frame(maxWidth: 300)
            TextField("port", text: $port)
                .frame(maxWidth: 300)

            Button("save") {
                LocalProxyManager.instance.saveProxy(host: host, port: port)
            }

            Text("connection data is not same as data base")
                .opacity(showError ? 1 : 0)
            Text("save the data or click on reconfig")
                .opacity(showError ? 1 : 0)
        }
        .padding()
        .onAppear {
            LocalProxyManager.instance.showErrorChange = {
                showError = $0
            }

            LocalProxyManager.instance.onStateChange = {
                if case .enabled = $0 { isConnected = true } else { isConnected = false }
            }

            let db = LocalProxyManager.instance.dataBase()
            self.host = db.host ?? ""
            self.port = db.port ?? ""
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
