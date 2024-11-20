//
//  VideoPreviewVideoModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 11/05/23.
//

import Foundation

protocol VideoPreviewViewModelDelegate: AnyObject, LoginManagerDelegate {
    func handleResultUpdate()
    func configureDownloadButton()
    func loadVideo()
    func configureLikeButton()
    func configureWatchListButton()
}

class VideoPreviewViewModel: BaseViewModel {
    
    let repository: VideoPreviewRepositoryProtocol
    lazy var loginManager: LoginManagerProtocol = {
        let manager = LoginManager(repository: UserSessionRepository())
        manager.delegate = delegate
        return manager
    }()
    
    init(repository: VideoPreviewRepositoryProtocol) {
        self.repository = repository
    }
    
    private var title: TitleMOProtocol? {
        didSet {
            delegate?.handleResultUpdate()
        }
    }
    weak var delegate: VideoPreviewViewModelDelegate?
//    var isError = false
    
    var isDownloaded: Bool? {
        didSet {
            delegate?.configureDownloadButton()
        }
    }
    
    var isFavourite: Bool? {
        didSet {
            delegate?.configureLikeButton()
        }
    }
    
    var isWatchListed: Bool? {
        didSet {
            delegate?.configureWatchListButton()
        }
    }
    
    var videoURL: URL? {
        didSet {
            delegate?.loadVideo()
        }
    }
    
    func configure(title: TitleMOProtocol) {
        self.title = title
        self.isDownloaded = isTitleDownloaded()
        configureTitleState()
        
        getTitleVideo()
    }
    
    private func isTitleDownloaded() -> Bool {
        guard let id = title?.id else { return false }
        return repository.isTitleDownloaded(for: id)
    }
    
    private func configureTitleState() {
        guard let id = title?.id else { return }
        if UserSession.shared.userDetails != nil {
            getTitleState(id: id) { [weak self] titleState in
                self?.isFavourite = titleState.0
                self?.isWatchListed = titleState.1
            }
        }
    }
    
    private func getTitleState(id: Int, completionBlock: @escaping ((Bool, Bool)) -> Void) {
        let mediaType = MediaType(rawValue: title?.mediaType ?? "") ?? .Movie
        repository.getTitleState(with: id, for: mediaType) {[weak self] result in
            switch result {
            case .success(let titleState):
                completionBlock(titleState)
            case .failure(let error):
                self?.handleError(with: error.localizedDescription)
            }
        }
    }
    
    private func getTitleVideo() {
        let mediaType = MediaType(rawValue: title?.mediaType ?? "") ?? .Movie
        repository.getTitleVideo(mediaType: mediaType, titleId: title?.id ?? 0) {[weak self] result in
            guard let self =  self else { return }
            switch result {
            case .success(let videoElement):
                guard let key = videoElement.key else { return }
                self.videoURL = URL(string: "\(Constants.YOUTUBE_BASE_URL)\(key)")
            case .failure(let error):
                self.handleError(with: error.localizedDescription)
            }
        }
    }
    
    func downloadAction() {
        if let title = title {
            repository.saveTitle(for: title)
            print("Data saved")
            NotificationCenter.default.post(name: NSNotification.Name("Downloaded"), object: nil)
            isDownloaded = true
        }
    }
    
    func addFavouriteAction() {
        let mediaType = MediaType(rawValue: title?.mediaType ?? "") ?? .Movie
        repository.addFavourite(with: title?.id ?? 0, mediaType: mediaType) { [weak self] result in
            switch result {
            case .success(let isAdded):
                if isAdded {
                    NotificationCenter.default.post(name: NSNotification.Name("Favourite"), object: nil, userInfo: ["media-type":self?.title?.mediaType ?? "movie"])
                    self?.isFavourite = true
                }
            case .failure(let error):
                self?.handleError(with: error.localizedDescription)
            }
        }
    }
    
    func addToWatchListAction() {
        let mediaType = MediaType(rawValue: title?.mediaType ?? "") ?? .Movie
        repository.addToWatchList(with: title?.id ?? 0, mediaType: mediaType) { [weak self] result in
            switch result {
            case .success(let isAdded):
                if isAdded {
                    NotificationCenter.default.post(name: NSNotification.Name("WatchList"), object: nil, userInfo: ["media-type":self?.title?.mediaType ?? "movie"])
                    self?.isWatchListed = true
                }
            case .failure(let error):
                self?.handleError(with: error.localizedDescription)
            }
        }
    }
    
    func getTitle() -> String? {
        return title?.name
    }
    
    func getOverview() -> String? {
        return title?.overview
    }
    
    func loginAction() {
        loginManager.loginAction()
    }
    
    func assignWebAuthenticationViewModel() -> WebAuthenticationViewModel {
        let webVC = WebAuthenticationViewModel()
        webVC.sessionDelegate = loginManager
        return webVC
    }
    
    func reloadTitleState() {
        if let title = title {
            configure(title: title)
        }
    }
    
    private func handleError(with errorMsg: String) {
        if !isError {
            self.delegate?.handleError(with: errorMsg)
        }
    }
}
