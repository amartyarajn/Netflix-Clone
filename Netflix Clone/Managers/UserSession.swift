//
//  LoginManager.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 29/05/23.
//

import Foundation

class UserSession {
    
    static let shared: UserSession = {
        let loginManager = UserSession()
        loginManager.setUserDetails()
        return loginManager
    }()
    
    private(set) var userDetails: UserDetailsMOProtocol?

    func setUserDetails() {
        let repository = UserSessionRepository()
        userDetails = repository.getUserDetails()
    }
}
