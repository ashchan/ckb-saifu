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

    var balance: UInt64 { walletStore.balance }
    @FetchRequest(
        entity: Tx.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Tx.date, ascending: false)
        ]
    ) var transactions: FetchedResults<Tx>

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
                }

                if walletStore.transactionsCount > 0 && transactions.isEmpty {
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

                ForEach(transactions, id: \.hash) { tx in
                    TransactionRow(transaction: tx)
                }
            }.navigationBarTitle("Transactions")
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
                    .truncationMode(.middle)
                    .lineLimit(1)
                    .font(Font.system(.footnote, design: .monospaced))

            }

            HStack(spacing: 10) {
                Text(Self.dateFormatter.string(from: transaction.date!))
                Text("#\(transaction.block)")
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
