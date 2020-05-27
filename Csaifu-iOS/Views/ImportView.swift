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
    @State private var pickerPresented = false

    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Text("🔑")
                    .font(Font.system(size: 80))
                Text("Import extended public key")
            }

            HStack {
                Button(action: {
                    self.selectFile()
                }) {
                    Text("Select file")
                }
            }

            Text("From Neuron, choose 'Wallet > Export Extended Public Key' to get your file.\nThen save that file to one of your iCloud folders.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(10)
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .sheet(isPresented: $pickerPresented, onDismiss: {
            self.pickerPresented = false
        }) {
            FilePicker(callback: self.loadFile(_:))
        }
    }

    private func selectFile() {
        pickerPresented.toggle()
    }

    private func loadFile(_ path: URL) {
        walletStore.import(path: path)
    }
}

struct FilePicker: UIViewControllerRepresentable {
    var callback: (URL) -> ()

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<FilePicker>) {
        // Update the controller
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(documentTypes: ["public.json"], in: .open)
        controller.delegate = context.coordinator
        return controller
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: FilePicker

        init(_ pickerController: FilePicker) {
            self.parent = pickerController
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.callback(urls[0])
        }

        func documentPickerWasCancelled() {
        }
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ImportView()
                .colorScheme(.light)

            ImportView()
                .background(Color(UIColor.systemBackground))
                .colorScheme(.dark)
        }
    }
}
