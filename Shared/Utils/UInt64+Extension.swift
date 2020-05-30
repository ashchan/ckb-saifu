//
//  UInt64+Extension.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/24.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation

extension UInt64 {
    static let ckbAmountSeparatorFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.groupingSeparator = ","
        formatter.numberStyle = .decimal
        return formatter
    }()

    var ckbAmount: String {
        let integer = Self.ckbAmountSeparatorFormatter.string(for: self / 100_000_000) ?? "0"
        var fraction = String(format: "%08d", self % 100_000_000)
        while fraction.last == "0" && fraction.count > 1 {
            fraction = String(fraction.dropLast())
        }
        return "\(integer).\(fraction)"
    }
}

extension Int64 {
    var ckbAmount: String {
        let sign = self < 0 ? "-" : ""
        return sign + UInt64(abs(self)).ckbAmount
    }
}
