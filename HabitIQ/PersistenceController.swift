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
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("❌ Core Data 로드 실패: \(error)")
            }
        }
    }
}
