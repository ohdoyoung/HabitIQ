//import SwiftUI
//import CoreML
//import Charts
//
//struct StatsView: View {
//    @ObservedObject var viewModel = HabitViewModel(context: PersistenceController.shared.container.viewContext)
//
//    var body: some View {
//        VStack {
//            Text("습관 통계")
//                .font(.title)
//                .bold()
//            Chart(viewModel.completionStats(), id: \ .0) { status in
//                BarMark(
//                    x: .value("상태", status.0),
//                    y: .value("개수", status.1)
//                )
//            }
//            .frame(height: 200)
//        }
//        .padding()
//    }
//}
