//
//  WalleltStore+Transactions.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/30.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation
import CoreData
import Combine

extension WalletStore {
    func loadTransactions() {
        for address in addresses.filter({ $0.txCount > 0 }) {
            loadTransactions(for: address)
        }
    }

    private func loadTransactions(for address: Address) {
        let loader = TransactionLoader(address: address)
        loader.notifier.sink { [weak self] in
            self?.persist(transactions: $0)
        }.store(in: &txLoadCancellables)

        loader.load()
    }

    private func persist(transactions: [Api.Transaction]) {
        let txs = transactions.map { tx -> [String: Any]  in
            [
                "txHash": tx.hash,
                "block": tx.block,
                "date": tx.date,
                "fee": tx.fee,
                "estimatedAmount": tx.income,
            ]
        }
        let request = NSBatchInsertRequest(entity: Tx.entity(), objects: txs)
        request.resultType = .objectIDs
        do {
            let result = try managedObjectContext.execute(request) as! NSBatchInsertResult
            if let objectIDs = result.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let changes = [NSInsertedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [managedObjectContext])
            }
        } catch {
            print("Saving transaction DB error: " + error.localizedDescription)
        }
    }

    class TransactionLoader {
        let address: Address
        var transactions: [Api.Transaction] = []
        var page = 1
        private let per = 50 // Nervos Explorer accepts up to 100
        private var cancellable: AnyCancellable?

        let notifier = PassthroughSubject<[Api.Transaction], Never>()

        private var loadedTransactions: [Api.Transaction] = [] {
            didSet {
                if page == 1 {
                    transactions = []
                }
                transactions.append(contentsOf: loadedTransactions)
                notifier.send(loadedTransactions)

                fetchNext()
            }
        }

        init(address: Address) {
            self.address = address
        }

        func load() {
            transactions = []
            page = 1
            fetch()
        }

        func fetch() {
            guard let address = address.address else { return }
            let publisher = ExplorerApi
                .fetchCollection(endpoint: .addressTransactions(address: address), page: page, perPage: per)
                .replaceError(with: [Api.Transaction]())
                .eraseToAnyPublisher()
            cancellable = publisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.loadedTransactions, on: self)
        }

        func fetchNext() {
            guard transactions.count == page * per else {
                // Reached last page
                return
            }
            page += 1
            fetch()
        }
    }
}

