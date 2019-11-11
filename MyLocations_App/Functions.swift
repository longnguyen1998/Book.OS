//
//  Functions.swift
//  MyLocations_App
//
//  Created by Nguyen Dinh Thanh Long on 11/11/19.
//  Copyright © 2019 Nguyen Dinh Thanh Long. All rights reserved.
//

import Foundation

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory,
                                         in: .userDomainMask)
    return paths[0]
}()  //     creates a new global constant,

let CoreDataSaveFailedNotification =
    Notification.Name(rawValue: "CoreDataSaveFailedNotification")
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(
        name: CoreDataSaveFailedNotification, object: nil)
}


func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run)
}

