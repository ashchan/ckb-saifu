//
//  ImportView.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/21.
//  Copyright © 2020 James Chen. All rights reserved.
//

import SwiftUI

struct ImportView: View {
    @EnvironmentObject private var walletStore: WalletStore
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

    private func selectFile() {
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
    }
}
