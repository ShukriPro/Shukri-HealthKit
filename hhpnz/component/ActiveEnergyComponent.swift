//
//  ActiveEnergyComponent.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//
import SwiftUI
import HealthKit

struct ActiveEnergyComponent: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ActiveEnergySummary()
            Spacer()
            ActiveEnergyBar()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct ActiveEnergySummary: View {
    @State private var todayKcal: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Active Energy")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Last 7 days")
                .font(.caption2)
                .foregroundColor(.gray)

            HStack(spacing: 2) {
                Text("\(todayKcal)")
                    .foregroundColor(.red)
                    .font(.footnote)
                    .fontWeight(.semibold)

                Text("kcal")
                    .font(.caption2)
                    .foregroundColor(.red)
            }

            Text("Today")
                .font(.caption2)
                .foregroundColor(.red)
        }
        .onAppear {
            fetchTodayActiveEnergy { kcal in
                DispatchQueue.main.async {
                    self.todayKcal = Int(kcal)
                }
            }
        }
    }
}

struct ActiveEnergyBar: View {
    @State private var values: [Int] = Array(repeating: 0, count: 7)
    let days = ["T", "F", "S", "S", "M", "T", "W"]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<values.count, id: \.self) { i in
                VStack(spacing: 4) {
                    if values[i] >= 100 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .offset(y: 5)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.red)
                            .frame(width: 20, height: barHeight(for: values[i]))

                        Text("\(values[i])")
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
            fetchActiveEnergyLast7Days { kcalList in
                DispatchQueue.main.async {
                    self.values = kcalList
                }
            }
        }
    }

    private func barHeight(for value: Int) -> CGFloat {
        let maxHeight: CGFloat = 70
        let minHeight: CGFloat = 20
        let maxValue = values.max() ?? 1
        let scale = CGFloat(value) / CGFloat(maxValue)
        return max(minHeight, maxHeight * scale)
    }
}

// MARK: - HealthKit Functions (inline)
private func fetchTodayActiveEnergy(completion: @escaping (Double) -> Void) {
    guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
        completion(0)
        return
    }

    let now = Date()
    let start = Calendar.current.startOfDay(for: now)
    let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)

    let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
        let value = result?.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
        completion(value)
    }

    HKHealthStore().execute(query)
}

private func fetchActiveEnergyLast7Days(completion: @escaping ([Int]) -> Void) {
    guard let type = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
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
        options: .cumulativeSum,
        anchorDate: calendar.startOfDay(for: now),
        intervalComponents: interval
    )

    query.initialResultsHandler = { _, results, _ in
        var dailyKcal = Array(repeating: 0, count: 7)
        if let stats = results {
            stats.enumerateStatistics(from: startDate, to: now) { stat, _ in
                let index = calendar.dateComponents([.day], from: startDate, to: stat.startDate).day ?? 0
                if index >= 0 && index < 7 {
                    let kcal = stat.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    dailyKcal[index] = Int(kcal)
                }
            }
        }
        completion(dailyKcal)
    }

    healthStore.execute(query)
}
