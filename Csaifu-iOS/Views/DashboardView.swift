//
//  DashboardView.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/21.
//  Copyright © 2020 James Chen. All rights reserved.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var walletStore: WalletStore
    @EnvironmentObject private var balanceStore: BalanceStore
    @EnvironmentObject private var transactionStore: TransactionStore

    var addresses: [Api.Address] {
        balanceStore.derivedAddresses.compactMap { address in
            balanceStore.addresses[address]
        }
    }

    var balance: UInt64 { balanceStore.balance }

    var body: some View {
        NavigationView {
            List {
                HStack(alignment: .bottom, spacing: 8) {
                    Text("Balance:")
                        .font(Font.system(.subheadline))
                    Text("\(balance.ckbAmount)")
                        .font(Font.system(.subheadline, design: .monospaced))
                        .fontWeight(.bold)
                    Spacer()
                    Text("Txs:")
                        .font(Font.system(.subheadline))
                    Text("\(balanceStore.transactionsCount)")
                        .font(Font.system(.subheadline))
                }

                if balanceStore.transactionsCount > 0 && transactionStore.transactions.isEmpty {
                    HStack(alignment: .center, spacing: 10) {
                        Spacer()
                        Button(action: {
                            self.loadTransactions()
                        }) {
                            HStack {
                                Image(systemName: "arrow.down.circle")
                                    .font(.body)
                                Text("Load txs")
                                    .fontWeight(.semibold)
                                    .font(.body)
                            }
                            .padding(5)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(15)
                        }
                        Spacer()
                    }
                }

                ForEach(transactionStore.transactions.sorted(by: { $1.block < $0.block }), id: \.hash) { tx in
                    TransactionRow(transaction: tx)
                }
            }.navigationBarTitle("Transactions")
        }
        .onAppear {
            self.balanceStore.loadBalance()
        }
    }
}

private extension DashboardView {
    func loadTransactions() {
        transactionStore.addresses = Array(balanceStore.addresses.values)
        transactionStore.load()
    }
}

struct TransactionRow: View {
    let transaction: Api.Transaction
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(transaction.hash)
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .font(Font.system(.footnote, design: .monospaced))

            }

            HStack(spacing: 10) {
                Text(Self.dateFormatter.string(from: transaction.date))
                Text("#\(transaction.block)")
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(WalletStore.example)
            .environmentObject(BalanceStore(wallet: WalletStore.example.wallet!))
            .environmentObject(TransactionStore())
    }
}
