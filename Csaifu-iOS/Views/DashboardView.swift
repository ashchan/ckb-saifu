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

    var addresses: [Address] {
        balanceStore.derivedAddresses.compactMap { address in
            balanceStore.addresses[address]
        }
    }

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

            ForEach(addresses, id: \.address) { address in
                AddressRow(address: address)
            }
        }
        .onAppear {
            self.balanceStore.loadBalance()
        }
    }
}

struct AddressRow: View {
    let address: Address

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(address.address)
                    .font(Font.system(.body, design: .monospaced))
            }
            HStack(spacing: 10) {
                Text("\(address.balance.ckbAmount)")
                    .font(Font.system(.body, design: .monospaced))
                    .fontWeight(.bold)

                Text("txs: \(address.transactionsCount)")
            }
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(WalletStore.example)
            .environmentObject(BalanceStore(wallet: WalletStore.example.wallet!))
    }
}
