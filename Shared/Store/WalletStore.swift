//
//  WalletStore.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/21.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation
import KeychainAccess

final class WalletStore: ObservableObject {
    @Published var wallet: Wallet?
    @Published var balance: UInt64 = 0
    @Published var transactionsCount: Int = 0

    var hasWallet: Bool { wallet != nil }

    private static let keychainService = "com.ashchan.ckb-saifu"
    private static let keychainKey = "wallet"

    init() {
        let keychain = Keychain(service: Self.keychainService)
        if let saved = keychain[Self.keychainKey] {
            wallet = Wallet(xpubkey: ExtendedPublicKey(raw: saved))
            calculateTotal()
        }
    }

    private func persist(wallet: Wallet) {
        let keychain = Keychain(service: Self.keychainService)
        keychain[Self.keychainKey] = wallet.xpubkey.raw
    }
}

extension WalletStore: CoreDataSupport {}

// MARK: - Create/Destory
extension WalletStore {
    func `import`(path: URL) {
        // TODO: error handling
        #if os(macOS)
        guard let content = try? Data(contentsOf: path) else {
            return // Cannot read file
        }
        #else
        guard let content = iOSreadFile(url: path) else {
            return // Cannot read file
        }
        #endif
        guard let wallet = Wallet(json: content) else {
            return // File format doesn't match
        }
        self.wallet = wallet
        persist(wallet: wallet)

        deriveInitialAddresses()
        deriveAddressesIfNessary()
    }

    func delete() {
        wallet = nil
        let keychain = Keychain(service: Self.keychainService)
        keychain[Self.keychainKey] = nil

        deleteAllAddresses()
    }

    private func iOSreadFile(url: URL) -> Data? {
        guard url.startAccessingSecurityScopedResource() else {
            return nil
        }
        defer { url.stopAccessingSecurityScopedResource() }

        var error: NSError? = nil
        var result: Data?
        NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { (url) in
            result = try? Data(contentsOf: url)
        }

        return result
    }
}

// MARK: - For preview only
#if DEBUG
extension WalletStore {
    static var example: WalletStore {
        let xpubkey = "03e15b08cd5f04a2263f614ae788ec7efc16f23aad8bf427548674d2720887976f" +
            "1281863be3136a102e5bcb545d97192071f11cb50a63e7ef535c63449900b2e9"
        let store = WalletStore()
        store.wallet = Wallet(xpubkey: ExtendedPublicKey(raw: xpubkey))
        return store
    }
}
#endif
