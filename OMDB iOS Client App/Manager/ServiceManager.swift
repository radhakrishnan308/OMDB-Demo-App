//
//  ServiceManager.swift
//  OMDB iOS Client App
//
//  Created by Radhakrishnan A on 11/1/20.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import UIKit

typealias OMDBResponse = (NSError?, [OMDBModel]? ,PageModel?) -> Void
typealias ImageResponse = (NSError?, Data?) -> Void


class ServiceManager: NSObject {
    
    static let kResponse = "Response"
    static let kTrue = "True"
    static let kError = "Error"
    static let kSearch = "Search"
    static let kTotalResults = "totalResults"

    
    
    static let apiCache = NSCache<NSString, NSData>()
    struct Errors {
        static let invalidAccessErrorCode = 100
    }
    
    //To Fetch the data from the OMDB API
    class func fetchPhotosForSearchText(searchText: String,pageNo: Int, onCompletion: @escaping OMDBResponse) -> Void {
        let escapedSearchText: String = searchText.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed)!
        let urlString: String = "https://www.omdbapi.com/?s=\(escapedSearchText)&page=\(pageNo)&apikey=\(Keys.APIKey)"

        let url: NSURL = NSURL(string: urlString)!
        let searchTask = URLSession.shared.dataTask(with: url as URL, completionHandler: {data, response, error -> Void in
            
            if error != nil {
                print("Error fetching photos: \(String(describing: error))")
                onCompletion(error as NSError?, [], nil)
                return
            }
            
            do {
                let resultsDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
                guard let results = resultsDictionary else { return }
                
                if let statusCode = results[kResponse] as? String {
                    if let error = results[kError] as? String,statusCode != kTrue {
                        let invalidAccessError = NSError(domain: "com.OMDB.api", code: Errors.invalidAccessErrorCode, userInfo: [NSLocalizedDescriptionKey : error])
                        onCompletion(invalidAccessError, nil, nil)
                        return
                    }
                }
                
                guard let photosArray = resultsDictionary![kSearch] as? [NSDictionary] else { return }
                
                let OMDBPhotos: [OMDBModel] = OMDBModel.parse(dataSet: photosArray)
                let paging: PageModel?
                if let numberOfElements = resultsDictionary![kTotalResults] as? String {
                    let numberOfPage = Int(numberOfElements)! % 10 == 0 ? Int(numberOfElements)!/10 : (Int(numberOfElements)!/10) + 1
                    paging = PageModel(totalPages: numberOfPage, elements: Int(numberOfElements)!, currentPage: pageNo)
                    onCompletion(nil, OMDBPhotos, paging)
                }

            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(error, nil, nil)
                return
            }
            
        })
        searchTask.resume()
    }
    
    //To Download data of the given URL
    class func fetchDataForURL(URL: String, onCompletion: @escaping ImageResponse) -> Void {
        if let cachedImage = apiCache.object(forKey: URL as NSString) {
            onCompletion(nil, cachedImage as Data)
        }else{

        let url: NSURL = NSURL(string: URL)!
        let searchTask = URLSession.shared.dataTask(with: url as URL, completionHandler: { (data, response, error) in
            if error != nil {
                print("Error fetching photos: \(String(describing: error))")
                onCompletion(error as NSError?,nil)
                return
            }
            self.apiCache.setObject(data! as NSData, forKey: URL as NSString)
                onCompletion(nil, data)
        })
        searchTask.resume()
    }
    }
}
