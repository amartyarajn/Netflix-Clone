//
//  WatchListViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 21/05/23.
//

import Foundation

protocol WatchListViewModelDelegate: ErrorBaseViewModelDelegate, NavigateToVideoPreviewDelegate {
    func handleTitlesUpdate()
}

class WatchListViewModel: BaseViewModel {
    
    let repository: AccountListsRepositoryProtocol
    
    init(repository: AccountListsRepositoryProtocol) {
        self.repository = repository
    }
    
    weak var delegate: WatchListViewModelDelegate?
    
     private var watchListMovies: [TitleMOProtocol]? {
        didSet {
            delegate?.handleTitlesUpdate()
        }
    }
    
    private var watchListTVs: [TitleMOProtocol]? {
        didSet {
            delegate?.handleTitlesUpdate()
        }
    }
    
    var isMoviesLoadRequired = true
    var isTVsLoadRequired = true
    
    var selectedMediaType: MediaType? {
        didSet {
            if selectedMediaType == .Movie && isMoviesLoadRequired {
                getWatchList()
            } else if selectedMediaType == .TV && isTVsLoadRequired {
                getWatchList()
            } else {
                delegate?.handleTitlesUpdate()
            }
        }
    }
    
    func getWatchList() {
        repository.getWatchList(for: self.selectedMediaType!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let titles):
                if self.selectedMediaType == .Movie {
                    self.isMoviesLoadRequired = false
                    self.watchListMovies = titles
                } else {
                    self.isTVsLoadRequired = false
                    self.watchListTVs = titles
                }
            case .failure(let error):
                if self.isError == false {
                    self.delegate?.handleError(with: error.localizedDescription)
                }
            }
        }
    }
    
    func handleCellTap(for indexPath: IndexPath) {
        if var title = selectedMediaType == .Movie ? watchListMovies?[indexPath.row] : watchListTVs?[indexPath.row] {
            title.mediaType = selectedMediaType?.rawValue
            delegate?.navigateToVideoPreviewVC(with: title)
        }
    }
    
    func getNoOfTitles() -> Int {
        return selectedMediaType == .Movie ? watchListMovies?.count ?? 0 : watchListTVs?.count ?? 0
    }
    
    func getTitle(for indexPath: IndexPath) -> UpcomingViewModel {
        let title = selectedMediaType == .Movie ? watchListMovies?[indexPath.row] : watchListTVs?[indexPath.row]
        return UpcomingViewModel(titleMO: title)
    }
}
