//
//  FavouritesViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 20/05/23.
//

import Foundation

protocol FavouritesViewModelDelegate: ErrorBaseViewModelDelegate, NavigateToVideoPreviewDelegate {
    func handleTitlesUpdate()
}

class FavouritesViewModel: BaseViewModel {
    
    let repository: AccountListsRepositoryProtocol
    
    init(repository: AccountListsRepositoryProtocol) {
        self.repository = repository
    }
    
    weak var delegate: FavouritesViewModelDelegate?
    
     private var favouriteMovies: [TitleMOProtocol]? {
        didSet {
            delegate?.handleTitlesUpdate()
        }
    }
    
    private var favouriteTVs: [TitleMOProtocol]? {
        didSet {
            delegate?.handleTitlesUpdate()
        }
    }
    
    var isMoviesLoadRequired = true
    var isTVsLoadRequired = true
    
    var selectedMediaType: MediaType? {
        didSet {
            if selectedMediaType == .Movie && isMoviesLoadRequired {
                getFavouriteTitles()
            } else if selectedMediaType == .TV && isTVsLoadRequired {
                getFavouriteTitles()
            } else {
                delegate?.handleTitlesUpdate()
            }
        }
    }
    
    func getFavouriteTitles() {
        repository.getFavouriteTitles(for: selectedMediaType!) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let titles):
                if self.selectedMediaType == .Movie {
                    self.isMoviesLoadRequired = false
                    self.favouriteMovies = titles
                } else {
                    self.isTVsLoadRequired = false
                    self.favouriteTVs = titles
                }
            case .failure(let error):
                if self.isError == false {
                    self.delegate?.handleError(with: error.localizedDescription)
                }
            }
        }
    }
    
    func handleCellTap(for indexPath: IndexPath) {
        if var title = selectedMediaType == .Movie ? favouriteMovies?[indexPath.row] : favouriteTVs?[indexPath.row] {
            title.mediaType = selectedMediaType?.rawValue
            delegate?.navigateToVideoPreviewVC(with: title)
        }
    }
    
    func getNoOfTitles() -> Int {
        return selectedMediaType == .Movie ? favouriteMovies?.count ?? 0 : favouriteTVs?.count ?? 0
    }
    
    func getTitle(for indexPath: IndexPath) -> UpcomingViewModel {
        let title = selectedMediaType == .Movie ? favouriteMovies?[indexPath.row] : favouriteTVs?[indexPath.row]
        return UpcomingViewModel(titleMO: title)
    }
}
