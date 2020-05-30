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
    @FetchRequest(
        entity: Tx.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Tx.date, ascending: false)
        ]
    ) var transactions: FetchedResults<Tx>

    var balance: UInt64 { walletStore.balance }

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
                if walletStore.transactionsCount > 0 {
                    Button(action: {
                        self.loadTransactions()
                    }) {
                        Text("Load transactions")
                    }
                }
            }

            ForEach(transactions, id: \.hash) { tx in
                TransactionRow(transaction: tx)
            }
        }
        .onAppear {
            self.walletStore.loadBalance()
        }
    }
}

private extension DashboardView {
    func loadTransactions() {
        walletStore.loadTransactions()
    }
}

struct TransactionRow: View {
    let transaction: Tx
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(transaction.txHash!)
                    .font(Font.system(.body, design: .monospaced))

            }

            HStack(spacing: 10) {
                Text(Self.dateFormatter.string(from: transaction.date!))
                Text("#\(transaction.block)")
                Text(transaction.estimatedAmount.ckbAmount)
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(WalletStore.example)
    }
}
