//
//  AppDelegate.swift
//  Yelp
//
//  Created by An Vu on 5/23/17.
//  Copyright © 2017 An Vu. All rights reserved.
//

import UIKit
import CoreLocation

protocol DidGetLatestLocationDelegate {
    func didGetLocation(location: CLLocation)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let locationManager = CLLocationManager()
    var locationDelegate: DidGetLatestLocationDelegate? = nil {
        didSet{
            if let _ = locationDelegate{
                if CLLocationManager.locationServicesEnabled() == false{
                    alertGPS(message: ALERT.locationTurnOff)
                }else{
                    locationManager.startUpdatingLocation()
                }
            }else{
                locationManager.stopUpdatingLocation()
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // LOCATION
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)    {
        locationManager.stopUpdatingLocation()
        alert(message: ALERT.locationError)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        
        if let deleg = locationDelegate{
            deleg.didGetLocation(location: locationObj)
        }
        
        locationManager.stopUpdatingLocation()
        
    }
    
    func alertGPS(message: String){
        let vc = self.window?.rootViewController
        if vc?.presentedViewController == nil{
            let alertController = UIAlertController(title: ALERT.appName, message: message, preferredStyle: .alert)
            let actionNO = UIAlertAction(title: BUTTON.no, style: .destructive, handler: nil)
            alertController.addAction(actionNO)
            let actionYES = UIAlertAction(title: BUTTON.yes, style: .default, handler: { (action) in
                let url = URL(string : UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(url!)
                
            })
            alertController.addAction(actionYES)
            vc?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func alert(message: String){
        let vc = self.window?.rootViewController
        if vc?.presentedViewController == nil{
            let alertController = UIAlertController(title: ALERT.appName, message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: BUTTON.ok, style: .destructive, handler: nil)
            alertController.addAction(OKAction)
            vc?.present(alertController, animated: true, completion: nil)
        }
    }
}

