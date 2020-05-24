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
    private(set) var recevingAddresses = [String]()
    private(set) var changeAddresses = [String]()
    var derivedAddresses: [String] { recevingAddresses + changeAddresses }

    @Published var balance: UInt64 = 0
    @Published var addresses = [String: Address]()

    init(wallet: Wallet) {
        self.wallet = wallet

        deriveAddresses(true)
        deriveAddresses(false)
    }

    private func calcTotal() {
        balance = addresses.values.map { $0.balance }.reduce(0, +)
    }

    private func update(address: Address) {
        if address.transactionsCount > 0 && addresses[address.address]?.balance != address.balance {
            addresses[address.address] = address
            calcTotal()
        }
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
                    self?.update(address: result)
                })
        }
    }
}

// MARK: - Derivate addresses
private extension BalanceStore {
    var batchSize: Int { 20 }

    var extendedKey: Keychain {
         Keychain(publicKey: wallet.xpubkey.publicKey, chainCode: wallet.xpubkey.chainCode)
    }

    func deriveAddress(path: String) -> String {
        let publicKey = extendedKey.derivedKeychain(with: path)!.publicKey
        return AddressGenerator.address(for: publicKey, network: .mainnet)
    }

    func deriveAddresses(_ receiving: Bool = true) {
        let start = receiving ? recevingAddresses.count : changeAddresses.count
        for index in start ..< start + batchSize {
            let address: String
            if receiving {
                address = deriveAddress(path: "0/\(index)")
                recevingAddresses.append(address)
            } else {
                address = deriveAddress(path: "1/\(index)")
                changeAddresses.append(address)
            }
            addresses[address] = Address(address: address)
        }

        let lastAddress = receiving ? recevingAddresses.last! : changeAddresses.last!
        _ = ExplorerApi
            .fetch(endpoint: .addresses(address: lastAddress))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (error) in
                print(error)
            }, receiveValue: { [weak self] (result: Address) in
                self?.update(address: result)

                if result.transactionsCount > 0 {
                    self?.deriveAddresses(receiving)
                }
            })
    }
}
