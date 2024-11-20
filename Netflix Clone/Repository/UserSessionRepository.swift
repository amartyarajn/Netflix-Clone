//
//  UserSessionRepository.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 04/06/23.
//

import Foundation

protocol UserSessionRepositoryProtocol {
    func fetchRequestToken(completionBlock: @escaping (Result<(URLRequest?, String?), APIErrorMO>) -> Void)
    func getSessionId(with requestToken: String, completionBlock: @escaping (Result<String?, APIErrorMO>) -> Void)
    func getAccountDetails(with sessionId: String, completionBlock: @escaping (Result<UserDetailsMOProtocol, APIErrorMO>) -> Void)
    func deleteSession(with sessionId: String, completionBlock: @escaping (Result<Bool, APIErrorMO>) -> Void)
    func getUserDetails() -> UserDetailsMOProtocol?
    func deleteUser() -> Bool
    func saveUserDetails(with userDetails: UserDetailsMOProtocol)
    func saveSessionId(with sessionId: String) -> Bool
    func deleteSessionId() -> Bool
}

class UserSessionRepository: UserSessionRepositoryProtocol {
    
    func fetchRequestToken(completionBlock: @escaping (Result<(URLRequest?, String?), APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.login) { (result: Result<[String:Any], APIError>) in
            switch result {
            case .success(let response):
                let rToken = response["request_token"] as? String
                let urlString1 = "https://www.themoviedb.org/authenticate/\(rToken ?? "")"
                guard let url = URL(string: urlString1) else {
                    completionBlock(.failure(.NoInternet))
                    return
                }
                completionBlock(.success((URLRequest(url: url), rToken)))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.LoginError
                completionBlock(.failure(err))
            }
        }
    }
    
    func getSessionId(with requestToken: String, completionBlock: @escaping (Result<String?, APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getSessionId(requestToken: requestToken)) { (result: Result<[String:Any], APIError>) in
            switch result {
            case .success(let response):
                let sessionId = response["session_id"] as? String
                completionBlock(.success(sessionId))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.LoginError
                completionBlock(.failure(err))
            }
        }
    }
    
    func getAccountDetails(with sessionId: String, completionBlock: @escaping (Result<UserDetailsMOProtocol, APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getAccountDetails(sessionId: sessionId)) { (result: Result<UserInfo, APIError>) in
            switch result {
            case .success(let response):
                completionBlock(.success(UserDetailsMO(userInfo: response)))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
    
    func deleteSession(with sessionId: String, completionBlock: @escaping (Result<Bool, APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.deleteSession(sessionId: sessionId)) { (result: Result<[String:Any], APIError>) in
            switch result {
            case .success(let response):
                let isDeleted = response["success"] as! Bool
                completionBlock(.success(isDeleted))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.LogoutError
                completionBlock(.failure(err))
            }
        }
    }
    
    func getUserDetails() -> UserDetailsMOProtocol? {
        let userDetails = LocalDataService.shared.get(for: UserDetails.self, predicate: nil, fetchLimit: 1)
        return userDetails.count > 0 ? UserDetailsMO(userDetails: userDetails[0]) : nil
    }
    
    func deleteUser() -> Bool {
        return LocalDataService.shared.delete(entity: UserDetails.self, predicate: nil)
    }
    
    func saveUserDetails(with userDetails: UserDetailsMOProtocol) {
        LocalDataService.shared.saveUserDetails(accountId: userDetails.accountId, username: userDetails.username, avatarPath: userDetails.avatarPath)
    }
    
    func saveSessionId(with sessionId: String) -> Bool {
        return KeychainService.shared.saveSessionToKeychain(with: sessionId)
    }
    
    func deleteSessionId() -> Bool {
        return KeychainService.shared.deleteSessionFromKeychain()
    }
}
