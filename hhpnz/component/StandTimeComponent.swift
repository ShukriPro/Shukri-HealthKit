//
//  StandTimeComponent.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//
import SwiftUI
import HealthKit

struct StandTimeComponent: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            StandTimeSummary()
            Spacer()
            StandTimeBar()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct StandTimeSummary: View {
    @State private var todayHours: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Stand Time")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Last 7 days")
                .font(.caption2)
                .foregroundColor(.gray)

            HStack(spacing: 2) {
                Text("\(todayHours)")
                    .foregroundColor(.indigo)
                    .font(.footnote)
                    .fontWeight(.semibold)

                Text("hrs")
                    .font(.caption2)
                    .foregroundColor(.indigo)
            }

            Text("Today")
                .font(.caption2)
                .foregroundColor(.indigo)
        }
        .onAppear {
            fetchStandTimeLast7Days { list in
                DispatchQueue.main.async {
                    todayHours = list.last ?? 0
                }
            }
        }
    }
}

struct StandTimeBar: View {
    @State private var hours: [Int] = Array(repeating: 0, count: 7)
    let days = ["T", "F", "S", "S", "M", "T", "W"]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<hours.count, id: \.self) { i in
                VStack(spacing: 4) {
                    if hours[i] >= 6 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .offset(y: 5)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.indigo)
                            .frame(width: 20, height: barHeight(for: hours[i]))

                        Text("\(hours[i])")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .frame(width: 18)
                    }

                    Text(days[i])
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                }
            }
        }
        .onAppear {
            fetchStandTimeLast7Days { list in
                DispatchQueue.main.async {
                    self.hours = list
                }
            }
        }
    }

    private func barHeight(for value: Int) -> CGFloat {
        let maxHeight: CGFloat = 70
        let minHeight: CGFloat = 20
        let maxValue = hours.max() ?? 1
        let scale = CGFloat(value) / CGFloat(maxValue)
        return max(minHeight, maxHeight * scale)
    }
}

// MARK: - Inline HealthKit function
private func fetchStandTimeLast7Days(completion: @escaping ([Int]) -> Void) {
    guard let type = HKObjectType.categoryType(forIdentifier: .appleStandHour) else {
        completion([])
        return
    }

    let healthStore = HKHealthStore()
    let calendar = Calendar.current
    let now = Date()
    let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)
    let interval = DateComponents(day: 1)

    let query = HKStatisticsCollectionQuery(
        quantityType: HKQuantityType(.appleStandTime),
        quantitySamplePredicate: predicate,
        options: .cumulativeSum,
        anchorDate: calendar.startOfDay(for: now),
        intervalComponents: interval
    )

    query.initialResultsHandler = { _, results, _ in
        var values = Array(repeating: 0, count: 7)
        if let stats = results {
            stats.enumerateStatistics(from: startDate, to: now) { stat, _ in
                let index = calendar.dateComponents([.day], from: startDate, to: stat.startDate).day ?? 0
                if index >= 0 && index < 7 {
                    let val = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                    values[index] = Int(val)
                }
            }
        }
        completion(values)
    }

    healthStore.execute(query)
}
