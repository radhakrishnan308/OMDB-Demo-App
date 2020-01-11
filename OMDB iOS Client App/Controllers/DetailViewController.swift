//
//  DetailViewController.swift
//  OMDB iOS Client App
//
//  Created by radhakrishnan on 11/1/20.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var loaderView: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    var model: OMDBModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.delegate = self
        if model.state != .failed {
            loadImage()
        }else{
            imageView.image = UIImage(named: "failed")
        }
        
        titleLabel.text = model.title
        yearLabel.text = model.getYear()! + " Years ago"
        typeLabel.text = model.type.capitalized
    }
    
    
    //Loads the Image from URL
    func loadImage () {
        self.loaderView.startAnimating()
        ServiceManager.fetchDataForURL(URL: model.OMDBImageURL()!) { [weak self] (error, data) in
            DispatchQueue.main.async {
                if error == nil{
                    self?.imageView.image = UIImage(data:data!)
                    self?.loaderView.stopAnimating()
                }
            }
        }
    }
    
    //To pinch and zoom over the imageview
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        for view in scrollView.subviews where view is UIImageView {
            return view as! UIImageView
        }
        return nil
    }
    
}
