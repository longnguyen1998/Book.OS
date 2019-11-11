//
//  FirstViewController.swift
//  MyLocations_App
//
//  Created by Nguyen Dinh Thanh Long on 11/6/19.
//  Copyright © 2019 Nguyen Dinh Thanh Long. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData



class CurrentLocationViewController: UIViewController {
    
    private let locationManager = CLLocationManager()
    private var location : CLLocation?
    private var lastLocationError:Error?
    private var updatingLocation = false
    
    private let geocoder = CLGeocoder()
    private var placemark: CLPlacemark?
    private var performingReverseGeocoding = false
    private var lastGeocodingError : Error?
    private var timer : Timer?
    var managedObjectContext: NSManagedObjectContext!
    
    
    
    @IBOutlet weak private var messageLabel: UILabel!
    @IBOutlet weak private var latitudeLabel: UILabel!
    @IBOutlet weak private var longitudeLabel: UILabel!
    @IBOutlet weak private var addressLabel: UILabel!
    @IBOutlet weak private var tagButton: UIButton!
    @IBOutlet weak private var getButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        updateLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        updateLabels()
        navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let controller = segue.destination as! LocationDetailsViewController
            controller.coordinate = location!.coordinate
            controller.placemark = placemark
            controller.managedObjectContext = managedObjectContext
        }
    }
    
    // MARK:- Actions
    @IBAction func getLocation() {
        // do nothing yet
        
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        //        startLocationManager()
        if updatingLocation{
            stopLocationManager()
        }else{
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }
        updateLabels()
    }
    
    
}


extension CurrentLocationViewController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")
        if (error as NSError ).code == CLError.locationUnknown.rawValue{
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        print("didUpdateLocations \(String(describing: newLocation))")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        // New section #1
        var distance = CLLocationDistance(
            Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }
        // End of new section #1
        
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy{
            lastLocationError = nil
            location = newLocation
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                print("*** We' re done!")
                stopLocationManager()
            }
            // New section #2
            if distance > 0 {
                performingReverseGeocoding = false
            }
            // End of new section #2
            
            updateLabels()
            // The new code begins here:
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation,
                                                completionHandler: {
                                                    placemarks, error in
                                                    self.lastGeocodingError = error
                                                    if error == nil, let p = placemarks, !p.isEmpty {
//                                                        self.placemark = p.last!
                                                    } else {
                                                        self.placemark = nil
                                                    }
                                                    self.performingReverseGeocoding = false
                                                    self.updateLabels()
                })
            }
            // End of the new code
            // New section #3
        } else if distance < 1 {
            let timeInterval = newLocation.timestamp.timeIntervalSince(
                location!.timestamp)
            if timeInterval > 10 {
                print("*** Force done!")
                stopLocationManager()
                updateLabels()
            }
            // End of new sectiton #3
            
        }
    }
}


extension CurrentLocationViewController {
    // MARK:- Helper Methods
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(
            title: "Location Services Disabled",
            message: "Please enable location services for this app in Settings.",
            preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    func updateLabels(){
        if let location = location {
            latitudeLabel.text = "Latitude --> " + String(format: "%.8f",
                                                          location.coordinate.latitude)
            longitudeLabel.text = "Longitude --> " + String(format: "%.8f",
                                                            location.coordinate.longitude)
            addressLabel.text = "Address in here !!!"
            tagButton.isHidden = false
            messageLabel.text = ""
            // Add this block
            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            } else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            } else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            } else {
                addressLabel.text = "No Address Found"
            }
            // End new code
            
        } else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagButton.isHidden = true
            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain &&
                    error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                } else {
                    statusMessage = "Error Getting Location"
                }
            } else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            } else if updatingLocation {
                statusMessage = "Searching..."
            } else {
                statusMessage = "Tap 'Get My Location' to Start"
            }
            messageLabel.text = statusMessage
        }
        configureGetButton()
    }
    
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
            if let timer = timer{
                timer.invalidate()
            }
        }
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy =
            kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
            timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)
        }
    }
    
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }
    
    func string (from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }
        if let s = placemark.thoroughfare {
            line1 += s
        }
        var line2 = ""
        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }
        return line1 + "\n" + line2
    }
    
    @objc func didTimeOut(){
        print("*** Time out")
        if location == nil {
            stopLocationManager()
            lastLocationError = NSError(
                domain: "MyLocationsErrorDomain",
                code: 1, userInfo: nil)
            updateLabels()
        }
    }
    
}




// NOTE :
// horizontalAccuracy : bán ki'nh không chính xác
