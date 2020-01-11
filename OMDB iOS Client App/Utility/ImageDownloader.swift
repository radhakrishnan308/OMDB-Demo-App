//
//  ImageDownloader.swift
//  OMDB iOS Client App
//
//  Created by radhakrishnan on 11/1/20.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import UIKit

class ImageDownloader: Operation {
    
    //Hold the reference of the Model object
    let oMDBModel: OMDBModel
    
    init(_ omdb: OMDBModel) {
        self.oMDBModel = omdb
    }
    
    //This will get executed on initialisation
    override func main() {
        if isCancelled {
            return
        }
        
        guard let imageData = try? Data(contentsOf:URL(string:oMDBModel.photoUrl)!) else {
            oMDBModel.image = UIImage(named: "failed")
            oMDBModel.state = .failed
            return
            
        }
        
        if isCancelled {
            return
        }
        
        if !imageData.isEmpty {
            oMDBModel.image = UIImage(data:imageData)
            oMDBModel.state = .downloaded
        } else {
            oMDBModel.image = UIImage(named: "failed")
            oMDBModel.state = .failed
        }
        
        if isCancelled {
            return
        }
    }
}
