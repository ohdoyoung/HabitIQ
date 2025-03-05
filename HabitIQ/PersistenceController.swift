//
//  PersistenceController.swift
//  HabitIQ
//
//  Created by 오도영 on 2/20/25.
//

import Foundation
import CoreData

// ✅ Core Data 설정 (습관 데이터 저장)
class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "HabitTrackerModel")
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.habitiq.shared") {
                  let storeURL = appGroupURL.appendingPathComponent("HabitIQ.sqlite")
                  let storeDescription = NSPersistentStoreDescription(url: storeURL)
                  container.persistentStoreDescriptions = [storeDescription]
              }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("❌ Core Data 로드 실패: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    var viewContext: NSManagedObjectContext {
           return container.viewContext
       }
}
