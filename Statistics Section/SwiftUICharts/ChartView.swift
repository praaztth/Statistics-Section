//
//  ChartView.swift
//  Statistics Section
//
//  Created by tryuruy on 18.09.2024.
//

import SwiftUI
import Charts
import UIKit

struct ChartView: View {
    struct ChartData: Identifiable {
        var id = UUID()
        var date: Date
        var count: Int
    }
    
    var color: Color
    
    init(color: Color, data: [Double: Int]) {
        self.color = color
        self.data = data.map { ChartData(date: Date(timeIntervalSince1970: $0.key), count: $0.value) }.sorted { $0.date < $1.date }
    }
    
    var data: [ChartData]
    
    var body: some View {
        Chart {
            ForEach(data) { item in
                LineMark(x: .value("Date", item.date), y: .value("Count", item.count))
                    .interpolationMethod(.cardinal)
                    .lineStyle(.init(lineWidth: 3))
                    .foregroundStyle(color)
                    .shadow(color: Color(uiColor: UIColor.secondaryLabel.withAlphaComponent(0.2)), radius: 1, y: 5)
            }
            PointMark(x: .value("Date", data.last!.date), y: .value("Count", data.last!.count))
                .symbol(Circle())
                .symbolSize(100)
                .foregroundStyle(color)
            PointMark(x: .value("Date", data.last!.date), y: .value("Count", data.last!.count))
                .symbol(Circle())
                .symbolSize(20)
                .foregroundStyle(.white)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

#Preview {
    ChartView(color: .green, data: [2034985230: 0, 54323545: 1])
}
