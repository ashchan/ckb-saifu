//
//  WalletStore+Balance.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/28.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation

extension WalletStore {
    private func calcTotal() {
        balance = UInt64(addresses.map { $0.balance }.reduce(0, +))
        transactionsCount = Int(addresses.map { $0.txCount }.reduce(0, +))
    }

    private func update(address: Api.Address) {
        if address.transactionsCount == 0 && address.balance == 0 {
            return
        }

        let entity = addresses.first(where: { $0.address == address.address })!
        entity.balance = Int64(address.balance)
        entity.txCount = Int32(address.transactionsCount)

        calcTotal()
    }

    func loadBalance() {
        for address in addresses {
            _ = ExplorerApi
                .fetch(endpoint: .addresses(address: address.address!))
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] (result: Api.Address) in
                    self?.update(address: result)
                })
        }
    }
}
