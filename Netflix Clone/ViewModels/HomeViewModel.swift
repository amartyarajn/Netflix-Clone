//
//  HomeViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 08/05/23.
//

import Foundation

protocol HomeViewModelDelegate: ErrorBaseViewModelDelegate, NavigateToVideoPreviewDelegate {
    func configureHeaderImage(with posterURL: URL?)
}

class HomeViewModel: BaseViewModel {
    
    let repository: TitlesRepositoryProtocol
    
    init(repository: TitlesRepositoryProtocol) {
        self.repository = repository
    }
    
    private let sectionTitles = ["Trending movies", "Popular", "Trending TV", "Upcoming movies", "Top rated"]
    weak var delegate: HomeViewModelDelegate?
//    var isError = false
    
    func fetchTitles(for indexPath: IndexPath, viewModel: HomeSectionViewModel) {
        print("Index0 \(indexPath.section)")
        switch indexPath.section {
        case 0:
            repository.getTrendingMovies { [weak self, viewModel] result in
                self?.parseTitleResponse(result: result, viewModel: viewModel)
            }
        case 1:
            repository.getPopularMovies { [weak self, viewModel] result in
                self?.parseTitleResponse(result: result, viewModel: viewModel)
            }
        case 2:
            repository.getTrendingTV { [weak self, viewModel] result in
                self?.parseTitleResponse(result: result, viewModel: viewModel)
            }
        case 3:
            repository.getUpcomingMovies { [weak self, viewModel] result in
                self?.parseTitleResponse(result: result, viewModel: viewModel)
            }
        case 4:
            repository.getTopRatedMovies { [weak self, viewModel] result in
                self?.parseTitleResponse(result: result, viewModel: viewModel)
            }
        default:
            break
        }
    }
    
    private func parseTitleResponse(result: Result<[TitleMOProtocol],APIErrorMO>, viewModel: HomeSectionViewModel) {
        switch result {
        case .success(let titles):
            viewModel.setTitles(with: titles)
        case .failure(let error):
            handleError(with: error.localizedDescription)
        }
    }
    
    func getHeaderImage() {
        repository.getDiscoverResult { [weak self] result in
            switch result {
            case .success(let title):
                self?.delegate?.configureHeaderImage(with: title.posterPath?.getImageURL())
            case .failure(let error):
                self?.handleError(with: error.localizedDescription)
            }
        }
    }
    
    private func handleError(with errMsg: String) {
        if !isError {
            delegate?.handleError(with: errMsg)
        }
    }
    
    func assignCellViewModel() -> HomeSectionViewModel {
        return HomeSectionViewModel()
    }
    
    func assignSideBarViewModel() -> SideBarViewModel {
        return SideBarViewModel(repository: UserSessionRepository())
    }
    
    func getNoOfSections() -> Int {
        return sectionTitles.count
    }
    
    func getSection(for index: Int) -> String {
        return sectionTitles[index]
    }
    
    func noOfItemsInSection() -> Int {
        return 1
    }
}

extension HomeViewModel: CollectionViewTableViewCellDelegate {
    func titleCellTapAction(title: TitleMOProtocol) {
        delegate?.navigateToVideoPreviewVC(with: title)
    }
}
