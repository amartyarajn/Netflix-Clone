//
//  HomeSectionViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 09/05/23.
//

import Foundation

protocol HomeSectionViewModelDelegate: AnyObject {
    func handleTitleUpdate()
}

protocol CollectionViewTableViewCellDelegate:AnyObject {
    func titleCellTapAction(title: TitleMOProtocol)
}

class HomeSectionViewModel {
    
    weak var delegate: HomeSectionViewModelDelegate?
    weak var tapDelegate: CollectionViewTableViewCellDelegate?
    
    private var titles: [TitleMOProtocol]? {
        didSet {
            delegate?.handleTitleUpdate()
        }
    }
    
    func setTitles(with values: [TitleMOProtocol]) {
        titles = values
    }
    
    func getNoOfItems() -> Int {
        return titles?.count ?? 0
    }
    
    func getPosterPath(for indexPath: IndexPath) -> URL? {
        let posterPath = titles?[indexPath.item].posterPath ?? ""
        return posterPath.getImageURL()
    }
    
    func handleCellTap(for indexPath: IndexPath) {
        let title = titles?[indexPath.item]
        self.tapDelegate?.titleCellTapAction(title: title!)
    }
}
