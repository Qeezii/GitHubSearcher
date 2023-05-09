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
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/search/repositories"
        components.queryItems = [URLQueryItem(name: "q", value: query)]
        return components.url
    }

    /// Returns the URL  for getting information about a user on GitHub.
    static func apiForUser(username: String) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.github.com"
        components.path = "/users/\(username)"
        return components.url
    }
}
