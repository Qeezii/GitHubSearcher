//
//  AppConstants.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 13.05.2023.
//

import Foundation

struct AppConstants {

    struct Strings {
        struct Network {
            static let scheme = "https"
            static let host = "api.github.com"

            struct SearchRepositories {
                static let path = "/search/repositories"
                static let queryItemName = "q"
            }

            struct OwnerInfo {
                static func path(userName: String) -> String {
                    "/users/\(userName)"
                }
            }
        }

        struct SearchScreen {
            static let title = "Search repositories"
            static let cellIdentifier = "SearchRepositoryTableViewCell"
            static let searchTextFieldPlaceholder = "Search"
            static let hintLabelTextDefault = "Enter the text to search for repositories"
            static let hintLabelTextNothingFound = "Nothing found"
            static let searchEmptyImageViewImageName = "SearchEmpty"
        }

        struct DetailScreen {
            static let title = "Detailed information"
            static let favoriteButtunNormalText = "Add to favorites"
            static let favoriteBottunSelectedText = "Delete from favorites"

            static func fullNameLabelText(_ fullName: String) -> String {
                "Repository: \(fullName)"
            }
            static func descriptionLabelText(_ description: String?) -> String {
                "Description: \(description ?? "")"
            }
            static func ownerNameLabelText(_ ownerName: String?) -> String {
                "Owner email: \(ownerName ?? "")"
            }
        }
        struct FavoritesScreen {
            static let title = "Favorites repositories"
            static let cellIdentifier = "FavoriteRepositoryTableViewCell"
            static let emptyFavoritesLabelText = "Nothing has been added to favorites"
        }
        struct CoreData {
            static let containerName = "GitHubSearcher"
        }
    }

    struct Constraints {
        static let leadingLarge: CGFloat = 24
        static let leadingMiddle: CGFloat = 16
        static let leadingSmall: CGFloat = 8

        static let trailingLarge: CGFloat = 24
        static let trailingMiddle: CGFloat = 16
        static let trailingSmall: CGFloat = 8

        static let verticalSpacing: CGFloat = 16
        static let height: CGFloat = 32
    }
}
