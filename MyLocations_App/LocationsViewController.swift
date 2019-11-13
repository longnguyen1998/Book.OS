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
    var managedObjectContext = appDelegate.persistentContainer.viewContext
    var locations = [Location]()

    
    lazy var fetchedResultsController:
        NSFetchedResultsController<Location> = {
            let fetchRequest = NSFetchRequest<Location>()
            let entity = Location.entity()
            fetchRequest.entity = entity
            
            let sortDescriptor = NSSortDescriptor(key: "date",
                                                  ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            fetchRequest.fetchBatchSize = 20
            
            let sort1 = NSSortDescriptor(key: "category", ascending: true)
            let sort2 = NSSortDescriptor(key: "date", ascending: true)
            fetchRequest.sortDescriptors = [sort1, sort2]
            
            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: self.managedObjectContext,
                sectionNameKeyPath: "category", cacheName: "Locations")
            
            fetchedResultsController.delegate = self as! NSFetchedResultsControllerDelegate
            return fetchedResultsController
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSFetchedResultsController<Location>.deleteCache(withName: "Locations")
        performFetch()
        navigationItem.rightBarButtonItem = editButtonItem // make color for  edit
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1
        let fetchRequest = NSFetchRequest<Location>()
        // 2
        let entity = Location.entity()
        fetchRequest.entity = entity
        // 3
        let sortDescriptor = NSSortDescriptor(key: "date",
                                              ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            // 4
            locations = try (managedObjectContext.fetch(fetchRequest))
            tableView.reloadData()
        } catch {
            fatalCoreDataError(error)
        }
        
    }
    
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: "LocationCell",
                for: indexPath) as! LocationCell
            let location = fetchedResultsController.object(at: indexPath)
            cell.configure(for: location)
            return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete { // delete row
            let location = fetchedResultsController.object(at:
                indexPath)
            location.removePhotoFile() 
            managedObjectContext.delete(location)
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int { // created tag for cell   couble +
        return fetchedResultsController.sections!.count
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { //// created tag for cell  couble + 
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let controller = segue.destination
                as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            if let indexPath = tableView.indexPath(for: sender
                as! UITableViewCell) {
                let location = locations[indexPath.row]
                controller.locationToEdit = location
            }
        }
    }
    
    
    deinit {
        fetchedResultsController.delegate = nil
    }
    
}


extension LocationsViewController {
    // MARK:- Helper methods
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
}


// MARK:- NSFetchedResultsController Delegate Extension
extension LocationsViewController:
NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any, at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            
        case .delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            
        case .update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRow(at: indexPath!)
                as? LocationCell {
                let location = controller.object(at: indexPath!)
                    as! Location
                cell.configure(for: location)
            }
        case .move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(IndexSet(integer: sectionIndex),
                                     with: .fade)
        case .update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
