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
    
    var data: [ChartData]
    
    init(data: [Double: Int]) {
        self.data = data.map { ChartData(date: Date(timeIntervalSince1970: $0.key), count: $0.value)}.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                LineMark(x: .value("Date", item.date), y: .value("Count", item.count))
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(.red)
                if item.count != 0 {
                    PointMark(x: .value("Date", item.date), y: .value("Count", item.count))
                        .symbol(Circle())
                        .symbolSize(100)
                        .foregroundStyle(.red)
                }
                
            }
        }
    }
}

#Preview {
    BigChartView(data: [234234234: 3, 2342343: 6])
}
