//
//  UserInfo.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 14/05/23.
//

import Foundation

struct UserInfo: Codable {
    let avatar: Avatar?
    let id: Int?
    let username: String?
}

struct Avatar: Codable {
    let tmdb: TMDB?
}

struct TMDB: Codable {
    let avatar_path: String?
}

protocol UserDetailsMOProtocol {
    var accountId: Int { get }
    var avatarPath: String? { get }
    var username: String? { get }
}

struct UserDetailsMO: UserDetailsMOProtocol {
    var accountId: Int
    var avatarPath: String?
    var username: String?
    
    init(userDetails: UserDetails) {
        
        accountId = Int(userDetails.accountId)
        avatarPath = userDetails.avatarPath
        username = userDetails.username
    }
    
    init(userInfo: UserInfo) {
        accountId = userInfo.id ?? 0
        avatarPath = userInfo.avatar?.tmdb?.avatar_path
        username = userInfo.username
    }
}

/*
 {
     "avatar": {
         "gravatar": {
             "hash": "e805a35a99e7ca76fb5078ccc8311158"
         },
         "tmdb": {
             "avatar_path": "/A7S4aB7ANtEcrH3YMKsdHdh4kyj.jpg"
         }
     },
     "id": 19231192,
     "iso_639_1": "en",
     "iso_3166_1": "IN",
     "name": "",
     "include_adult": false,
     "username": "Amartyarajn"
 }
 */
