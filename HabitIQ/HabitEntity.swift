
import Foundation
import CoreData

@objc(HabitEntity)
public class HabitEntity: NSManagedObject {
    @NSManaged public var category: Int16
    @NSManaged public var habitName: String
    @NSManaged public var timeOfDay: Int16
    @NSManaged public var time: Date? // ✅ 시간 저장 필드 추가
    @NSManaged public var frequency: Int16
    @NSManaged public var durationWeeks: Int16
    @NSManaged public var completion: Int16
    @NSManaged public var date: Date?
    
}

extension HabitEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitEntity> {
        return NSFetchRequest<HabitEntity>(entityName: "HabitEntity")
    }
}
