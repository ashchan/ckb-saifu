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

    var balance: UInt64 { balanceStore.balance }

    var body: some View {
        List {
            HStack(alignment: .bottom, spacing: 10) {
                Text("Balance:")
                    .font(Font.system(.title))
                Text("\(balance.ckbAmount)")
                    .font(Font.system(.title, design: .monospaced))
                    .fontWeight(.bold)
            }

            HStack(alignment: .bottom, spacing: 10) {
                Text("Txs:")
                    .font(Font.system(.subheadline))
                Text("\(balanceStore.transactionsCount)")
                    .font(Font.system(.subheadline))

                if balanceStore.transactionsCount > 0 {
                    Button(action: {
                        self.loadTransactions()
                    }) {
                        Text("Load transactions")
                    }
                }
            }

            ForEach(transactionStore.transactions.sorted(by: { $1.block < $0.block }), id: \.hash) { tx in
                TransactionRow(transaction: tx)
            }
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
        formatter.dateStyle = .short
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(transaction.hash)
                    .font(Font.system(.body, design: .monospaced))

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
            .frame(minWidth: 800, minHeight: 400)
    }
}
