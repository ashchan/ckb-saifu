//
//  ContentView.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/21.
//  Copyright © 2020 James Chen. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: WalletStore

    @ViewBuilder
    var body: some View {
        if store.hasWallet {
            DashboardView()
                .environmentObject(BalanceStore())
                .environmentObject(TransactionStore())
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        } else {
            ImportView()
                .frame(minWidth: 800, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(WalletStore.example)
    }
}
