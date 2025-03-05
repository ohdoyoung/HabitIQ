import UserNotifications
import CoreData

class HabitNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "COMPLETE_HABIT_ACTION" {
            let habitID = response.notification.request.identifier
            HabitDataManager.shared.markHabitAsCompleted(habitID: habitID)

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("HabitUpdated"), object: nil)
            }
        }
        completionHandler()
    }
}
