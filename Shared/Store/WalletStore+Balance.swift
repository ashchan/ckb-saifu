//
//  WalletStore+Balance.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/28.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation
import CoreData

extension WalletStore {
    func calculateTotal() {
        let request: NSFetchRequest<NSFetchRequestResult> = Address.fetchRequest()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [
            NSExpressionDescription.description(
                for: "balance",
                expression: NSExpression(format: "@sum.balance"),
                resultType: .integer64AttributeType
            ),
            NSExpressionDescription.description(
                for: "txCount",
                expression: NSExpression(format: "@sum.txCount"),
                resultType: .integer32AttributeType
            ),
        ]
        let results = try? managedObjectContext.fetch(request) as? [[String: AnyObject]]
        if let result = results?.first {
            balance = result["balance"] as? UInt64 ?? 0
            transactionsCount = result["txCount"] as? Int ?? 0
        }
    }

    func loadBalance() {
        for address in addresses {
            _ = ExplorerApi
                .fetch(endpoint: .addresses(address: address.address!))
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print(error.localizedDescription)
                    }
                }, receiveValue: { [weak self] (result: Api.Address) in
                    self?.update(address: result)
                })
        }
    }

    private func update(address: Api.Address) {
        if address.transactionsCount == 0 && address.balance == 0 {
            return
        }

        let entity = addresses.first(where: { $0.address == address.address })!
        entity.balance = Int64(address.balance)
        entity.txCount = Int32(address.transactionsCount)
        try? managedObjectContext.save()

        calculateTotal()
    }
}
