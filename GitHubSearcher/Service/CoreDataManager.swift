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
    private let viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    private init() {}

    /// Saves changes to the managed object context, if any changes exist.
    private func saveContext() {
        guard let viewContext = viewContext else { return }
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error occured while saving data: \(error.localizedDescription)")
            }
        }
    }

    /// Checks whether a repository with the given ID is marked as a favorite.
    /// - Parameter repositoryID: The ID of the repository to check.
    /// - Returns: `true` if the repository is marked as a favorite, `false` otherwise.
    func isFavorite(_ repositoryID: Int) -> Bool {
        let fetchRequest: NSFetchRequest<RepositoryEntity> = RepositoryEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "repositoryID == %d", repositoryID)
        if let result = try? viewContext?.fetch(fetchRequest) {
            return !result.isEmpty
        }
        return false
    }

    /// Adds the given repository to the list of favorites.
    /// - Parameter repository: The repository to add.
    func addFavorite(_ repository: Repository) {
        if !isFavorite(repository.id),
            let viewContext = viewContext {
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
        if let result = try? viewContext?.fetch(fetchRequest),
           let favorite = result.first {
            viewContext?.delete(favorite)
            saveContext()
        }
    }

    /// Retrieves the list of favorite repositories from the managed object context.
    /// - Returns: An array of `RepositoryEntity` objects representing the favorite repositories.
    func loadFavorites() -> [RepositoryEntity] {
        guard let viewContext = viewContext else { return [] }
        let fetchRequest: NSFetchRequest<RepositoryEntity> = RepositoryEntity.fetchRequest()
        do {
            let favoriteRepositories = try viewContext.fetch(fetchRequest)
            return favoriteRepositories
        } catch {
            print("Could not fetch favorites: \(error.localizedDescription)")
        }
        return []
    }
}
