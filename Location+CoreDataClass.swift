//
//  Location+CoreDataClass.swift
//  MyLocations_App
//
//  Created by Nguyen Dinh Thanh Long on 11/11/19.
//  Copyright © 2019 Nguyen Dinh Thanh Long. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Location)
public class Location: NSManagedObject , MKAnnotation  {
    
    var hasPhoto: Bool {
        return photoID != nil
    }
    
    var photoURL: URL {
        assert(photoID != nil, "No photo ID set")
        let filename = "Photo-\(photoID!.intValue).jpg"
        return applicationDocumentsDirectory.appendingPathComponent(
            filename)
    }
    
    var photoImage: UIImage? {
        return UIImage(contentsOfFile: photoURL.path)
    }
    
    
    public var coordinate: CLLocationCoordinate2D {
     return CLLocationCoordinate2DMake(latitude, longitude)
    }
    public var title: String? {
        if locationDescription!.isEmpty {
     return "(No Description)"
     } else {
     return locationDescription
     }
    }
    public var subtitle: String? {
     return category
    }
    
    
}

extension Location{
    class func nextPhotoID() -> Int {
        let userDefaults = UserDefaults.standard
        let currentID = userDefaults.integer(forKey: "PhotoID") + 1
        userDefaults.set(currentID, forKey: "PhotoID")
        userDefaults.synchronize()
        return currentID
    }
    
    func removePhotoFile() {
        if hasPhoto {
            do {
                try FileManager.default.removeItem(at: photoURL)
            } catch {
                print("Error removing file: \(error)")
            }
        }
    }
}
