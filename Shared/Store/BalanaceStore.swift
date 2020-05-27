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
    var addresses = [Address]()
    @Published var balance: UInt64 = 0
    @Published var transactionsCount: Int = 0

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
