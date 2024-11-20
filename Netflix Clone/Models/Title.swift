//
//  Movie.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 30/04/23.
//

import Foundation

protocol TitleProtocol {
    var id: Int? { get }
    var mediaType: String? { get set}
    var tvOriginalName: String? { get }
    var overview: String? { get }
    var posterPath: String? { get }
    var tvName: String? { get }
    var movieName: String? { get }
    var movieOriginalName: String? { get }
}

struct TrendingTitlesResponse: Codable {
    let results: [Movie]
}

struct Movie: TitleProtocol, Codable {
    var id: Int?
    var mediaType: String?
    var tvOriginalName: String?
    var movieOriginalName: String?
    var overview: String?
    var posterPath: String?
    var tvName: String?
    var movieName: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case mediaType = "media_type"
        case movieOriginalName = "original_title"
        case overview = "overview"
        case posterPath = "poster_path"
        case movieName = "title"
        case tvOriginalName = "original_name"
        case tvName = "name"
    }
}

/* {
adult = 0;
"backdrop_path" = "/8HfjrSxfTVKmjNh8cJjbu5eXzcX.jpg";
"genre_ids" =             (
    10751,
    14,
    28,
    12
);
id = 420808;
"media_type" = movie;
"original_language" = en;
"original_title" = "Peter Pan & Wendy";
overview = "Wendy Darling, a young girl afraid to leave her childhood home behind, meets Peter Pan, a boy who refuses to grow up. Alongside her brothers and a tiny fairy, Tinker Bell, she travels with Peter to the magical world of Neverland. There, she encounters an evil pirate captain, Captain Hook, and embarks on a thrilling adventure that will change her life forever.";
popularity = "113.655";
"poster_path" = "/9NXAlFEE7WDssbXSMgdacsUD58Y.jpg";
"release_date" = "2023-04-20";
title = "Peter Pan & Wendy";
video = 0;
"vote_average" = "6.2";
"vote_count" = 102;
}
*/

protocol TitleMOProtocol {
    var id: Int? { get }
    var mediaType: String? { get set}
    var name: String? { get }
    var overview: String? { get }
    var posterPath: String? { get }
}

class TitleMO: TitleMOProtocol {
    var id: Int?
    var mediaType: String?
    var name: String?
    var overview: String?
    var posterPath: String?
    
    init(titleProtocol: TitleProtocol) {
        id = titleProtocol.id
        mediaType = titleProtocol.mediaType
        name = titleProtocol.movieName ?? titleProtocol.movieOriginalName ?? titleProtocol.tvName ?? titleProtocol.tvOriginalName
        overview = titleProtocol.overview
        posterPath = titleProtocol.posterPath
    }
    
    init(titleItem: TitleItem) {
        id = Int(titleItem.id64)
        mediaType = titleItem.mediaType
        name = titleItem.name
        overview = titleItem.overview
        posterPath = titleItem.posterPath
    }
}
