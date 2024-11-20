//
//  APICaller.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 30/04/23.
//

import Foundation

enum APIErrorMO: Error {
    case NoInternet
    case FetchError
    case LoginError
    case LogoutError
    case SaveError
    
    var localizedDescription: String {
        switch self {
        case .NoInternet:
            return "Please connect to internet and try again."
        case .LoginError:
            return "Unable to login. Please try later."
        case .LogoutError:
            return "Unable to logout. Please try later."
        case .SaveError:
            return "Unable to save. Please try later."
        default:
            return "Unable to fetch data. Please try later"
        }
    }
}
