//
//  APIService.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 22/05/23.
//

import Foundation

protocol Endpoint {
    var scheme: String { get }
    var baseURL: String { get }
    var path: String { get }
    var parameters: [URLQueryItem] { get }
    var body: [String:Any]? { get }
    var method: String { get }
    var headers: [String:String]? { get }
}

enum APIEndpoint: Endpoint {
    
    case getTitles(titleType: TitleListType, mediaType: MediaType)
    case getSearchResults(query: String)
    case getDiscoverResults
    case getTitleVideo(mediaType:MediaType, titleId: Int)
    case updateList(listType: UserListType, sessionId: String, accountId: Int, titleId: Int, mediaType: MediaType, isAdded: Bool)
    case getList(listType: UserListType, sessionId: String, accountId: Int, mediaType: MediaType)
    case getTitleState(sessionId: String, titleId: Int, mediaType: MediaType)
    case login
    case getSessionId(requestToken: String)
    case getAccountDetails(sessionId: String)
    case deleteSession(sessionId: String)
    
    
    var scheme: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var baseURL: String {
        switch self {
        default:
            return Constants.TMDB_BASE_URL
        }
    }
    
    var path: String {
        switch self {
        case .getTitles(titleType: let titleType, mediaType: let mediaType):
            if titleType == .Trending {
                return "/3/\(titleType.rawValue)/\(mediaType.rawValue)/day"
            } else {
                return "/3/\(mediaType.rawValue)/\(titleType.rawValue)"
            }
        case .getSearchResults:
            return "/3/search/multi"
        case .getDiscoverResults:
            return "/3/discover/movie"
        case .getTitleVideo(mediaType: let mediaType, titleId: let titleId):
            return "/3/\(mediaType.rawValue)/\(titleId)/videos"
        case .updateList(listType: let listType, sessionId: _, accountId: let accountId, titleId: _, mediaType: _, isAdded: _):
            return "/3/account/\(accountId)/\(listType.rawValue)"
        case .getList(listType: let listType, sessionId: _, accountId: let accountId, mediaType: let mediaType):
            let mediaTypeString = mediaType == .Movie ? "movies" : "tv"
            return "/3/account/\(accountId)/\(listType.rawValue)/\(mediaTypeString)"
        case .getTitleState(sessionId: _, titleId: let titleId, mediaType: let mediaType):
            return "/3/\(mediaType.rawValue)/\(titleId)/account_states"
        case .login:
            return "/3/authentication/token/new"
        case .getSessionId:
            return "/3/authentication/session/new"
        case .getAccountDetails:
            return "/3/account"
        case .deleteSession:
            return "/3/authentication/session"
        }
    }
    
    private var fixedParameters: [URLQueryItem] {
        return [
            URLQueryItem(name: "api_key", value: Constants.API_KEY),
            URLQueryItem(name: "language", value: "en-US"),
            URLQueryItem(name: "page", value: "1")
        ]
    }
    
    var parameters: [URLQueryItem] {
        var queryItems = fixedParameters
        switch self {
            
        case .getSearchResults(query: let query):
            queryItems.append(URLQueryItem(name: "query", value: query))
            return queryItems
        case .getDiscoverResults:
            queryItems.append(contentsOf: [
                URLQueryItem(name: "sort_by", value: "popularity.desc"),
                URLQueryItem(name: "include_adult", value: "false"),
                URLQueryItem(name: "include_video", value: "false"),
                URLQueryItem(name: "with_watch_monetization_types", value: "flatrate"),
            ])
            return queryItems
        case .updateList(listType: _, sessionId: let sessionId, accountId: _, titleId: _, mediaType: _, isAdded: _), .getTitleState(sessionId: let sessionId, titleId: _, mediaType: _), .getAccountDetails(sessionId: let sessionId), .deleteSession(sessionId: let sessionId):
            return [
                URLQueryItem(name: "api_key", value: Constants.API_KEY),
                URLQueryItem(name: "session_id", value: sessionId)
            ]
        case .getList(listType: _, sessionId: let sessionId, accountId: _, mediaType: _):
            queryItems.append(contentsOf: [
                URLQueryItem(name: "session_id", value: sessionId),
                URLQueryItem(name: "sort_by", value: "created_at.asc")
            ])
            return queryItems
        case .login:
            return [URLQueryItem(name: "api_key", value: Constants.API_KEY)]
        case .getSessionId(requestToken: let requestToken):
            return [
                URLQueryItem(name: "api_key", value: Constants.API_KEY),
                URLQueryItem(name: "request_token", value: requestToken)
            ]
        default:
            return fixedParameters
        }
    }
    
    var body: [String : Any]? {
        switch self {
        case .updateList(listType: let listType, sessionId: _, accountId: _, titleId: let titleId, mediaType: let mediaType, isAdded: let isAdded):
            var parameters:[String : Any] = [
                "media_type": mediaType.rawValue,
                "media_id": titleId
            ]
            if listType == .Favourite {
                parameters["favorite"] = isAdded
            } else {
                parameters["watchlist"] = isAdded
            }
            return parameters
        default:
            return nil
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .updateList, .getSessionId, .deleteSession:
            return ["content-type": "application/json"]
        default:
            return nil
        }
    }
    
    var method: String {
        switch self {
        case .updateList:
            return "POST"
        case .deleteSession:
            return "DELETE"
        default:
            return "GET"
        }
    }
}

enum TitleListType: String {
    case Trending = "trending"
    case Popular = "popular"
    case Upcoming = "upcoming"
    case TopRated = "top_rated"
}

enum UserListType: String {
    case Favourite = "favorite"
    case WatchList = "watchlist"
}

enum MediaType: String {
    case Movie = "movie"
    case TV = "tv"
}

enum APIError: Error {
    case NoInternet
    case ParsingError
}

class APIService {
    
    static func apiRequest<T:Codable>(for endpoint: Endpoint, completionBlock: @escaping (Result<T,APIError>) -> Void) {
        
        guard let request = createURLRequest(from: endpoint) else { return }
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completionBlock(.failure(.NoInternet))
                return
            }
            do {
                let result = try JSONDecoder().decode(T.self, from: data)
                completionBlock(.success(result))
            } catch {
                completionBlock(.failure(.ParsingError))
            }
        }.resume()
    }
    
    static func apiRequest(for endpoint: Endpoint, completionBlock: @escaping (Result<[String:Any],APIError>) -> Void) {
        guard let request = createURLRequest(from: endpoint) else { return }
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completionBlock(.failure(.NoInternet))
                return
            }
            do {
                let result = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                completionBlock(.success(result))
            } catch {
                completionBlock(.failure(.ParsingError))
            }
        }.resume()
    }
    
    private static func createURLRequest(from endpoint: Endpoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = endpoint.scheme
        components.host = endpoint.baseURL
        components.path = endpoint.path
        components.queryItems = endpoint.parameters
        
        guard let url = components.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        if let body = endpoint.body {
            request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        }
        request.allHTTPHeaderFields = endpoint.headers
        return request
    }
}
