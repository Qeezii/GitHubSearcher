//
//  API.swift
//  GitHubSearcher
//
//  Created by Alexey Poletaev on 09.05.2023.
//

import Foundation

struct API {

    /// Returns the URL for searching repositories on GitHub.
    static func apiForRepositories(query: String) -> URL? {
        var components = URLComponents()
        components.scheme = AppConstants.Strings.Network.scheme
        components.host = AppConstants.Strings.Network.host
        components.path = AppConstants.Strings.Network.SearchRepositories.path
        components.queryItems = [
            URLQueryItem(name: AppConstants.Strings.Network.SearchRepositories.queryItemName,
                         value: query)
        ]
        return components.url
    }

    /// Returns the URL  for getting information about a user on GitHub.
    static func apiForUser(userName: String) -> URL? {
        var components = URLComponents()
        components.scheme = AppConstants.Strings.Network.scheme
        components.host = AppConstants.Strings.Network.host
        components.path = AppConstants.Strings.Network.OwnerInfo.path(userName: userName)
        return components.url
    }
}
