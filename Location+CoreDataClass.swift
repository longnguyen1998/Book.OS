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
