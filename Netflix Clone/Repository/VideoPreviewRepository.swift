//
//  VideoPreviewRepository.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 04/06/23.
//

import Foundation

protocol VideoPreviewRepositoryProtocol {
    func addFavourite(with titleId: Int, mediaType: MediaType, completionBlock: @escaping (Result<Bool, APIErrorMO>) -> Void)
    func getTitleState(with titleId: Int, for mediaType: MediaType, completionBlock: @escaping (Result<(Bool,Bool), APIErrorMO>) -> Void)
    func addToWatchList(with titleId: Int, mediaType: MediaType, completionBlock: @escaping (Result<Bool, APIErrorMO>) -> Void)
    func getTitleVideo(mediaType:MediaType, titleId: Int, completionBlock: @escaping (Result<VideoElement, APIErrorMO>) -> Void)
    func saveTitle(for title: TitleMOProtocol)
    func isTitleDownloaded(for id: Int) -> Bool
}

class VideoPreviewRepository: VideoPreviewRepositoryProtocol {
    
    func addFavourite(with titleId: Int, mediaType: MediaType, completionBlock: @escaping (Result<Bool, APIErrorMO>) -> Void) {
        guard let data = KeychainService.shared.getSessionFromKeychain(), let sId = String(data: data, encoding: .utf8) else { return }
        if let accId = UserSession.shared.userDetails?.accountId {
            APIService.apiRequest(for: APIEndpoint.updateList(listType: .Favourite, sessionId: sId, accountId: accId, titleId: titleId, mediaType: mediaType, isAdded: true)) { (result: Result<[String:Any], APIError>) in
                switch result {
                case .success(let response):
                    let isAdded = response["success"] as! Bool
                    completionBlock(.success(isAdded))
                case .failure(let error):
                    let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.SaveError
                    completionBlock(.failure(err))
                }
            }
        }
    }
    
    func getTitleState(with titleId: Int, for mediaType: MediaType, completionBlock: @escaping (Result<(Bool,Bool), APIErrorMO>) -> Void) {
        guard let data = KeychainService.shared.getSessionFromKeychain(), let sId = String(data: data, encoding: .utf8) else { return }
        APIService.apiRequest(for: APIEndpoint.getTitleState(sessionId: sId, titleId: titleId, mediaType: mediaType)) { (result: Result<[String:Any], APIError>) in
            switch result {
            case .success(let response):
                let isFavourite = response["favorite"] as! Bool
                let isWatchListed = response["watchlist"] as! Bool
                completionBlock(.success((isFavourite,isWatchListed)))
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
    
    func addToWatchList(with titleId: Int, mediaType: MediaType, completionBlock: @escaping (Result<Bool, APIErrorMO>) -> Void) {
        guard let data = KeychainService.shared.getSessionFromKeychain(), let sId = String(data: data, encoding: .utf8) else { return }
        if let accId = UserSession.shared.userDetails?.accountId {
            APIService.apiRequest(for: APIEndpoint.updateList(listType: .WatchList, sessionId: sId, accountId: accId, titleId: titleId, mediaType: mediaType, isAdded: true)) { (result: Result<[String:Any], APIError>) in
                switch result {
                case .success(let response):
                    let isSuccess = response["success"] as! Bool
                    completionBlock(.success(isSuccess))
                case .failure(let error):
                    let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.SaveError
                    completionBlock(.failure(err))
                }
            }
        }
    }
    
    func getTitleVideo(mediaType:MediaType, titleId: Int, completionBlock: @escaping (Result<VideoElement, APIErrorMO>) -> Void) {
        APIService.apiRequest(for: APIEndpoint.getTitleVideo(mediaType: mediaType, titleId: titleId)) { (result: Result<VideoResponse, APIError>) in
            switch result {
            case .success(let response):
                for videoElement in response.results {
                    if videoElement.site == "YouTube" && videoElement.type == "Trailer" {
                        completionBlock(.success(videoElement))
                        return
                    }
                }
            case .failure(let error):
                let err = error == .NoInternet ? APIErrorMO.NoInternet : APIErrorMO.FetchError
                completionBlock(.failure(err))
            }
        }
    }
    
    func saveTitle(for title: TitleMOProtocol) {
        if let accId = UserSession.shared.userDetails?.accountId {
            LocalDataService.shared.saveTitle(for: title, accountId: accId)
        }
    }
    
    func isTitleDownloaded(for id: Int) -> Bool {
        if let accId = UserSession.shared.userDetails?.accountId {
            return LocalDataService.shared.get(for: TitleItem.self, predicate: NSPredicate(format: "accountId64 = %i AND id64 == %i", accId, id), fetchLimit: 1).count > 0
        }
        return false
    }
}
