//
//  DetailViewTableViewCell.swift
//  OMDB iOS Client App
//
//  Created by Radhakrishnan A on 11/1/20.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import UIKit

class ImageViewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    
    @IBOutlet weak var OMDBimageView: UIImageView!
    
    //Sets the image based on the status
    func configCell(data: OMDBModel,indexpath: IndexPath) {
        titleLabel.text = data.title
        yearLabel.text = data.getYear()! + " Years ago"
        typeLabel.text = data.type.capitalized
        switch data.state {
        case .new:
            OMDBimageView.image = UIImage(named: "placeholder")
        case .failed:
            OMDBimageView.image = UIImage(named: "failed")
        case .downloaded:
            OMDBimageView.image = data.image
        }
    }
}
