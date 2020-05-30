//
//  WalletStore+AddressDerivation.swift
//  Csaifu
//
//  Created by James Chen on 2020/05/27.
//  Copyright © 2020 James Chen. All rights reserved.
//

import CoreData
import CKBFoundation
import CKBKit

/// Address derivation & management
extension WalletStore {
    enum AddressChange: Int32 {
        case receiving = 0
        case change = 1
    }

    var addresses: [Address] {
        let request: NSFetchRequest = Address.fetchRequest()
        return try! managedObjectContext.fetch(request)
    }

    func deriveInitialAddresses() {
        deriveAddresses(type: .receiving)
        deriveAddresses(type: .change)
    }

    func deriveAddressesIfNessary() {
        deriveMoreAddressesIfNecessary(type: .receiving)
        deriveMoreAddressesIfNecessary(type: .change)
    }
}

extension WalletStore.AddressChange {
    var fetchRequestName: String {
        switch self {
        case .receiving:
            return "FetchReceivingAddresses"
        case .change:
            return "FetchChangeAddresses"
        }
    }
}

private extension WalletStore {
    var addressDerivationBatchSize: Int32 { 20 }
    func deriveAddress(type: AddressChange, index: Int32) -> String {
        let path = "\(type.rawValue)/\(index)"
        let publicKey = wallet!.xpubkey.keychain.derivedKeychain(with: path)!.publicKey
        return AddressGenerator.address(for: publicKey, network: .mainnet)
    }

    func lastAddress(type: AddressChange) -> Address? {
        let request = managedObjectModel.fetchRequestFromTemplate(withName: type.fetchRequestName, substitutionVariables: [:]) as! NSFetchRequest<Address>
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Address.index, ascending: false)]
        request.fetchLimit = 1
        do {
            let addresses = try managedObjectContext.fetch(request)
            return addresses.first
        } catch {
            print("Loading last addresses error: " + error.localizedDescription)
            return nil
        }
    }

    func deriveAddresses(type: AddressChange) {
        var start: Int32 = 0
        if let last = lastAddress(type: type) {
            start = last.index + 1
        }
        let addresses = (start ..< start + addressDerivationBatchSize).map { index -> [String: Any] in
            [
                "address": deriveAddress(type: type, index: index),
                "change": type.rawValue,
                "index": index,
            ]
        }

        let request = NSBatchInsertRequest(entity: Address.entity(), objects: addresses)
        request.resultType = .objectIDs
        do {
            let result = try managedObjectContext.execute(request) as! NSBatchInsertResult
            if let objectIDs = result.result as? [NSManagedObjectID], !objectIDs.isEmpty {
                let changes = [NSInsertedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [managedObjectContext])
            }
        } catch {
            print("Saving address DB error: " + error.localizedDescription)
        }
    }

    func deriveMoreAddressesIfNecessary(type: AddressChange) {
        let last = lastAddress(type: type)!
        _ = ExplorerApi
            .fetch(endpoint: .addresses(address: last.address!))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            }, receiveValue: { [weak self] (result: Api.Address) in
                last.balance = Int64(result.balance) // No one would own half of the coins, right?
                last.txCount = Int32(result.transactionsCount)
                try? self?.managedObjectContext.save()

                if result.transactionsCount > 0 {
                    self?.deriveAddresses(type: type)
                }
            })
    }
}
