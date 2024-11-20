//
//  AccountListsRepository.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 04/06/23.
//

import Foundation

protocol AccountListsRepositoryProtocol {
    func getFavouriteTitles(for mediaType: MediaType, completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void)
    func getWatchList(for mediaType: MediaType, completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void)
    func getTitles() -> [TitleMOProtocol]
    func deleteTitle(with id: Int) -> Bool
}

class AccountListsRepository: AccountListsRepositoryProtocol {
    
    func getFavouriteTitles(for mediaType: MediaType, completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void) {
        guard let data = KeychainService.shared.getSessionFromKeychain(),
              let sId = String(data: data, encoding: .utf8) else { return }
        if let accountId = UserSession.shared.userDetails?.accountId {
            APIService.apiRequest(for: APIEndpoint.getList(listType: .Favourite, sessionId: sId, accountId: accountId, mediaType: mediaType)) { (result: Result<TrendingTitlesResponse, APIError>) in
                switch result {
                case .success(let response):
                    completionBlock(.success(response.results.compactMap {TitleMO(titleProtocol: $0)}))
                case .failure(let error):
                    let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                    completionBlock(.failure(err))
                }
            }
        }
    }
    
    func getWatchList(for mediaType: MediaType, completionBlock: @escaping (Result<[TitleMOProtocol], APIErrorMO>) -> Void) {
        guard let data = KeychainService.shared.getSessionFromKeychain(),
              let sId = String(data: data, encoding: .utf8) else { return }
        if let accountId = UserSession.shared.userDetails?.accountId {
            APIService.apiRequest(for: APIEndpoint.getList(listType: .WatchList, sessionId: sId, accountId: accountId, mediaType: mediaType)) { (result: Result<TrendingTitlesResponse, APIError>) in
                switch result {
                case .success(let response):
                    completionBlock(.success(response.results.compactMap {TitleMO(titleProtocol: $0)}))
                case .failure(let error):
                    let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                    completionBlock(.failure(err))
                }
            }
        }
    }
    
    func getTitles() -> [TitleMOProtocol] {
        if let accountId = UserSession.shared.userDetails?.accountId {
            let titles = LocalDataService.shared.get(for: TitleItem.self, predicate: NSPredicate(format: "accountId64 = %i", accountId), fetchLimit: nil)
            return titles.compactMap {TitleMO(titleItem: $0)}
        }
        return []
    }
    
    func deleteTitle(with id: Int) -> Bool {
        if let accountId = UserSession.shared.userDetails?.accountId {
            return LocalDataService.shared.delete(entity: TitleItem.self, predicate: NSPredicate(format: "accountId64 = %i AND id64 == %i", accountId, id))
        }
        return false
    }
}
