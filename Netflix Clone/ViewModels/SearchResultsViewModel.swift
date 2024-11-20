//
//  SearchResultsViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 11/05/23.
//

import Foundation

protocol SearchResultsViewModelDelegate: AnyObject {
    func handleResultsUpdate()
}

class SearchResultsViewModel {
    
    weak var delegate: SearchResultsViewModelDelegate?
    weak var tapDelegate: SearchResultsViewControllerDelegate?
    
    private var titles = [TitleMOProtocol]() {
        didSet {
            delegate?.handleResultsUpdate()
        }
    }
    
    func handleCellTap(for indexPath: IndexPath) {
        let title = titles[indexPath.item]
        tapDelegate?.titleCellTapAction(title: title)
    }
    
    func setTitles(with titles: [TitleMOProtocol]) {
        self.titles = titles
    }
    
    func getNoOfItems() -> Int {
        return titles.count
    }
    
    func getItem(for indexPath: IndexPath) -> URL? {
        let imageURL = titles[indexPath.item].posterPath?.getImageURL()
        return imageURL
    }
}
