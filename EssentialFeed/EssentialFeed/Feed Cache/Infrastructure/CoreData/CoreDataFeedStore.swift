//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Stoyan Kostov on 13.06.23.
//

import CoreData

public final class CoreDataFeedStore {
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataFeedStore.self))

    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
    }

    public init(storeURL: URL) throws {
        let bundle = Bundle(for: CoreDataFeedStore.self)

        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }

        container = try NSPersistentContainer.load(modelName: Self.modelName, model: model, url: storeURL, in: bundle)
        context = container.newBackgroundContext()
    }

    deinit {
        cleanUpReferencesToPersistentStores()
    }

    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }

    private func cleanUpReferencesToPersistentStores() {
        context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
}
