//
//  BalanaceStroe.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/24.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation
import CKBFoundation
import CKBKit

final class BalanceStore: ObservableObject {
    private let wallet: Wallet
    var recevingAddresses = [String]()
    var changeAddresses = [String]()
    var derivedAddresses: [String] { recevingAddresses + changeAddresses }

    @Published var balance: UInt64 = 0
    @Published var addresses = [String: Address]()

    init(wallet: Wallet) {
        self.wallet = wallet

        let extendedKey = Keychain(publicKey: wallet.xpubkey.publicKey, chainCode: wallet.xpubkey.chainCode)
        for index in 0..<20 {
            let publicKey = extendedKey.derivedKeychain(with: "0/\(index)")!.publicKey
            let address = AddressGenerator.address(for: publicKey, network: .mainnet)
            recevingAddresses.append(address)
        }
        for index in 0..<20 {
            let publicKey = extendedKey.derivedKeychain(with: "1/\(index)")!.publicKey
            let address = AddressGenerator.address(for: publicKey, network: .mainnet)
            changeAddresses.append(address)
        }
    }

    private func calcTotal() {
        balance = addresses.values.map { $0.balance }.reduce(0, +)
    }

    func loadBalance() {
        // TODO: rate limit
        for address in derivedAddresses {
            _ = ExplorerApi
                .fetch(endpoint: .addresses(address: address))
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (error) in
                    print(error)
                }, receiveValue: { [weak self] (result: Address) in
                    self?.addresses[result.address] = result
                    self?.calcTotal()
                })
        }
    }
}
