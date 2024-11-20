//
//  TitleItem+CoreDataProperties.swift
//  Netflix Clone
//
//  Created by Amartya Narain on 13/05/23.
//
//

import Foundation
import CoreData

extension TitleItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TitleItem> {
        return NSFetchRequest<TitleItem>(entityName: "TitleItem")
    }

    @NSManaged public var id64: Int64
    @NSManaged public var mediaType: String?
    @NSManaged public var originalLanguage: String?
    @NSManaged public var originalName: String?
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var releaseDate: Date?
    @NSManaged public var name: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var voteCount: Int64
    @NSManaged public var accountId64: Int64

}
