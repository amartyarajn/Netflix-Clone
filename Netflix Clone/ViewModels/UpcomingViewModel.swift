//
//  UpcomingViewModel.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 01/05/23.
//

import Foundation

struct UpcomingViewModel {
    let originalTitle: String?
    let imageURL: URL?
    
    init(titleMO: TitleMOProtocol?) {
        originalTitle = titleMO?.name
        imageURL = titleMO?.posterPath?.getImageURL()
    }
}
