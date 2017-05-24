//
//  RestaurantAnnotationView.swift
//  Yelp
//
//  Created by An Vu on 5/23/17.
//  Copyright © 2017 An Vu. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class RestaurantAnnotationView: MKAnnotationView {
    
    weak var calloutView: RestaurantCalloutView?
    var clickDetailsAction: ((RestaurantCalloutView) -> Void)?
    
    override var annotation: MKAnnotation? {
        willSet {
            calloutView?.removeFromSuperview()
        }
    }
    
    
    let animationDuration: TimeInterval = 0.25
    
    
    init(annotation: MKAnnotation?, reuseIdentifier: String?, nvc: UINavigationController?, currentLocation: CLLocation) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = false
    }
    
    
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        canShowCallout = false
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    // MARK: - Show and hide callout as needed
    // If the annotation is selected, show the callout; if unselected, remove it
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        let restaurant = (annotation as! RestaurantAnnotation).restaurant!
        if selected {
            self.calloutView?.removeFromSuperview()
            
            let calloutView = (Bundle.main.loadNibNamed("RestaurantCalloutView", owner: self, options: nil))?[0] as! RestaurantCalloutView
            calloutView.annotation = annotation
            
            calloutView.rateview.rating = Float(restaurant.rating)
            
            calloutView.lblName.text = restaurant.name
            for address in restaurant.location.address{
                calloutView.lblAddress.text = address + ", " + restaurant.location.city + ", " + restaurant.location.postalCode
                break
            }
            calloutView.clickDetailsAction = clickDetailsAction
            
            calloutView.add(to: self)
            self.calloutView = calloutView
            
            if animated {
                calloutView.alpha = 0
                UIView.animate(withDuration: animationDuration) {
                    calloutView.alpha = 1
                }
            }
        } else {
            guard let calloutView = calloutView else { return }
            
            if animated {
                UIView.animate(withDuration: animationDuration, animations: {
                    calloutView.alpha = 0
                }, completion: { finished in
                    calloutView.removeFromSuperview()
                })
            } else {
                calloutView.removeFromSuperview()
            }
        }
    }
    
    
    
    // Ff the cell is reused, remove it from the super view.

    override func prepareForReuse() {
        super.prepareForReuse()
        
        calloutView?.removeFromSuperview()
    }
    
    
    
    // MARK: - Detect taps on callout
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event) { return hitView }
        
        if let calloutView = calloutView {
            let pointInCalloutView = convert(point, to: calloutView)
            return calloutView.hitTest(pointInCalloutView, with: event)
        }
        
        return nil
    }
    
}
