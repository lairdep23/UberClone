//
//  DriverVC.swift
//  UberClone
//
//  Created by Evan on 5/4/16.
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import Parse
import MapKit

//44:19 in the video

class DriverVC: UITableViewController, CLLocationManagerDelegate {
    
    var usernames = [String]()
    var locations = [CLLocationCoordinate2D]()
    var distances = [CLLocationDistance]()
    
    var locationManager: CLLocationManager!
    
    var lat: CLLocationDegrees = 0.0
    var long: CLLocationDegrees = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        let distanceDouble = Double(distances[indexPath.row])
        
        let roundedDistance = Double(round(distanceDouble * 10)/10)

        cell.textLabel?.text = "\(usernames[indexPath.row]) - \(roundedDistance) miles away"

        return cell
    }
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "logoutDriver" {
            
            navigationController?.setNavigationBarHidden(true, animated: false)
            
            PFUser.logOut()
        } else if segue.identifier == "showViewRequests" {
            
            if let destination = segue.destinationViewController as? RequestViewVC {
                
                destination.requestLocation = locations[(tableView.indexPathForSelectedRow?.row)!]
                
                destination.requestUsername = usernames[tableView.indexPathForSelectedRow!.row]
            }
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location: CLLocationCoordinate2D = manager.location!.coordinate
        
        self.lat = location.latitude
        self.long = location.longitude
        
        print("locations = \(location.latitude) \(location.longitude)")
        
        var query = PFQuery(className: "driverLocation")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            
            if error == nil {
                
                //print("Successfully retrieved \(objects!.count)")
                
                if let objects = objects as [PFObject]! {
                    
                    if objects.count > 0 {
                    
                        for object in objects {
                        
                            var query = PFQuery(className: "driverLocation")
                            query.getObjectInBackgroundWithId(object.objectId!, block: { (object: PFObject?, error: NSError?) in
                            
                                if error != nil {
                                
                                    print(error)
                                
                                } else if let object = object {
                                
                                    object["driverLocation"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                                
                                    object.saveInBackground()
                                }
                            })
                        
                        }
                    } else {
                        
                        let driverLocation = PFObject(className: "driverLocation")
                        driverLocation["username"] = PFUser.currentUser()?.username
                        driverLocation["driverLocation"] = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
                        
                        driverLocation.saveInBackground()
                    }
                        
                }
                
            } else {
                
                print(error)
            }
        })

        
        
        //Old Query
        
        query = PFQuery(className: "riderRequest")
        query.whereKey("location", nearGeoPoint: PFGeoPoint(latitude: location.latitude, longitude: location.longitude) , withinMiles: 100.0)
        query.limit = 15
        query.findObjectsInBackgroundWithBlock({ (objects, error) in
            
            if error == nil {
                
                //print("Successfully retrieved \(objects!.count)")
                
                if let objects = objects as [PFObject]! {
                    
                    self.usernames.removeAll()
                    self.locations.removeAll()
                    
                    for object in objects {
                        
                        if object["driverResponded"] == nil || object["driverResponded"] as! String == "" {
                        
                            if let username = object["username"] as? String {
                            
                                self.usernames.append(username)
                            }
                        
                            if let returnedlocation = object["location"] as? PFGeoPoint {
                            
                                let requestLocation = CLLocationCoordinate2DMake(returnedlocation.latitude, returnedlocation.longitude)
                            
                                self.locations.append(requestLocation)
                            
                                let requestCLLocation = CLLocation(latitude: requestLocation.latitude, longitude: requestLocation.longitude)
                            
                                let driverCLLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                            
                                let distance = driverCLLocation.distanceFromLocation(requestCLLocation)
                            
                                self.distances.append(distance * 0.000621371)
                            
                            }
                        }
                        
                    }
                    
                    self.tableView.reloadData()
                    
                   // print(self.locations)
                    //print(self.usernames)
                }
                
            } else {
                
                print(error)
            }
        })
        
        
    }


}
