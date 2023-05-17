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
                static let queryQueryItems = "q"
                static let perPageQueryItems = "per_page"
                static let perPageValue = "100"
                static let pageQueryItems = "page"
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
            static let hintLabelText = "Enter the text to search for repositories"
            static let searchEmptyImageViewImageName = "SearchEmpty"
        }

        struct DetailScreen {
            static let title = "Detailed information"
            static let favoriteButtunNormalText = "Add to favorites"
            static let favoriteBottunSelectedText = "Delete from favorites"

            static func fullNameLabelText(_ fullName: String?) -> String {
                return "Repository: \(fullName ?? "")"
            }
            static func descriptionLabelText(_ description: String?) -> String {
                "Description: \(description ?? "")"
            }
            static func ownerNameLabelText(_ ownerName: String?) -> String {
                "Owner name: \(ownerName ?? "")"
            }
            static func ownerEmailLabelText(_ ownerEmail: String?) -> String {
                "Owner email: \(ownerEmail ?? "")"
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

        static let verticalSpacingLarge: CGFloat = 24
        static let verticalSpacingMiddle: CGFloat = 16
        static let verticalSpacingSmall: CGFloat = 8
        static let height: CGFloat = 32
    }
}
