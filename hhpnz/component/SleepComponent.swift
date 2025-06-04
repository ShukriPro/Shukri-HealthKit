//
//  SleepComponent.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//
import SwiftUI
import HealthKit

struct SleepComponent: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            SleepSummary()
            Spacer()
            WeeklySleepBar()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct SleepSummary: View {
    @State private var lastNightSleep: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Sleep")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Last 7 days")
                .font(.caption2)
                .foregroundColor(.gray)

            HStack(spacing: 2) {
                Text(String(format: "%.1f", lastNightSleep))
                    .foregroundColor(.purple)
                    .font(.footnote)
                    .fontWeight(.semibold)

                Text("hrs")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            Text("Last night")
                .font(.caption2)
                .foregroundColor(.purple)
        }
        .onAppear {
            fetchSleepGroupedByDay { data in
                let latest = data.sorted { $0.key > $1.key }.first?.value ?? 0
                DispatchQueue.main.async {
                    lastNightSleep = latest
                }
            }
        }
    }
}

struct WeeklySleepBar: View {
    @State private var sleepHours: [Double] = []
    private let dayLabels = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<sleepHours.count, id: \.self) { i in
                VStack(spacing: 4) {
                    if sleepHours[i] >= 6.0 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .offset(y: 5)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.purple)
                            .frame(width: 20, height: barHeight(for: sleepHours[i]))

                        Text("\(Int(sleepHours[i]))h")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.6)
                            .lineLimit(1)
                            .frame(width: 18)
                    }

                    Text(dayLabels[i % 7])
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(width: 20)
                }
            }
        }
        .onAppear {
            fetchSleepGroupedByDay { data in
                let sorted = data.sorted { $0.key < $1.key }
                let last7 = sorted.suffix(7).map { $0.value }

                DispatchQueue.main.async {
                    self.sleepHours = last7
                }
            }
        }
    }

    private func barHeight(for hours: Double) -> CGFloat {
        let maxHeight: CGFloat = 70
        let minHeight: CGFloat = 20
        let maxHours = sleepHours.max() ?? 1
        let scale = CGFloat(hours / maxHours)
        return max(minHeight, maxHeight * scale)
    }
}

// MARK: - Inline HealthKit sleep function
private func fetchSleepLast7Days(completion: @escaping ([Double]) -> Void) {
    guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
        completion([])
        return
    }

    let healthStore = HKHealthStore()
    let calendar = Calendar.current
    let now = Date()
    let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!
    let predicate = HKQuery.predicateForSamples(withStart: startDate, end: now, options: .strictStartDate)

    var sleepData = Array(repeating: 0.0, count: 7)

    let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
        guard let samples = samples as? [HKCategorySample] else {
            completion(sleepData)
            return
        }

        for sample in samples {
            if let value = HKCategoryValueSleepAnalysis(rawValue: sample.value),
               HKCategoryValueSleepAnalysis.allAsleepValues.contains(value) {

                let dayIndex = calendar.dateComponents([.day], from: startDate, to: sample.startDate).day ?? 0
                if dayIndex >= 0 && dayIndex < 7 {
                    let duration = sample.endDate.timeIntervalSince(sample.startDate) / 3600
                    sleepData[dayIndex] += duration
                }
            }
        }

        completion(sleepData)
    }

    healthStore.execute(query)
}

private func fetchSleepGroupedByDay(completion: @escaping ([Date: Double]) -> Void) {
    guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
        completion([:])
        return
    }

    let healthStore = HKHealthStore()
    let predicate = HKQuery.predicateForSamples(withStart: .distantPast, end: Date(), options: .strictStartDate)
    let calendar = Calendar.current

    var sleepByDay: [Date: Double] = [:]

    let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
        guard let samples = samples as? [HKCategorySample] else {
            completion([:])
            return
        }

        for sample in samples {
            if let value = HKCategoryValueSleepAnalysis(rawValue: sample.value),
               HKCategoryValueSleepAnalysis.allAsleepValues.contains(value) {

                let date = calendar.startOfDay(for: sample.startDate)
                let duration = sample.endDate.timeIntervalSince(sample.startDate) / 3600
                sleepByDay[date, default: 0.0] += duration
            }
        }

        completion(sleepByDay)
    }

    healthStore.execute(query)
}
