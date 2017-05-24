//
//  DetailViewController.swift
//  Yelp
//
//  Created by An Vu on 5/23/17.
//  Copyright © 2017 An Vu. All rights reserved.
//

import UIKit
import YelpAPI
import Kingfisher

class DetailViewController: UIViewController {

    var restaurant: YLPBusiness!
    
    @IBOutlet weak var ivRestaurant: UIImageView!
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblCategory: UILabel!
    @IBOutlet weak var lblReviewCount: UILabel!
    @IBOutlet weak var rateView: FloatRatingView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
    }
    
    private func initView(){
        title = restaurant.name
        
        if let imageURL = restaurant.imageURL{
            progressView.startAnimating()
            ivRestaurant.kf.setImage(with: imageURL, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { [weak self] (image, error, cache, url) in
                guard let ss = self else { return }
                ss.progressView.stopAnimating()
            })
        }
        
        lblName.text = restaurant.name
        lblPhone.text = (restaurant.phone ?? "")
        lblReviewCount.text = "Review Counts: \(restaurant.reviewCount)"
        
        var categories = ""
        for category in restaurant.categories{
            categories = categories + " " + category.name
        }
        lblCategory.text = "Category: " + categories
        rateView.rating = Float(restaurant.rating)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
