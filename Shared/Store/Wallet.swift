//
//  Wallet.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/21.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation
import CKBFoundation
import CKBKit

struct ExtendedPublicKey: Decodable {
    let raw: String

    var publicKey: Data {
        Data(hex: String(raw.prefix(66)))
    }

    var chainCode: Data {
        Data(hex: String(raw.suffix(64)))
    }

    var keychain: Keychain {
        Keychain(publicKey: publicKey, chainCode: chainCode)
    }

    enum CodingKeys: String, CodingKey {
        case raw = "xpubkey"
    }
}

struct Wallet {
    let xpubkey: ExtendedPublicKey
    var address: String {
        let publicKey = xpubkey.keychain.derivedKeychain(with: "0/0")!.publicKey
        return AddressGenerator.address(for: publicKey, network: .mainnet)
    }

    init?(json: Data) {
        guard let key = try? JSONDecoder().decode(ExtendedPublicKey.self, from: json) else {
            return nil
        }
        xpubkey = key
    }

    init(xpubkey: ExtendedPublicKey) {
        self.xpubkey = xpubkey
    }
}
