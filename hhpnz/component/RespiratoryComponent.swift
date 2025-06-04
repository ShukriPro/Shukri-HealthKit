//
//  RespiratoryComponent.swift
//  hhpnz
//
//  Created by Shukri on 3/06/25.
//
import SwiftUI

struct RespiratoryComponent: View {
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            RespiratorySummary()
            Spacer()
            RespiratoryBar()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
}

struct RespiratorySummary: View {
    let rate: Double = 18.4

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Respiratory Rate")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("Last 7 days")
                .font(.caption2)
                .foregroundColor(.gray)

            HStack(spacing: 2) {
                Text(String(format: "%.1f", rate))
                    .foregroundColor(.teal)
                    .font(.footnote)
                    .fontWeight(.semibold)

                Text("breaths/min")
                    .font(.caption2)
                    .foregroundColor(.teal)
            }

            Text("Resting")
                .font(.caption2)
                .foregroundColor(.teal)
        }
    }
}

struct RespiratoryBar: View {
    let rates: [Double] = [17.5, 18.2, 19.0, 20.3, 18.4, 17.9, 18.1]
    let days = ["T", "F", "S", "S", "M", "T", "W"]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(0..<rates.count, id: \.self) { i in
                VStack(spacing: 4) {
                    if rates[i] >= 17 {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .offset(y: 5)
                    }

                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.teal)
                            .frame(width: 20, height: barHeight(for: rates[i]))

                        Text(String(format: "%.0f", rates[i]))
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
    }

    private func barHeight(for value: Double) -> CGFloat {
        let maxHeight: CGFloat = 70
        let minHeight: CGFloat = 20
        let maxValue = rates.max() ?? 1
        let scale = CGFloat(value) / CGFloat(maxValue)
        return max(minHeight, maxHeight * scale)
    }
}

#Preview {
    RespiratoryComponent()
        .padding()
        .background(Color(.systemGroupedBackground))
}
