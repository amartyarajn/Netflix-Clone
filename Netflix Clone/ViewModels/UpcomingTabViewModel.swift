//
//  UpcomingTabViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 10/05/23.
//

import Foundation
import UIKit

protocol UpcomingTabViewModelDelegate: ErrorBaseViewModelDelegate, NavigateToVideoPreviewDelegate {
    func handleTitleUpdate()
}

class UpcomingTabViewModel: BaseViewModel {
    
    let repository: TitlesRepositoryProtocol
    
    init(repository: TitlesRepositoryProtocol) {
        self.repository = repository
    }
    
    private var titles = [TitleMOProtocol]() {
        didSet {
            delegate?.handleTitleUpdate()
        }
    }
    
    weak var delegate: UpcomingTabViewModelDelegate?
    
    func getUpcomingMovies() {
        repository.getUpcomingMovies { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
            case .failure(let error):
                if self?.isError == false {
                    self?.delegate?.handleError(with: error.localizedDescription)
                }
            }
        }
    }
    
    func handleCellTap(for indexPath: IndexPath) {
        let title = titles[indexPath.item]
        delegate?.navigateToVideoPreviewVC(with: title)
    }
    
    func getNoOfItems() -> Int {
        return titles.count
    }
    
    func getTitle(for indexPath: IndexPath) -> UpcomingViewModel {
        let title = titles[indexPath.row]
        return UpcomingViewModel(titleMO: title)
    }
}

protocol ErrorBaseViewModelDelegate: UIViewController {
    func handleError(with errorMsg: String)
}

protocol NavigateToVideoPreviewDelegate: UIViewController {
    func navigateToVideoPreviewVC(with title: TitleMOProtocol)
}

class BaseViewModel {
    var isError = false
    
    func assignVideoPreviewViewModel() -> VideoPreviewViewModel {
        return VideoPreviewViewModel(repository: VideoPreviewRepository())
    }
}
