//
//  AppDelegate.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/21.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Cocoa
import SwiftUI

typealias Application = NSApplication

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    private var walletStore = WalletStore()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores { description, error in
            if let error = error {
            }
        }
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save core data error: " + error.localizedDescription)
            }
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.tabbingMode = .disallowed
        window.center()
        window.setFrameAutosaveName("Main Window")
        window.title = "CKB Saifu"

        let contentView = ContentView()
            .environment(\.managedObjectContext, persistentContainer.viewContext)
            .environmentObject(walletStore)

        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationDidResignActive(_ notification: Notification) {
        saveContext()
    }
}

extension AppDelegate: NSUserInterfaceValidations {
    @IBAction func openDocument(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.message = "Select an extended public key file."
        panel.allowedFileTypes = [kUTTypeJSON as String]
        panel.beginSheetModal(for: window!) { (result) in
            if result == .OK, let path = panel.url {
                self.walletStore.import(path: path)
            }
        }
    }

    @IBAction func deleteWallet(_ sender: Any?) {
        walletStore.delete()
    }

    func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        switch item.action {
        case #selector(openDocument(_:)):
            return !walletStore.hasWallet
        case #selector(deleteWallet(_:)):
            return walletStore.hasWallet
        default:
            return true
        }
    }
}
