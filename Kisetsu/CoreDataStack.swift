//
//  CoreDataStack.swift
//  AniManager
//
//  Created by Tobias Helmrich on 27.12.16.
//  Copyright © 2016 Tobias Helmrich. All rights reserved.
//

import Foundation

import Foundation
import CoreData

class CoreDataStack {
    private let modelName: String
    init(modelName: String) {
        self.modelName = modelName
    }
    
    private lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
        container.loadPersistentStores {
            (storeDescription, error) in
            if let error = error as NSError? {
                print("Error when trying to load persistent stores: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    func saveContext () {
        guard managedContext.hasChanges else { return }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Error when trying to save the managed context: \(error), \(error.userInfo)")
        }
    }
}
