//
//  SmallChartViewController.swift
//  Statistics Section
//
//  Created by tryuruy on 22.09.2024.
//

import Foundation
import RealmSwift
import SwiftUI

struct ChartData: Identifiable {
    var id = UUID()
    var date: Date
    var count: Int
}

class SmallChartViewController {
    private var statisticsData = [ChartData]()
    private let type: StatisticsModel.EventType
    private let color: Color
    private var view: ChartView? = nil
    
    internal var chartView: UIView {
        let hostingView = UIHostingController(rootView: view)
        return hostingView.view
    }
    
    init(type: StatisticsModel.EventType, color: Color) {
        self.type = type
        self.color = color
        
        prepareStatistics()
        prepareView()
    }
    
    private func prepareStatistics() {
        var statisticsDictionary = Constants.shared.getDaysOfMonth()
        
        do {
            let realm = try Realm()
            let instances = realm.objects(StatisticsModel.self).filter("type == %@", self.type.rawValue)
            
            instances.forEach { instance in
                instance.listTimestamps.forEach { timestamp in
                    let date = Date(timeIntervalSince1970: timestamp)
                    
                    if Constants.shared.isDateInCurrentMonth(date) {
                        statisticsDictionary[timestamp]? += 1
                    }
                }
            }
        } catch {
            print(error)
        }
        
        statisticsData = statisticsDictionary.map {
            ChartData(date: Date(timeIntervalSince1970: $0.key), count: $0.value)
        }.sorted { $0.date < $1.date }
    }
    
    private func prepareView() {
        view = ChartView(color: self.color, data: self.statisticsData)
    }
}
