//
//  BigChartView.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import SwiftUI
import Charts

struct BigChartView: View {
    struct ChartData: Identifiable {
        var id = UUID()
        var date: Date
        var count: Int
    }
    
    var data: [ChartData] = [
        ChartData(date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, count: 15),
        ChartData(date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!, count: 8),
        ChartData(date: Date(), count: 13),
        ChartData(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, count: 12),
        ChartData(date: Calendar.current.date(byAdding: .day, value: 2, to: Date())!, count: 5)
    ]
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                LineMark(x: .value("Date", item.date), y: .value("Count", item.count))
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(.red)
                PointMark(x: .value("Date", item.date), y: .value("Count", item.count))
                    .symbol(Circle())
                    .symbolSize(100)
                    .foregroundStyle(.red)
            }
        }
    }
}

#Preview {
    BigChartView()
}
