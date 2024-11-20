//
//  TitlesRepository.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 04/06/23.
//

import Foundation

protocol TitlesRepositoryProtocol {
    func getTrendingMovies(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void)
    func getPopularMovies(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void)
    func getTrendingTV(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void)
    func getUpcomingMovies(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void)
    func getTopRatedMovies(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void)
    func getSearchResults(query: String, completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void)
    func getDiscoverResult(completionBlock: @escaping (Result<TitleMOProtocol, APIErrorMO>) -> Void)
}

class TitlesRepository: TitlesRepositoryProtocol {
    
    func getTrendingMovies(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getTitles(titleType: .Trending, mediaType: .Movie)) { (result: Result<TrendingTitlesResponse, APIError>) in
            switch result {
            case .success(let response):
                completionBlock(.success(response.results.compactMap {TitleMO(titleProtocol: $0)}))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
    
    func getPopularMovies(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getTitles(titleType: .Popular, mediaType: .Movie)) { (result: Result<TrendingTitlesResponse, APIError>) in
            switch result {
            case .success(let response):
                completionBlock(.success(response.results.compactMap {TitleMO(titleProtocol: $0)}))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
    
    func getTrendingTV(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getTitles(titleType: .Trending, mediaType: .TV)) { (result: Result<TrendingTitlesResponse, APIError>) in
            switch result {
            case .success(let response):
                completionBlock(.success(response.results.compactMap {TitleMO(titleProtocol: $0)}))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
    
    func getUpcomingMovies(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getTitles(titleType: .Upcoming, mediaType: .Movie)) { (result: Result<TrendingTitlesResponse, APIError>) in
            switch result {
            case .success(let response):
                completionBlock(.success(response.results.compactMap {TitleMO(titleProtocol: $0)}))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
    
    func getTopRatedMovies(completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getTitles(titleType: .TopRated, mediaType: .Movie)) { (result: Result<TrendingTitlesResponse, APIError>) in
            switch result {
            case .success(let response):
                completionBlock(.success(response.results.compactMap {TitleMO(titleProtocol: $0)}))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
    
    func getSearchResults(query: String, completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getSearchResults(query: query)) { (result: Result<TrendingTitlesResponse, APIError>) in
            switch result {
            case .success(let response):
                var results = response.results
                results = results.filter { $0.posterPath != nil && ($0.mediaType == MediaType.Movie.rawValue || $0.mediaType == MediaType.TV.rawValue) }
                completionBlock(.success(results.compactMap {TitleMO(titleProtocol: $0)}))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
    
    func getDiscoverResult(completionBlock: @escaping (Result<TitleMOProtocol, APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getDiscoverResults) { (result: Result<TrendingTitlesResponse, APIError>) in
            switch result {
            case .success(let response):
                let index = Int.random(in: 0..<response.results.count)
                completionBlock(.success(TitleMO(titleProtocol: response.results[index])))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
}
