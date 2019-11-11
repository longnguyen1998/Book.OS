//
//  LocationsViewController.swift
//  MyLocations_App
//
//  Created by Nguyen Dinh Thanh Long on 11/11/19.
//  Copyright © 2019 Nguyen Dinh Thanh Long. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "LocationCell",
                for: indexPath)
            let descriptionLabel = cell.viewWithTag(100) as! UILabel
            descriptionLabel.text = "If you can see this"
            let addressLabel = cell.viewWithTag(101) as! UILabel
            addressLabel.text = "Then it works!"
            return cell
    }
}
