//
//  BasicSeries+CoreDataProperties.swift
//  AniManager
//
//  Created by Tobias Helmrich on 27.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation
import CoreData


extension BasicSeries {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BasicSeries> {
        return NSFetchRequest<BasicSeries>(entityName: "BasicSeries");
    }

    @NSManaged public var averageScore: Double
    @NSManaged public var coverImageData: NSData?
    @NSManaged public var id: Int32
    @NSManaged public var imageMediumUrlString: String?
    @NSManaged public var popularity: Int32
    @NSManaged public var seriesType: String?
    @NSManaged public var titleEnglish: String?
    @NSManaged public var titleRomaji: String?
    @NSManaged public var seriesList: SeriesList?

}