//
//  ExplorerApi.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/24.
//  Copyright © 2020 James Chen. All rights reserved.
//

import Foundation
import Combine

enum ApiError: Error {
    case message(reason: String)
}

struct ExplorerApi {
    private static let server = "https://api.explorer.nervos.org/api/v1/"

    private static let apiQueue = DispatchQueue(
        label: "ckb_saifu_explorer_api",
        qos: .userInitiated,
        attributes: .concurrent
    )
    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static func fetch<T: Codable>(endpoint: Endpoint) -> AnyPublisher<T, ApiError> {
        URLSession.shared
            .dataTaskPublisher(for: buildRequest(endpoint: endpoint))
            .map(\.data)
            .map { d in
                // For debug http response
                // print(String(data: d, encoding: .utf8))
                return d
            }
            .replaceError(with: Data())
            .decode(type: Result<T>.self, decoder: decoder)
            .mapError({ (error) -> ApiError in
                ApiError.message(reason: error.localizedDescription)
            })
            .map { $0.data }
            .subscribe(on: apiQueue)
            .eraseToAnyPublisher()
    }

    static func fetchCollection<T: Codable>(endpoint: Endpoint, page: Int = 1, perPage: Int = 50) -> AnyPublisher<[T], ApiError> {
        URLSession.shared
            .dataTaskPublisher(for: buildRequest(endpoint: endpoint, params: ["page": "\(page)", "page_size": "\(perPage)"]))
            .map(\.data)
            .map { d in
                // For debug http response
                // print(String(data: d, encoding: .utf8))
                return d
            }
            .replaceError(with: Data())
            .decode(type: PaginatedResult<T>.self, decoder: decoder)
            .mapError({ (error) -> ApiError in
                ApiError.message(reason: error.localizedDescription)
            })
            .map { $0.data }
            .subscribe(on: apiQueue)
            .eraseToAnyPublisher()
    }

    private static func buildRequest(endpoint: Endpoint, params: [String: String] = [:]) -> URLRequest {
        var components = URLComponents(string: [server, endpoint.path].joined(separator: "/"))!
        components.queryItems = params.map({ (name, value) in
            URLQueryItem(name: name, value: value)
        })

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.addValue("application/vnd.api+json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/vnd.api+json", forHTTPHeaderField: "Accept")

        return request
    }
}

extension ExplorerApi {
    enum Endpoint {
        case addressTransactions(address: String)
        case addresses(address: String)

        var path: String {
            switch self {
            case .addressTransactions(let address):
                return "address_transactions/\(address)"
            case .addresses(let address):
                return "addresses/\(address)"
            }
        }
    }
}
