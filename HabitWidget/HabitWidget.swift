import WidgetKit
import SwiftUI
import CoreData
import AppIntents

// ✅ Core Data와 연동하여 위젯 타임라인을 제공하는 Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), habits: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), habits: fetchCoreData())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let currentDate = Date()
        let entry = SimpleEntry(date: currentDate, habits: fetchCoreData())
        let entries = [SimpleEntry(date: currentDate, habits: fetchCoreData())]
//        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: entries, policy: .atEnd) // ❌ 기존 `.after(nextUpdate)` 제거
        completion(timeline)
    }
    
    private func fetchCoreData() -> [(name: String, completion: Int16, time: String)] {
        let context = PersistenceController.shared.viewContext
        let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        request.fetchLimit = 3
        
        do {
            let result = try context.fetch(request)
            return result.map { habit in
                let timeString = habit.time != nil ? formatDate(habit.time!) : "--:--"
                return (habit.habitName, habit.completion, timeString)
            }
        } catch {
            return []
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// ✅ 위젯에 표시할 데이터 모델
struct SimpleEntry: TimelineEntry {
    let date: Date
    let habits: [(name: String, completion: Int16, time: String)]
}

// ✅ 위젯 UI 구현
//struct HabitWidgetEntryView: View {
//    var entry: Provider.Entry
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            Text("📝 습관 위젯")
//                .font(.headline)
//                .padding(.bottom, 5)
//            
//            let habitsArray = Array(entry.habits.prefix(3))
//            let enumeratedHabits = Array(habitsArray.enumerated()) // ✅ 미리 변환
//
//            ForEach(enumeratedHabits, id: \.offset) { index, habit in
//                HStack {
//                    VStack(alignment: .leading) {
//                        Text(habit.name)
//                            .font(.subheadline)
//                            .bold()
//                        Text("⏰ \(habit.time)")
//                            .font(.caption)
//                            .foregroundColor(.gray)
//                    }
//                    Spacer()
//
//                    let iconName = habit.completion == 1 ? "checkmark.circle.fill" : "circle"
//                    let iconColor: Color = habit.completion == 1 ? .green : .gray
//
//                    Toggle(isOn: false,intent: ToggleHabitCompletionIntent(
//                        habitName: IntentParameter(title : LocalizedStringResource(stringLiteral: habit.name))
////                        habitTime: IntentParameter(title: LocalizedStringResource(stringLiteral: habit.time))
//                    )) {
//                        Image(systemName: iconName)
//                            .foregroundColor(iconColor)
//                    }
//                    .buttonStyle(.plain)
//                }
//                .padding(.vertical, 3)
//            }
//            Spacer()
//        }
//        .padding()
//    }
//}

struct HabitWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("📝 습관 위젯")
                .font(.headline)
                .padding(.bottom, 5)
            
            let habitsArray = entry.habits // ✅ 최신 데이터를 바로 사용
            
            ForEach(habitsArray, id: \.name) { habit in
                HStack {
                    VStack(alignment: .leading) {
                        Text(habit.name)
                            .font(.subheadline)
                            .bold()
                        Text("⏰ \(habit.time)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    
                    let iconName = habit.completion == 1 ? "checkmark.circle.fill" : "circle"
                    let iconColor: Color = habit.completion == 1 ? .green : .gray
                    
                    Toggle(isOn: false,intent: ToggleHabitCompletionIntent(
//                        habitName: IntentParameter(title: LocalizedStringResource(stringLiteral: habit.name))
                        habitName: habit.name
                        
                        //                        habitTime: IntentParameter(title: LocalizedStringResource(stringLiteral: habit.time))
                    )) {
                        Image(systemName: iconName)
                            .foregroundColor(iconColor)
                    }
                    .buttonStyle(.plain)
//                    .onAppear {
//                        print("🟢 Intent로 보낼 habit.name: [\(habit.name)]") // ✅ habit.name이 nil인지 확인
//                    }
                }
                .padding(.vertical, 3)
            }
        }
        .padding()
    }
}

// ✅ 위젯 구성
struct HabitWidget: Widget {
    let kind: String = "HabitWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            HabitWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

// ✅ AppIntent 기반의 습관 완료 토글
@available(iOS 17.0, *)
struct ToggleHabitCompletionIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Habit Completion"
    
//    @Parameter(title: "habitName")
//    var habitName: String
    
//    @Parameter(title: "Habit Name" , default: "")
        
//    @Parameter(title: "Habit Name" , default: "")
       var habitName: String?

       func perform() async throws -> some IntentResult {
           print("🚀 Intent 실행됨!")
           print("📌 Intent에서 받은 habitName: [\(habitName)]")

           let context = PersistenceController.shared.container.newBackgroundContext() // ✅ 백그라운드 컨텍스트 사용
                   await context.perform {
                       let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
                       request.predicate = NSPredicate(format: "habitName == %@", habitName ?? "" )
           
                       do {
                           let results = try context.fetch(request)
                           if let habit = results.first {
                               habit.completion = (habit.completion == 0) ? 1 : 0
                               try context.save()
           
                               print("✅ \(habitName) 완료 상태 변경됨: \(habit.completion)")
           
                               DispatchQueue.main.async {
                                   WidgetCenter.shared.reloadAllTimelines() // ✅ 위젯 강제 새로고침
                               }
                           } else {
                               print("❌ 해당 습관을 찾을 수 없습니다.")
                           }
                       } catch {
                           print("⚠️ Core Data 업데이트 중 오류 발생: \(error.localizedDescription)")
                       }
                   }
           
                   return .result()
       }
    
//    func perform() async throws -> some IntentResult {
//        print("🚀 Intent 실행됨: \(habitName)")
//        
//        PersistenceController.ensureCoreDataIsLoaded()
//        
//        let context = PersistenceController.shared.container.newBackgroundContext() // ✅ 백그라운드 컨텍스트 사용
//        await context.perform {
//            let request: NSFetchRequest<HabitEntity> = HabitEntity.fetchRequest()
//            request.predicate = NSPredicate(format: "habitName == %@", habitName)
//            
//            do {
//                let results = try context.fetch(request)
//                if let habit = results.first {
//                    habit.completion = (habit.completion == 0) ? 1 : 0
//                    try context.save()
//                    
//                    print("✅ \(habitName) 완료 상태 변경됨: \(habit.completion)")
//                    
//                    DispatchQueue.main.async {
//                        WidgetCenter.shared.reloadAllTimelines() // ✅ 위젯 강제 새로고침
//                    }
//                } else {
//                    print("❌ 해당 습관을 찾을 수 없습니다.")
//                }
//            } catch {
//                print("⚠️ Core Data 업데이트 중 오류 발생: \(error.localizedDescription)")
//            }
//        }
//        
//        return .result()
//    }
 
}
@available(iOS 17.0, *)
struct HabitAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ToggleHabitCompletionIntent(),
            phrases: ["Toggle habit completion"]
        )
    }
}

//// ✅ 사용자 설정(버튼 동작 로직 추가)
//extension ConfigurationAppIntent {
//    static func toggleCompletionIntent(habitName: String, habitTime: String) -> ToggleHabitCompletionIntent {
//        var intent = ToggleHabitCompletionIntent()
//        intent.habitName = habitName
//        intent.habitTime = habitTime
//        return intent
//    }
//}
