//
//  SearchViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 11/05/23.
//

import Foundation

protocol SearchViewModelDelegate: ErrorBaseViewModelDelegate, NavigateToVideoPreviewDelegate {

}

class SearchViewModel: BaseViewModel {
    
    let repository: TitlesRepositoryProtocol
    
    init(repository: TitlesRepositoryProtocol) {
        self.repository = repository
    }
    
    private var currentWorkItem: DispatchWorkItem?
    weak var delegate: SearchViewModelDelegate?
    
    func getSearchResults(for query: String, viewModel: SearchResultsViewModel?) {
        currentWorkItem?.cancel()
        
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty, query.trimmingCharacters(in: .whitespaces).count >= 3 else {
            return
        }
        let workItem = DispatchWorkItem { [weak self, weak viewModel] in
            self?.repository.getSearchResults(query: query) { result in
                switch result {
                case .success(let titles):
                    viewModel?.setTitles(with: titles)
                case .failure(let error):
                    if self?.isError == false {
                        self?.delegate?.handleError(with: error.localizedDescription)
                    }
                }
            }
        }
        currentWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: workItem)
    }
    
    func assignSearchResultViewModel() -> SearchResultsViewModel {
        return SearchResultsViewModel()
    }
}

extension SearchViewModel: SearchResultsViewControllerDelegate {
    func titleCellTapAction(title: TitleMOProtocol) {
        delegate?.navigateToVideoPreviewVC(with: title)
    }
}
