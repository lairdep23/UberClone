//
//  RiderVC.swift
//  UberClone
//
//  Created by Evan on 5/3/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

class RiderVC: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var callUberButton: UIButton!
    
    @IBOutlet weak var map: MKMapView!
    
    var riderRequestActive = false
    
    var locationManager: CLLocationManager!
    
    var lat: CLLocationDegrees = 0.0
    var long: CLLocationDegrees = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        
        self.lat = location.latitude
        self.long = location.longitude
        
        print("locations = \(location.latitude) \(location.longitude)")
        
        let center = CLLocationCoordinate2D(latitude: location.latitude , longitude: location.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpanMake(0.01, 0.01))
        
        self.map.setRegion(region, animated: true)
        
        self.map.removeAnnotations(map.annotations)
        
        let pinLocation : CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = pinLocation
        self.map.addAnnotation(objectAnnotation)
        
    }


    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutRider" {
            
            PFUser.logOut()
        }
    }
    
    @IBAction func callUber(sender: AnyObject) {
        
        if riderRequestActive == false {
        
        let riderRequest = PFObject(className: "riderRequest")
        riderRequest["username"] = PFUser.currentUser()?.username
        riderRequest["location"] = PFGeoPoint(latitude: lat , longitude: long)
        
        riderRequest.saveInBackgroundWithBlock { (success, error) in
            
            if error == nil {
                
                self.callUberButton.setTitle("Cancel Uber", forState: UIControlState.Normal)
                
                
                
            } else {
                
                let alert = UIAlertController(title:"Could not call Uber" , message: "We are sorry. Please try again" , preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            }
            }
            
            riderRequestActive = true
        
        } else {
            
            self.callUberButton.setTitle("Call An Uber", forState: UIControlState.Normal)
            
            riderRequestActive = false
            
            var query = PFQuery(className: "riderRequest")
            query.whereKey("username", equalTo: (PFUser.currentUser()?.username)!)
            query.findObjectsInBackgroundWithBlock({ (objects, error) in
                
                if error == nil {
                    
                    print("Successfully retrieved \(objects!.count)")
                    
                    if let objects = objects as [PFObject]! {
                        
                        for object in objects {
                            
                            object.deleteInBackground()
                        }
                    }
                } else {
                    
                    print(error)
                }
            })

        }
    }
    
    

}
