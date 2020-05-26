//
//  TransactionStore.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/26.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation
import Combine

final class TransactionStore: ObservableObject {
    var addresses = [Address]()
    private var cancellables = [AnyCancellable]()

    @Published var transactions = [Transaction]()

    func load() {
        for address in addresses.filter({ $0.transactionsCount > 0 }) {
            load(for: address)
        }
    }

    private func load(for address: Address) {
        let loader = TransactionLoader(address: address)
        let cancellable = loader.notifier.sink { [weak self] in
            self?.transactions.append(contentsOf: $0)
        }
        cancellables.append(cancellable)

        loader.load()
    }

    class TransactionLoader {
        let address: Address
        var transactions: [Transaction] = []
        var page = 1
        private let per = 50 // Nervos Explorer accepts up to 100
        private var cancellable: AnyCancellable?

        let notifier = PassthroughSubject<[Transaction], Never>()

        private var loadedTransactions: [Transaction] = [] {
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
            let publisher = ExplorerApi
                .fetchCollection(endpoint: .addressTransactions(address: address.address), page: page, perPage: per)
                .replaceError(with: [Transaction]())
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
