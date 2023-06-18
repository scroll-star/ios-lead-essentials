//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 13.06.23.
//

import CoreData

extension NSPersistentContainer {

    enum LoadingError: Swift.Error {
        case failedToLoadPersistentStores(Swift.Error)
    }

    static func load(
        modelName name: String,
        model: NSManagedObjectModel,
        url: URL,
        in bundle: Bundle
    ) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]

        var loadError: Swift.Error?
        container.loadPersistentStores { loadError = $1 }
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }

        return container
    }
}

extension NSManagedObjectModel {

    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
