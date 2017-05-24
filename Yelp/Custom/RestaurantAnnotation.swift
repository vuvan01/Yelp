//
//  RestaurantAnnotation.swift
//  Yelp
//
//  Created by An Vu on 5/23/17.
//  Copyright © 2017 An Vu. All rights reserved.
//

import UIKit
import YelpAPI
import CoreLocation
import MapKit

open class RestaurantAnnotation: NSObject {
    
    open var coordinate = CLLocationCoordinate2D()
    open var title: String?
    open var subtitle: String?
    
    var restaurant: YLPBusiness!
}

extension RestaurantAnnotation : MKAnnotation {
    
}
