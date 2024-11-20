//
//  SideBarViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 16/05/23.
//

import Foundation

protocol SideBarViewModelDelegate: AnyObject, LoginManagerDelegate {
    func handleLogout()
}

class SideBarViewModel: BaseViewModel {
    
    let repository: UserSessionRepositoryProtocol
    
    init(repository: UserSessionRepositoryProtocol) {
        self.repository = repository
    }
    
    lazy var loginManager: LoginManagerProtocol = {
        let manager = LoginManager(repository: UserSessionRepository())
        manager.delegate = delegate
        return manager
    }()
    
    var isLoggedIn: Bool = {
        return UserSession.shared.userDetails != nil
    }()
    
    weak var delegate: SideBarViewModelDelegate?
    
    private let sideBarMenus = ["Watchlist", "Favourites", "Settings"] //Settings: clear cache, adult included?
    private let sidemenuImages = ["rectangle.stack.badge.play","star","gearshape"]
    private let guestSideBarMenus = ["Settings"] //Settings: clear cache, adult included?
    private let guestSidemenuImages = ["gearshape"]
    
    func getLoginLogoutButtonTitle() -> String {
        return isLoggedIn ? "Logout" : "Login"
    }
    
    func loginLogoutAction() {
        if isLoggedIn {
            logoutAction()
        } else {
            loginAction()
        }
    }
    
    private func loginAction() {
        loginManager.loginAction()
    }
    
    private func logoutAction() {
        let data = KeychainService.shared.getSessionFromKeychain()
        deleteSessionIdFromServer(with: data)
    }
    
    private func deleteSessionIdFromServer(with sessionId: Data?) {
        guard let data = sessionId, let sId = String(data: data, encoding: .utf8) else { return }
        repository.deleteSession(with: sId) { [weak self] result in
            switch result {
            case .success(let isDeleted):
                if isDeleted {
                    self?.deleteUserDetails()
                }
            case .failure(let error):
                if self?.isError == false {
                    self?.delegate?.handleError(with: error.localizedDescription)
                }
            }
        }
    }
    
    private func deleteUserDetails() {
        DispatchQueue.main.async {
            if self.repository.deleteUser() {
                self.deleteUserSession()
                UserSession.shared.setUserDetails()
            }
        }
    }
    
    private func deleteUserSession() {
       if repository.deleteSessionId() {
           delegate?.handleLogout()
       }
    }
    
    func assignFavouritesViewModel() -> FavouritesViewModel {
        return FavouritesViewModel(repository: AccountListsRepository())
    }
    
    func assignWatchListViewModel() -> WatchListViewModel {
        return WatchListViewModel(repository: AccountListsRepository())
    }
    
    func assignWebAuthenticationViewModel() -> WebAuthenticationViewModel {
        let webVC = WebAuthenticationViewModel()
        webVC.sessionDelegate = loginManager
        return webVC
    }
    
    func getUsername() -> String? {
        return UserSession.shared.userDetails?.username
    }
    
    func getProfileImageURL() -> URL? {
        return UserSession.shared.userDetails?.avatarPath?.getImageURL()
    }
    
    func getNoOfMenus() -> Int {
        return UserSession.shared.userDetails == nil ? guestSideBarMenus.count : sideBarMenus.count
    }
    
    func getMenu(for indexPath: IndexPath) -> String {
        return UserSession.shared.userDetails == nil ? guestSideBarMenus[indexPath.row] : sideBarMenus[indexPath.row]
    }
    
    func getMenuImage(for indexPath: IndexPath) -> String {
        return UserSession.shared.userDetails == nil ? guestSidemenuImages[indexPath.row] : sidemenuImages[indexPath.row]
    }
}
