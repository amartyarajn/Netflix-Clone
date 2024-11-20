//
//  LoginViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 14/05/23.
//

import Foundation

protocol LoginViewModelDelegate: LoginManagerDelegate {

}

class LoginViewModel:BaseViewModel {
    
    var manager: LoginManagerProtocol
    weak var delegate: LoginViewModelDelegate?
    
    init(manager: LoginManagerProtocol) {
        self.manager = manager
    }
    
    func loginAction() {
        manager.delegate = delegate
        manager.loginAction()
    }
}
