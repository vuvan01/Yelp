//
//  MainViewController.swift
//  Yelp
//
//  Created by An Vu on 5/23/17.
//  Copyright © 2017 An Vu. All rights reserved.
//

import UIKit
import YelpAPI
import MapKit
import Pods_Yelp

struct MapZoom{
    static let longitude = 1000.0
    static let latitude = 1000.0
}

struct YelpResult{
    static let limit: UInt = 50
    static let offset: UInt = 0
}

class MainViewController: UIViewController {

    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    
    var ylpClient: YLPClient?
    var currentMapCenter:CLLocationCoordinate2D?
    
    let dispatchGroupYLPClient = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Restaurants"

        progressView.startAnimating()
        (UIApplication.shared.delegate as! AppDelegate).locationDelegate = self
        
        dispatchGroupYLPClient.enter()
        YLPClient.authorize(withAppId: YELP.clientID, secret: YELP.secret) { [weak self] (client, error) in
            guard let ss = self else { return }
            if let client = client{
                ss.ylpClient = client
                ss.dispatchGroupYLPClient.leave()
            }
        }
    }
    
    func searchRestaurant(ylpCoordinate: YLPCoordinate){
        ylpClient?.search(with: ylpCoordinate, term: YELP.searchTerm, limit: YelpResult.limit, offset: YelpResult.offset, sort: YLPSortType.distance, completionHandler: { [weak self] (search, error) in
            guard let ss = self else { return }
            if let _ = error{
                ss.alert(message: ALERT.errorSearching)
            }else{
                // add annotations to mapview
                DispatchQueue.main.async {
                    if let businesses = search?.businesses{
                        // remove existing pins on map
                        ss.mapview.removeAnnotations(ss.mapview.annotations)
                        for item in businesses{
                            if let coordinate = item.location.coordinate{
                                let annotation = RestaurantAnnotation()
                                annotation.title = item.name
                                annotation.coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                annotation.restaurant = item
                                ss.mapview.addAnnotation(annotation)
                            }
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    ss.progressView.stopAnimating()
                }
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        (UIApplication.shared.delegate as! AppDelegate).locationDelegate = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}



extension MainViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // fetch data when user moves map more than 500m
        let center = mapView.centerCoordinate
        if let currentMapCenter = currentMapCenter{
            let currentCenter = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let lastCenter = CLLocation(latitude: currentMapCenter.latitude, longitude: currentMapCenter.longitude)
            let distance = currentCenter.distance(from: lastCenter)
            if abs(distance) > 500{
                self.currentMapCenter = center
                let coordinate = YLPCoordinate(latitude: center.latitude, longitude: center.longitude)
                searchRestaurant(ylpCoordinate: coordinate)
            }else{
                print("user moves map, but not > 500m")
            }
        }else{
            currentMapCenter = center
        }
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "reuseID"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
        if pinView == nil{
            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.image = #imageLiteral(resourceName: "pin")
            let btnInfo = UIButton(type: .detailDisclosure)
            pinView?.rightCalloutAccessoryView = btnInfo
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailViewController.restaurant = (view.annotation as! RestaurantAnnotation).restaurant
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
}



extension MainViewController: DidGetLatestLocationDelegate{
    
    func didGetLocation(location: CLLocation) {
        // move map to current user's location
        let mapCenter = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let adjustedRegion = mapview.regionThatFits(MKCoordinateRegionMakeWithDistance( mapCenter, MapZoom.latitude, MapZoom.longitude))
        mapview.setRegion(adjustedRegion, animated: true)
        
        
        // fetch data
        let coordinate = YLPCoordinate(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        dispatchGroupYLPClient.notify(queue: .main) { [weak self] in
            guard let ss = self else { return }
            ss.searchRestaurant(ylpCoordinate: coordinate)
        }
    }
    
}



extension MainViewController{
    
    func alert(message: String, title: String = ALERT.appName) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: BUTTON.ok, style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
