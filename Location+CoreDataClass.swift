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
        let filename = "Photo-\(photoID).jpg"
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
        if let currentID = userDefaults.object(forKey: "PhotoID") as? Int {
            userDefaults.set(currentID + 1, forKey: "PhotoID")
            userDefaults.synchronize()
            return currentID + 1
        } else {
            userDefaults.set(0, forKey: "PhotoID")
            userDefaults.synchronize()
            return 0
        }
        
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
