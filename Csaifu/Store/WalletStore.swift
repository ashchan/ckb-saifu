//
//  WalletStore.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/21.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation

final class WalletStore: ObservableObject {
    @Published var wallet: Wallet?
    var hasWallet: Bool { wallet != nil }

    func `import`(path: URL) {
        guard let content = try? Data(contentsOf: path) else {
            return // Cannot read file
        }
        guard let wallet = Wallet(json: content) else {
            return // File format doesn't match
        }
        // TODO: persiste (in keychain?)
        self.wallet = wallet
    }
}

extension WalletStore {
    static var example: WalletStore {
        let xpubkey = "03e15b08cd5f04a2263f614ae788ec7efc16f23aad8bf427548674d2720887976f" +
            "1281863be3136a102e5bcb545d97192071f11cb50a63e7ef535c63449900b2e9"
        let store = WalletStore()
        store.wallet = Wallet(xpubkey: ExtendedPublicKey(xpubkey: xpubkey))
        return store
    }
}
