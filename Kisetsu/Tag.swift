//
//  Tag.swift
//  AniManager
//
//  Created by Tobias Helmrich on 10.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

struct Tag {
    let name: String
    let description: String
    let isSpoiler: Bool
    
    init?(fromDictionary dictionary: [String:Any]) {
        
        typealias TagResponseKey = AniListConstant.ResponseKey.Tag
        
        guard let name = dictionary[TagResponseKey.name] as? String,
        let description = dictionary[TagResponseKey.description] as? String,
            let isSpoiler = dictionary[TagResponseKey.isSpoiler] as? Bool else {
                return nil
        }
        
        self.name = name
        self.description = description
        self.isSpoiler = isSpoiler
        
    }
    
    /*
        This function takes in an array of dictionaries and tries to
        create an array of tag objects from it by looping through the
        dictionaries and creating tag objects with its dictionary
        initializer
    */
    static func createTagArray(fromDictionaries dictionaries: [[String:Any]]) -> [Tag]? {
        var tags = [Tag]()
        for dictionary in dictionaries {
            guard let tag = Tag(fromDictionary: dictionary) else {
                return nil
            }
            tags.append(tag)
        }
        return tags
    }
}
