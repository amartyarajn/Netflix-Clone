//
//  WebAuthenticationViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 14/05/23.
//

import Foundation

protocol SessionDelegate: AnyObject {
    func getSessionId()
}

protocol WebAuthenticationViewModelDelegate: AnyObject {
    func loadRequest()
}

class WebAuthenticationViewModel {
    
    weak var delegate: WebAuthenticationViewModelDelegate?
    weak var sessionDelegate: SessionDelegate?
    
    private var urlRequest: URLRequest? {
        didSet {
            delegate?.loadRequest()
        }
    }
    
    private var requestToken: String?
    
    func loadRequest(with urlRequest: URLRequest?) {
        self.urlRequest = urlRequest
    }
    
    func getRequest() -> URLRequest? {
        return urlRequest
    }
}
