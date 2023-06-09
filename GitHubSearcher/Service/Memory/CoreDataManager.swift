//
//  CoreDataManager.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//

import UIKit
import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: AppConstants.Strings.CoreData.containerName)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    private lazy var viewContext = persistentContainer.viewContext

    private init() {}

    /// Saves changes to the managed object context, if any changes exist.
    private func saveContext() {
        if viewContext.hasChanges {
            try? viewContext.save()
        }
    }

    /// Checks whether a repository with the given ID is marked as a favorite.
    /// - Parameter repositoryID: The ID of the repository to check.
    /// - Returns: `true` if the repository is marked as a favorite, `false` otherwise.
    func isFavorite(_ repositoryID: Int) -> Bool {
        let fetchRequest: NSFetchRequest<RepositoryEntity> = RepositoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "repositoryID == %d", repositoryID)
        if let result = try? viewContext.fetch(fetchRequest) {
            return !result.isEmpty
        }
        return false
    }

    /// Adds the given repository to the list of favorites.
    /// - Parameter repository: The repository to add.
    func addFavorite(_ repository: RepositoryResponse) {
        if !isFavorite(repository.id) {
            let favorite = RepositoryEntity(context: viewContext)
            favorite.repositoryID = Int64(repository.id)
            favorite.fullName = repository.fullName
            favorite.descrip = repository.description
            favorite.ownerName = repository.owner.name
            favorite.ownerEmail = repository.owner.email
            favorite.ownerLogin = repository.owner.login
            saveContext()
        }
    }

    /// Removes the repository with the given ID from the list of favorites.
    /// - Parameter repositoryID: The ID of the repository to remove.
    func removeFavorite(_ repositoryID: Int) {
        let fetchRequest: NSFetchRequest<RepositoryEntity> = RepositoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "repositoryID == %d", repositoryID)
        if let result = try? viewContext.fetch(fetchRequest),
           let favorite = result.first {
            viewContext.delete(favorite)
            saveContext()
        }
    }

    /// Retrieves the list of favorite repositories from the managed object context.
    /// - Returns: An array of `RepositoryEntity` objects representing the favorite repositories.
    func loadFavorites() -> [RepositoryEntity] {
        let fetchRequest: NSFetchRequest<RepositoryEntity> = RepositoryEntity.fetchRequest()
        let favoriteRepositories = try? viewContext.fetch(fetchRequest)
        switch favoriteRepositories {
        case .none:
            return []
        case .some(let favoriteRepositoriesUnwrap):
            return favoriteRepositoriesUnwrap
        }
    }
}
