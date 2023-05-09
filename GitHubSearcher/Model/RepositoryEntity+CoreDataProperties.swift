//
//  RepositoryEntity+CoreDataProperties.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 08.05.2023.
//
//

import Foundation
import CoreData


extension RepositoryEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RepositoryEntity> {
        return NSFetchRequest<RepositoryEntity>(entityName: "RepositoryEntity")
    }

    @NSManaged public var fullName: String
    @NSManaged public var descrip: String?
    @NSManaged public var ownerName: String?
    @NSManaged public var ownerEmail: String?
    @NSManaged public var repositoryID: Int64
    @NSManaged public var ownerLogin: String

}

extension RepositoryEntity : Identifiable {

}
