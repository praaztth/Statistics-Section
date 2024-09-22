//
//  BigChartView.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import SwiftUI
import Charts

struct BigChartView: View {
    var data: [ChartData]
    
    init(data: [ChartData]) {
        self.data = data
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
    BigChartView(data: [ChartData(date: Date(), count: 7)])
}
