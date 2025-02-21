//import SwiftUI
//import CoreData
//
//struct MainView: View {
//    @Environment(\.managedObjectContext) private var context
//    @FetchRequest(entity: HabitEntity.entity(), sortDescriptors: []) private var habits: FetchedResults<HabitEntity>
//    @StateObject private var viewModel: HabitViewModel
//
//    init(context: NSManagedObjectContext) {
//        _viewModel = StateObject(wrappedValue: HabitViewModel(context: context))
//    }
//
//    var body: some View {
//        NavigationView {
//            VStack {
//                List {
//                    ForEach(habits, id: \.self) { habit in
//                        HStack {
//                            Text(habit.name ?? "")
//                            Spacer()
//                            Image(systemName: habit.isCompleted ? "checkmark.circle.fill" : "circle")
//                                .onTapGesture {
//                                    viewModel.toggleHabitCompletion(habit: habit)
//                                }
//                        }
//                    }
//                    .onDelete(perform: deleteHabit)
//                }
//                
//                // ✅ AI 추천 기능 추가
//                Button("AI 추천 받기") {
//                    viewModel.getRecommendation()
//                }
//                .buttonStyle(.borderedProminent)
//                .padding()
//
//                if !viewModel.recommendedHabit.isEmpty {
//                    Text("추천 습관: \(viewModel.recommendedHabit)")
//                        .font(.headline)
//                        .padding()
//                }
//
//                NavigationLink("습관 추가", destination: AddHabitView(viewModel: viewModel))
//            }
//            .navigationTitle("오늘의 습관")
//        }
//    }
//
//    private func deleteHabit(at offsets: IndexSet) {
//        offsets.map { habits[$0] }.forEach(context.delete)
//        saveContext()
//    }
//
//    private func saveContext() {
//        do {
//            try context.save()
//        } catch {
//            print("❌ 데이터 저장 실패: \(error)")
//        }
//    }
//}
