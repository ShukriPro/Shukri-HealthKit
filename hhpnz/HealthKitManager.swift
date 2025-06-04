//
//  HealthKitManager.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//

import Foundation
import HealthKit

class HealthKitManager {
    static let shared = HealthKitManager()
    let healthStore = HKHealthStore()

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let readTypes: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.categoryType(forIdentifier: .appleStandHour)!
        ]

        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
            completion(success)
        }
    }

    // Example: fetch today's steps
    func fetchTodaySteps(completion: @escaping (Double) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }

        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: now, options: .strictStartDate)

        let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, _ in
            let steps = result?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            completion(steps)
        }

        healthStore.execute(query)
    }
    func fetchStepsLast7Days(completion: @escaping ([Int]) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            completion([])
            return
        }

        let now = Date()
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now))!

        var dailySteps: [Int] = Array(repeating: 0, count: 7)
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
            if let stats = results {
                stats.enumerateStatistics(from: startDate, to: now) { stat, _ in
                    let index = calendar.dateComponents([.day], from: startDate, to: stat.startDate).day ?? 0
                    if index >= 0 && index < 7 {
                        let value = stat.sumQuantity()?.doubleValue(for: .count()) ?? 0
                        dailySteps[index] = Int(value)
                    }
                }
            }
            completion(dailySteps)
        }

        healthStore.execute(query)
    }

}
