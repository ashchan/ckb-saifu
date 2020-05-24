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

struct Address: Codable {
    let id: String
    let type: String
    let attributes: Attributes

    var address: String { attributes.addressHash }
    var balance: UInt64 { UInt64(attributes.balance) ?? 0 }
    var transactionsCount: Int { Int(attributes.transactionsCount) ?? 0 }

    init(address: String, balance: String = "0") {
        id = ""
        type = "address"
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
