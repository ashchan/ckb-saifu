//
//  ImportView.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/21.
//  Copyright © 2020 James Chen. All rights reserved.
//

import SwiftUI

struct ImportView: View, DropDelegate {
    @EnvironmentObject private var walletStore: WalletStore
    @Environment(\.window) private var window
    @State private var draggingOver = false

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("🔑")
                    .font(Font.system(size: 80))
                Text("Drag and drop extended public key file here")
            }
            .padding(40)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(
                        style: StrokeStyle(
                            lineWidth: 4,
                            dash: [8]
                        )
                    )
                    .foregroundColor(draggingOver ? .accentColor : .gray)
            )
            .onDrop(of: [kUTTypeFileURL as String], delegate: self)

            HStack {
                Text("or")
                Button(action: {
                    self.selectFile()
                }) {
                    Text("Select a file")
                }
            }

            Text("From Neuron, choose 'Wallet > Export Extended Public Key' to get your file.")
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
                .foregroundColor(.gray)
        }
    }

    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [(kUTTypeFileURL as String)]).first else {
            return false
        }

        itemProvider.loadItem(forTypeIdentifier: (kUTTypeFileURL as String), options: nil) { item, error in
            guard let data = item as? Data, let content = URL(dataRepresentation: data, relativeTo: nil) else {
                return
            }
            DispatchQueue.main.async {
                self.loadFile(path: content)
            }
        }

        return true
    }

    func validateDrop(info: DropInfo)-> Bool {
        return info.hasItemsConforming(to: [kUTTypeFileURL as String]) &&
            info.itemProviders(for: [(kUTTypeFileURL as String)]).count == 1
    }

    func dropEntered(info: DropInfo) {
        draggingOver = true
    }

    func dropExited(info: DropInfo) {
        draggingOver = false
    }

    private func selectFile() {
        let panel = NSOpenPanel()
        panel.message = "Select an extended public key file."
        panel.allowedFileTypes = [kUTTypeJSON as String]
        panel.beginSheetModal(for: window!) { (result) in
            if result == .OK, let path = panel.url {
                self.loadFile(path: path)
            }
        }
    }

    private func loadFile(path: URL) {
        walletStore.import(path: path)
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
           ImportView()
              .environment(\.colorScheme, .light)

           ImportView()
              .environment(\.colorScheme, .dark)
        }
        .frame(minWidth: 800, minHeight: 600)
    }
}