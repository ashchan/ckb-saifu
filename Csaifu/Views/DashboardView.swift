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

    var body: some View {
        VStack {
            Text("Dashboard")
            Text(walletStore.wallet!.address)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(WalletStore.example)
            .frame(minWidth: 800)
    }
}
