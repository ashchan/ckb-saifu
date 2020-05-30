//
//  ApiEntity.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/24.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation

struct ApiErrorMessage: Codable {
    let title: String
    let detail: String
    let code: Int
    let status: Int
}

struct Result<T>: Codable where T: Codable {
    let data: T
}

struct PaginatedResult<T>: Codable where T: Codable {
    let data: [T]
    let meta: Meta
    let links: Links

    struct Meta: Codable {
        let total: Int
        let pageSize: Int
    }

    struct Links: Codable {
        let `self`: String
        let first: String?
        let prev: String?
        let next: String?
        let last: String?
    }
}

struct Api {
    struct Address: Codable {
        let id: String
        let attributes: Attributes

        var address: String { attributes.addressHash }
        var balance: UInt64 { UInt64(attributes.balance) ?? 0 }
        var transactionsCount: Int { Int(attributes.transactionsCount) ?? 0 }

        init(address: String, balance: String = "0") {
            id = ""
            attributes = Attributes(
                addressHash: address,
                balance: balance,
                transactionsCount: "0"
            )
        }

        struct Attributes: Codable {
            let addressHash: String
            let balance: String
            let transactionsCount: String
        }
    }

    struct Transaction: Codable {
        let id: String
        let attributes: Attributes

        var hash: String { attributes.transactionHash }
        var block: UInt64 { UInt64(attributes.blockNumber) ?? 0 }
        var date: Date { Date(timeIntervalSince1970: (TimeInterval(attributes.blockTimestamp) ?? 0) / 1000) }
        var fee: UInt64 { UInt64(attributes.transactionFee) ?? 0 }
        var income: Int64 { Int64(attributes.income.dropLast(2)) ?? 0 } // Last two digits are `.0`

        struct Attributes: Codable {
            let transactionHash: String
            let blockNumber: String
            let blockTimestamp: String
            let transactionFee: String
            let income: String
        }
    }
}

