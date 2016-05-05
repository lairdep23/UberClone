//
//  RequestViewVC.swift
//  UberClone
//
//  Created by Evan on 5/4/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import MapKit
import Parse

class RequestViewVC: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    
    var requestLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0)
    var requestUsername: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        print(requestLocation)
        print(requestUsername)
        
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpanMake(0.01, 0.01))
        
        self.map.setRegion(region, animated: true)
        
        let objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = requestLocation
        objectAnnotation.title = requestUsername
        self.map.addAnnotation(objectAnnotation)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func pickUpRider(sender: AnyObject) {
        
        let query = PFQuery(className: "riderRequest")
        query.whereKey("username", equalTo: requestUsername)
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            
            if error == nil {
                
                //print("Successfully retrieved \(objects!.count)")
                
                if let objects = objects as [PFObject]! {
                    
                    for object in objects {
                        
                        object["driverResponded"] = PFUser.currentUser()?.username!
                        
                            object.saveInBackground()
                        
                            let requestCLLocation = CLLocation(latitude: self.requestLocation.latitude, longitude: self.requestLocation.longitude)
                        
                            CLGeocoder().reverseGeocodeLocation(requestCLLocation, completionHandler: { (placemarks, error) in
                                
                                if error != nil {
                                    
                                    print("Reverse Geocoder failed" + (error?.localizedDescription)!)
                                    
                                } else {
                                    
                                    if placemarks?.count > 0 {
                                        let pm = placemarks![0] as CLPlacemark
                                        
                                        let mkPm = MKPlacemark(placemark: pm)
                                        
                                        let mapItem = MKMapItem(placemark: mkPm)
                                        
                                        mapItem.name = self.requestUsername
                                        
                                        let launchOptions = [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving]
                                        
                                        mapItem.openInMapsWithLaunchOptions(launchOptions)
                                        
                                        
                                    } else {
                                        print("Problem with data recieved from geocoder")
                                    }
                                }
                                
                                
                                
                            })
                        
                        
                        
                    }
                }
            } else {
                
                print(error)
            }
        })

    }

}
