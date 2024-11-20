//
//  LoginManager.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 04/06/23.
//

import Foundation
import UIKit

protocol LoginManagerProtocol: SessionDelegate {
    var delegate: LoginManagerDelegate? { get set }
    func loginAction()
}

protocol LoginManagerDelegate: UIViewController, ErrorBaseViewModelDelegate {
    func loginCompletionAction()
}

class LoginManager: BaseViewModel, LoginManagerProtocol {
    
    var repository: UserSessionRepositoryProtocol
    
    init(repository: UserSessionRepositoryProtocol) {
        self.repository = repository
    }
    
    weak var delegate: LoginManagerDelegate?
    private var requestToken: String?
    
    func loginAction() {
        getRequestToken()
    }
    
    private func getRequestToken() {
        repository.fetchRequestToken { [weak self] result in
            switch result {
            case .success(let resultValue):
                self?.navigateToWebViewVC(with: resultValue.0)
                self?.requestToken = resultValue.1
            case .failure(let error):
                print(error.localizedDescription)
                self?.delegate?.handleError(with: error.localizedDescription)
            }
        }
    }
    
    private func saveSessionId(sessionId: String?) {
        guard let sessionId = sessionId else { return }
        if repository.saveSessionId(with: sessionId) {
            fetchAccountDetails(with: sessionId)
        }
    }
    
    private func fetchAccountDetails(with sessionId: String) {
        repository.getAccountDetails(with: sessionId) { [weak self] result in
            switch result {
            case .success(let userInfo):
                DispatchQueue.main.async {
                    self?.saveUserDetailsLocally(with: userInfo)
                }
            case .failure(let error):
                self?.delegate?.handleError(with: error.localizedDescription)
            }
        }
    }
    
    private func saveUserDetailsLocally(with userDetails: UserDetailsMOProtocol) {
        repository.saveUserDetails(with: userDetails)
        UserSession.shared.setUserDetails()
        delegate?.loginCompletionAction()
    }
    
//    func logoutAction() {
//        let data = KeyChainManager.shared.getSessionFromKeychain()
//        deleteSessionIdFromServer(with: data)
//    }
//
//    private func deleteSessionIdFromServer(with sessionId: Data?) {
//        guard let data = sessionId, let sId = String(data: data, encoding: .utf8) else { return }
//        APICaller.shared.deleteSession(with: sId) { [weak self] result in
//            switch result {
//            case .success(let isDeleted):
//                if isDeleted {
//                    self?.deleteUserDetails()
//                }
//            case .failure(let error):
//                self?.delegate?.handleError(with: error.localizedDescription)
//            }
//        }
//    }
//
//    private func deleteUserDetails() {
//        DispatchQueue.main.async {
//            if CoreDataManager.shared.deleteUser() {
//                self.deleteUserSession()
//                UserSession.shared.setUserDetails()
//            }
//        }
//    }
//
//    private func deleteUserSession() {
//       if KeyChainManager.shared.deleteSessionFromKeychain() {
//           delegate?.handleLogout()
//       }
//    }
}

extension LoginManager: SessionDelegate {
    func getSessionId() {
        guard let requestToken = requestToken else { return }
        repository.getSessionId(with: requestToken) { [weak self] result in
            switch result {
            case .success(let sessionId):
                self?.saveSessionId(sessionId: sessionId)
            case .failure(let error):
                print(error.localizedDescription)
                self?.delegate?.handleError(with: error.localizedDescription)
            }
        }
    }
}

extension LoginManager {
    
    func navigateToWebViewVC(with urlRequest: URLRequest?) {
        DispatchQueue.main.async { [weak self] in
            let authVC = WebAuthenticationViewController()
            let webVC = WebAuthenticationViewModel()
            webVC.sessionDelegate = self
            authVC.viewModel = webVC
            authVC.viewModel?.loadRequest(with: urlRequest)
            authVC.modalPresentationStyle = .fullScreen
            self?.delegate?.present(authVC, animated: true)
        }
    }
    
}
