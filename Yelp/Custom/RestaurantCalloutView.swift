//
//  RestaurantCalloutView.swift
//  Yelp
//
//  Created by An Vu on 5/23/17.
//  Copyright © 2017 An Vu. All rights reserved.
//

import UIKit
import YelpAPI
import MapKit

class RestaurantCalloutView: UIView {
    
    var restaurant: YLPBusiness!
    
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var viewBorder: UIView!
    @IBOutlet weak var rateview: FloatRatingView!
    
    private var _annotation: MKAnnotation!
    
    var clickDetailsAction: ((RestaurantCalloutView) -> Void)?
    
    @IBAction func clickDetails(sender: UIButton){
        clickDetailsAction?(self)
    }
    
    public var annotation:MKAnnotation!{
        set(anno){
            _annotation = anno
        }
        
        get{
            return _annotation
        }
    }
    
    func add(to annotationView: MKAnnotationView) {
        annotationView.addSubview(self)
        
        self.frame.origin.x = 0 + 15 - self.frame.size.width / 2
        self.frame.origin.y = 0 + 4 - self.frame.size.height
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewBorder.layer.cornerRadius = 6.0
    }
    
    
}
