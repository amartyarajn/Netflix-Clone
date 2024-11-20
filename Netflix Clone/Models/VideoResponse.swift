//
//  VideoResponse.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 04/05/23.
//

import Foundation

/*
 {
     id = 1085103;
     results =     (
                 {
             id = 64521ff8c0442900e2f0adad;
             "iso_3166_1" = US;
             "iso_639_1" = en;
             key = dsmuf95eshk;
             name = "Official Trailer";
             official = 1;
             "published_at" = "2023-05-03T00:21:36.000Z";
             site = YouTube;
             size = 1080;
             type = Trailer;
         }
     );
 }
 */

struct VideoResponse: Codable {
    let results: [VideoElement]
}

struct VideoElement: Codable {
    let id: String?
    let key: String?
    let site: String?
    let type: String?
}
