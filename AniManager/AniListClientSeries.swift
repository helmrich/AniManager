//
//  AniListClientSeries.swift
//  AniManager
//
//  Created by Tobias Helmrich on 15.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

extension AniListClient {
    /*
        This method tries to get an array of series objects from a specific
        page with a defined type (e.g. anime or manga) and parameters (such as
        release year, genres, sorting, etc.)
     */
    func getSeriesList(fromPage page: Int = 1, ofType seriesType: SeriesType, andParameters parameters: [String:Any], matchingQuery query: String? = nil, completionHandlerForSeriesList: @escaping (_ seriesList: [Series]?, _ nonAdultSeriesList: [Series]?, _ errorMessage: String?) -> Void) {
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForSeriesList(nil, nil, errorMessage!)
                return
            }
            
            // URL creation and request configuration
            var replacingPairs = [
                AniListConstant.Path.Placeholder.seriesType: seriesType.rawValue
            ]
            
            var allParameters = parameters
            let path: String
            if let query = query {
                replacingPairs[AniListConstant.Path.Placeholder.query] = query
                path = self.replacePlaceholders(inPath: AniListConstant.Path.SeriesGet.search, withReplacingPairs: replacingPairs)
            } else {
                path = self.replacePlaceholders(inPath: AniListConstant.Path.SeriesGet.browse, withReplacingPairs: replacingPairs)
                allParameters[AniListConstant.ParameterKey.Browse.page] = page
            }
            
            guard let url = self.createAniListUrl(withPath: path, andParameters: allParameters) else {
                completionHandlerForSeriesList(nil, nil, "Couldn't create AniList URL")
                return
            }
            
            let request = self.createDefaultRequest(withUrl: url)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                // Error Handling
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForSeriesList(nil, nil, errorMessage)
                    return
                }
                
                let data = data!

                // JSON Deserialization
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForSeriesList(nil, nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let rawSeriesList = jsonObject as? [[String:Any]] else {
                    completionHandlerForSeriesList(nil, nil, "Couldn't cast JSON to array of dictionaries")
                    return
                }
                
                
                /*
                    Create and fill a list of series by first checking which series
                    type was requested and depending on that trying to create series
                    by iterating over all dictionaries in the raw series list array
                 */
                typealias seriesKey = AniListConstant.ResponseKey.Series
                
                var seriesList = [Series]()
                if seriesType == .anime {
                    seriesList = seriesList as! [AnimeSeries]
                    for series in rawSeriesList {
                        if let animeSeries = AnimeSeries(fromDictionary: series) {
                            seriesList.append(animeSeries)
                        } else {
                            completionHandlerForSeriesList(nil, nil, "Couldn't get anime series")
                            return
                        }
                    }
                } else {
                    seriesList = seriesList as! [MangaSeries]
                    for series in rawSeriesList {
                        if let mangaSeries = MangaSeries(fromDictionary: series) {
                            seriesList.append(mangaSeries)
                        } else {
                            completionHandlerForSeriesList(nil, nil, "Couldn't get manga series")
                            return
                        }
                    }
                }
                
                let nonAdultSeriesList = seriesList.filter { !($0.isAdult) }
                
                completionHandlerForSeriesList(seriesList, nonAdultSeriesList, nil)
                
            }
            
            task.resume()
            
        }
    }
    
    /*
        This method gets a single series with a specified ID and series type
     */
    func getSingleSeries(ofType seriesType: SeriesType, withId id: Int, completionHandlerForSeries: @escaping (_ series: Series?, _ errorMessage: String?) -> Void) {
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForSeries(nil, errorMessage!)
                return
            }
            
            // URL creation and request configuration
            let replacingPairs = [
                AniListConstant.Path.Placeholder.seriesType: seriesType.rawValue,
                AniListConstant.Path.Placeholder.id: "\(id)"
            ]
            
            let path = self.replacePlaceholders(inPath: AniListConstant.Path.SeriesGet.pageSeriesModel, withReplacingPairs: replacingPairs)
            
            guard let url = self.createAniListUrl(withPath: path, andParameters: [:]) else {
                completionHandlerForSeries(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = self.createDefaultRequest(withUrl: url)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                // Error Handling
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForSeries(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                // JSON Deserialization
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForSeries(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let rawSeriesDictionary = jsonObject as? [String:Any] else {
                    completionHandlerForSeries(nil, "Couldn't cast JSON to dictionary")
                    return
                }
                
                
                /*
                    Check whether the requested series type is of anime or manga type
                    and try to create an appropriate object depending on this from the
                    raw series dictionary that was casted from the JSON object. Depending
                    on whether creating the object the completion handler should either be
                    called with the created object or an error message.
                 */
                typealias seriesKey = AniListConstant.ResponseKey.Series
                
                if seriesType == .anime {
                    if let animeSeries = AnimeSeries(fromDictionary: rawSeriesDictionary) {
                        DataSource.shared.selectedSeries = animeSeries
                        completionHandlerForSeries(animeSeries, nil)
                        return
                    } else {
                        completionHandlerForSeries(nil, "Couldn't get Anime series")
                        return
                    }
                } else {
                    if let mangaSeries = MangaSeries(fromDictionary: rawSeriesDictionary) {
                        DataSource.shared.selectedSeries = mangaSeries
                        completionHandlerForSeries(mangaSeries, nil)
                        return
                    } else {
                        completionHandlerForSeries(nil, "Couldn't get Manga series")
                        return
                    }
                }
            }
            
            task.resume()
            
        }
    }
    
    // This method gets the page model for a character with a specified character ID
    func getPageModelCharacter(forCharacterId id: Int, completionHandlerForCharacterPageModel: @escaping (_ character: Character?, _ errorMessage: String?) -> Void) {
        
        
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForCharacterPageModel(nil, errorMessage!)
                return
            }
            
            // URL creation and request configuration
            let replacingPairs = [
                AniListConstant.Path.Placeholder.id: "\(id)"
            ]
            let path = self.replacePlaceholders(inPath: AniListConstant.Path.CharacterGet.pageCharacterModel, withReplacingPairs: replacingPairs)
            guard let url = self.createAniListUrl(withPath: path, andParameters: [:]) else {
                completionHandlerForCharacterPageModel(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = self.createDefaultRequest(withUrl: url)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                // Error Handling
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForCharacterPageModel(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                // JSON Deserialization
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForCharacterPageModel(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let characterDictionary = jsonObject as? [String:Any],
                    let character = Character(fromDictionary: characterDictionary) else {
                        completionHandlerForCharacterPageModel(nil, "Couldn't create character object from dictionary")
                        return
                }
                
                completionHandlerForCharacterPageModel(character, nil)
                
            }
            
            task.resume()
            
        }
    }
    
    func getGenreList(completionHandlerForGenreList: @escaping (_ genreList: [String]?, _ errorMessage: String?) -> Void) {
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForGenreList(nil, errorMessage!)
                return
            }
         
            guard let url = self.createAniListUrl(withPath: AniListConstant.Path.SeriesGet.genreList, andParameters: [:]) else {
                completionHandlerForGenreList(nil, "Couldn't create AniList URL")
                return
            }
            
            let request = self.createDefaultRequest(withUrl: url)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForGenreList(nil, errorMessage)
                    return
                }
                
                let data = data!
                
                guard let jsonObject = self.deserializeJson(fromData: data) else {
                    completionHandlerForGenreList(nil, "Couldn't deserialize data into a JSON object")
                    return
                }
                
                guard let genreDictionaries = jsonObject as? [[String:Any]] else {
                    completionHandlerForGenreList(nil, "Couldn't cast JSON object to a usable array")
                    return
                }
                
                var genreList = [String]()
                for genreDictionary in genreDictionaries {
                    if let genre = genreDictionary[AniListConstant.ResponseKey.GenreList.genre] as? String {
                        genreList.append(genre)
                    }
                }
                
                let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileUrl = documentsUrl.appendingPathComponent("genres.plist")
                (genreList as NSArray).write(to: fileUrl, atomically: true)
                
                completionHandlerForGenreList(genreList, nil)
                
            }
            
            task.resume()
            
        }
    }
    
    // MARK: - POST/PUT
    
    // This method is used to favorite a series with a specified type and ID
    func favorite(seriesOfType type: SeriesType, withId id: Int, completionHandlerForFavoriting: @escaping (_ errorMessage: String?) -> Void) {
        let replacingPairs = [
            AniListConstant.Path.Placeholder.seriesType: type.rawValue
        ]
        
        let path = self.replacePlaceholders(inPath: AniListConstant.Path.SeriesPost.favourite, withReplacingPairs: replacingPairs)
        
        favorite(id: id, path: path, completionHandlerForFavoriting: completionHandlerForFavoriting)
    }
    
    // This method is used to favorite a character with a specified ID
    func favorite(characterWithId id: Int, completionHandlerForFavoriting: @escaping (_ errorMessage: String?) -> Void) {
        let path = AniListConstant.Path.CharacterPost.favourite
        
        favorite(id: id, path: path, completionHandlerForFavoriting: completionHandlerForFavoriting)
    }
    
    /*
        This method contains the general networking code for favoriting an object
        with an ID (e.g. series, character) and should be called inside of a more
        specific method that specifies a path based on the object type
     */
    fileprivate func favorite(id: Int, path: String, completionHandlerForFavoriting: @escaping (_ errorMessage: String?) -> Void) {
        validateAccessToken { (errorMessage) in
            guard errorMessage == nil else {
                completionHandlerForFavoriting(errorMessage!)
                return
            }
            
            // URL creation and request configuration
            guard let url = self.createAniListUrl(withPath: path, andParameters: [:]) else {
                completionHandlerForFavoriting("Couldn't create AniList URL")
                return
            }
            
            /*
                Create and configure a request with the created URL. Assign "POST"
                to the request's httpMethod property and create HTTP body data from
                a JSON-like formatted string and assign it to the request's httpBody
                property.
             */
            let request = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = "{\"id\":\"\(id)\"}".data(using: .utf8)
            request.addValue(AniListConstant.HeaderFieldValue.contentTypeJson, forHTTPHeaderField: AniListConstant.HeaderFieldName.contentType)
            request.addValue("Bearer \(UserDefaults.standard.string(forKey: "accessToken")!)", forHTTPHeaderField: AniListConstant.HeaderFieldName.authorization)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                // Error Handling
                if let errorMessage = self.checkDataTaskResponseForError(data: data, response: response, error: error) {
                    completionHandlerForFavoriting(errorMessage)
                    return
                }
                
                let data = data!
                
                // JSON Deserialization
                guard let _ = self.deserializeJson(fromData: data) else {
                    completionHandlerForFavoriting("Couldn't deserialize data into a JSON object")
                    return
                }
                
                completionHandlerForFavoriting(nil)
                
            }
            
            task.resume()
            
        }
    }
}
