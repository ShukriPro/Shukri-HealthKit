import SwiftUI
import HealthKit

struct HeartComponent: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            HeartSummary()
            Spacer()
            HeartRateLineChart()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct HeartSummary: View {
    @State private var bpm: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Heart Rate")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Last 7 days")
                .font(.caption2)
                .foregroundColor(.gray)

            HStack(spacing: 2) {
                Text("\(bpm)")
                    .foregroundColor(.pink)
                    .font(.footnote)
                    .fontWeight(.semibold)

                Text("BPM")
                    .font(.caption2)
                    .foregroundColor(.pink)
            }

            Text("Resting")
                .font(.caption2)
                .foregroundColor(.pink)
        }
        .onAppear {
            fetchHeartRatesLast7Days { rates in
                DispatchQueue.main.async {
                    bpm = Int(rates.last ?? 0)
                }
            }
        }
    }
}

struct HeartRateLineChart: View {
    @State private var heartRates: [Double] = Array(repeating: 0, count: 7)
    let days = ["T", "F", "S", "S", "M", "T", "W"]

    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Path { path in
                        let width = geo.size.width
                        let height = geo.size.height - 16
                        let maxRate = heartRates.max() ?? 1
                        let minRate = heartRates.min() ?? 0
                        let stepX = width / CGFloat(heartRates.count - 1)
                        let scaleY = height / CGFloat(maxRate - minRate)

                        for i in heartRates.indices {
                            let x = stepX * CGFloat(i)
                            let y = height - CGFloat(heartRates[i] - minRate) * scaleY
                            i == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                    .stroke(Color.pink, lineWidth: 1.5)

                    ForEach(heartRates.indices, id: \.self) { i in
                        let width = geo.size.width
                        let height = geo.size.height - 16
                        let maxRate = heartRates.max() ?? 1
                        let minRate = heartRates.min() ?? 0
                        let stepX = width / CGFloat(heartRates.count - 1)
                        let scaleY = height / CGFloat(maxRate - minRate)
                        let x = stepX * CGFloat(i)
                        let y = height - CGFloat(heartRates[i] - minRate) * scaleY

                        Circle()
                            .fill(Color.pink)
                            .frame(width: 6, height: 6)
                            .position(x: x, y: y)
                    }
                }
                .frame(height: 60)

                HStack {
                    ForEach(days, id: \.self) {
                        Text($0)
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(height: 80)
        .onAppear {
            fetchHeartRatesLast7Days { rates in
                DispatchQueue.main.async {
                    self.heartRates = rates
                }
            }
        }
    }
}

// MARK: - HealthKit Fetch Function
private func fetchHeartRatesLast7Days(completion: @escaping ([Double]) -> Void) {
    guard let type = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
        completion([])
        return
    }

    let healthStore = HKHealthStore()
    let now = Date()
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
    let interval = DateComponents(day: 1)

    let query = HKStatisticsCollectionQuery(
        quantityType: type,
        quantitySamplePredicate: predicate,
        options: .discreteAverage,
        anchorDate: calendar.startOfDay(for: now),
        intervalComponents: interval
    )

    query.initialResultsHandler = { _, results, _ in
        var dailyRates = Array(repeating: 0.0, count: 7)
        if let stats = results {
            stats.enumerateStatistics(from: startDate, to: now) { stat, _ in
                let index = calendar.dateComponents([.day], from: startDate, to: stat.startDate).day ?? 0
                if index >= 0 && index < 7 {
                    let value = stat.averageQuantity()?.doubleValue(for: .init(from: "count/min")) ?? 0
                    dailyRates[index] = value
                }
            }
        }
        completion(dailyRates)
    }

    healthStore.execute(query)
}
