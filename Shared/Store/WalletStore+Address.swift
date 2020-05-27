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

#if os(macOS)

import Cocoa
typealias Application = NSApplication

#else

import UIKit
typealias Application = UIApplication

#endif

/// Address derivation & management
extension WalletStore {
    enum AddressChange: Int32 {
        case receiving = 0
        case change = 1
    }

    var addresses: [Address] {
        let request = managedObjectModel.fetchRequestFromTemplate(withName: "FetchAllAddresses", substitutionVariables: [:]) as! NSFetchRequest<Address>
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

    func deleteAllAddresses() {
        let request = NSBatchDeleteRequest(fetchRequest: Address.fetchRequest())
        request.resultType = .resultTypeObjectIDs
        do {
            let _ = try managedObjectContext.execute(request) as! NSBatchDeleteResult
            /*
            let changes: [AnyHashable: Any] = [
                NSDeletedObjectsKey: result.result as! [NSManagedObjectID]
            ]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [managedObjectContext])
            */
        } catch {
            print("Delete address DB error: " + error.localizedDescription)
        }
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
    var managedObjectContext: NSManagedObjectContext {
        (Application.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    var managedObjectModel: NSManagedObjectModel {
        (Application.shared.delegate as! AppDelegate).persistentContainer.managedObjectModel
    }

    func deriveAddress(type: AddressChange, index: Int32) -> String {
        let path = "\(type.rawValue)/\(index)"
        let publicKey = wallet!.xpubkey.keychain.derivedKeychain(with: path)!.publicKey
        return AddressGenerator.address(for: publicKey, network: .mainnet)
    }

    func lastAddress(type: AddressChange) -> Address? {
        let request = managedObjectModel.fetchRequestFromTemplate(withName: type.fetchRequestName, substitutionVariables: [:]) as! NSFetchRequest<Address>
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Address.index, ascending: true)]
        do {
            let addresses = try managedObjectContext.fetch(request)
            return addresses.last
        } catch {
            print("Loading addresses error: " + error.localizedDescription)
            return nil
        }
    }

    func deriveAddresses(type: AddressChange) {
        var start: Int32 = 0
        if let last = lastAddress(type: type) {
            start = last.index + 1
        }
        for index in start ..< start + addressDerivationBatchSize {
            let address = Address(context: managedObjectContext)
            address.address = deriveAddress(type: type, index: index)
            address.change = type.rawValue
            address.index = index
        }

        try? managedObjectContext.save()
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

                if result.transactionsCount > 0 {
                    self?.deriveAddresses(type: type)
                }
            })
    }
}
