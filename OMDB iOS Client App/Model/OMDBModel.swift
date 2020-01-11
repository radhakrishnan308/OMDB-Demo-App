//
//  OMDBModel.swift
//  OMDB iOS Client App
//
//  Created by Radhakrishnan A on 11/1/20.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import UIKit

enum PhotoRecordState {
  case new, downloaded, failed
}
class OMDBModel {
    //Constants
    static let kTitle = "Title"
    static let kYear = "Year"
    static let kImdbID = "imdbID"
    static let kType = "Type"
    static let kPoster = "Poster"
    
    let title: String
    let imdbID: String
    let year: Int
    let type: String
    let poster: String
    var image: UIImage?
    var state = PhotoRecordState.new
    var photoUrl: String {
        return OMDBImageURL()!
    }
    
    func OMDBImageURL() -> String? {
      return poster
    }
    
    func getYear() -> String? {
        let currentYear = Calendar.current.component(.year, from: Date())
        return String(currentYear - year)
    }
    
    init(titleString: String?, imdbIDString: String? ,typeString: String? ,posterString: String?, yearString: String?){
        title = titleString!
        year = Int(yearString!.prefix(4))!
        imdbID = imdbIDString!
        type = typeString!
        poster = posterString!
        if !(posterString?.contains("http"))! {
            state = .failed
        }
        image = nil
    }
    
    //To parse the array of data
    static func parse(dataSet : [NSDictionary]) -> Array<OMDBModel> {
        return dataSet.map { object in
            let oMDBModel = OMDBModel(titleString: object.object(forKey: OMDBModel.kTitle) as? String, imdbIDString: object.object(forKey: OMDBModel.kImdbID) as? String, typeString: object.object(forKey: OMDBModel.kType) as? String, posterString: object.object(forKey: OMDBModel.kPoster) as? String, yearString: object.object(forKey: OMDBModel.kYear) as? String)
            return oMDBModel
        }
    }
}
