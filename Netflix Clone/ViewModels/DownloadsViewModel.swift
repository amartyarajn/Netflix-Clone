//
//  DownloadsViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 10/05/23.
//

import Foundation

protocol DownloadsViewModelDelegate: NavigateToVideoPreviewDelegate {
    func handleTitleUpdate()
    func handleDeleteAction(for indexPaths: [IndexPath])
}

class DownloadsViewModel: BaseViewModel {
    
    let repository: AccountListsRepositoryProtocol
    
    init(repository: AccountListsRepositoryProtocol) {
        self.repository = repository
    }
    
    private var titles = [TitleMOProtocol]() {
        didSet {
            delegate?.handleTitleUpdate()
        }
    }
    
    weak var delegate: DownloadsViewModelDelegate?
    var isMoviesLoadingRequired: Bool?
    
    func getDownloadedMovies() {
        self.titles = repository.getTitles()
    }
    
    func handleCellTap(for indexPath: IndexPath) {
        let title = titles[indexPath.item]
        delegate?.navigateToVideoPreviewVC(with: title)
    }
    
    func deleteTitle(for indexPath: IndexPath) {
        let title = titles[indexPath.item]
        if repository.deleteTitle(with: Int(title.id ?? 0)) {
            delegate?.handleDeleteAction(for: [indexPath])
            titles.remove(at: indexPath.item)
        }
    }
    
    func getNoOfItems() -> Int {
        return titles.count
    }
    
    func getTitle(for indexPath: IndexPath) -> UpcomingViewModel {
        let title = titles[indexPath.row]
        return UpcomingViewModel(titleMO: title)
    }
}
