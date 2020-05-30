//
//  ContentView.swift
//  Csaifu-iOS
//
//  Created by James Chen on 2020/05/24.
//  Copyright © 2020 James Chen. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: WalletStore

    @ViewBuilder
    var body: some View {
        if store.hasWallet {
            DashboardView()
        } else {
            ImportView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(WalletStore.example)
    }
}
