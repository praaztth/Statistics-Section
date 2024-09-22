//
//  BigChartViewController.swift
//  Statistics Section
//
//  Created by tryuruy on 22.09.2024.
//

import Foundation
import RealmSwift
import SwiftUI

class VisitorsChartViewController {
    enum State {
        case byDay
        case byWeek
        case byMonth
    }
    
    private var statisticsData = [ChartData]()
    private var view: BigChartView? = nil
    private let state: State
    
    internal var chartView: UIView {
        let hostingView = UIHostingController(rootView: view)
        return hostingView.view
    }
    
    init(state: State) {
        self.state = state
        
        prepareStatistics()
        prepareView()
    }
    
    private func prepareStatistics() {
        var componentStep: Calendar.Component? = nil
        var components: Set<Calendar.Component>? = nil
        var multiplier = 1
        
        switch self.state {
        case .byDay:
            componentStep = .day
            components = [.year, .month, .day]
        case .byWeek:
            componentStep = .day
            components = [.year, .month, .day]
            multiplier = 4
        case .byMonth:
            componentStep = .month
            components = [.year, .month]
        }
        
        var statisticsDictionary = Constants.shared.getTimeInterval(components: components!, componentStep: componentStep!, multiplier: multiplier)
        
        do {
            let realm = try Realm()
            let instances = realm.objects(StatisticsModel.self).filter("type == %@", StatisticsModel.EventType.visit.rawValue)
            
            instances.forEach { instance in
                instance.listTimestamps.forEach { timestamp in
                    addValueToVisitorsChart(dictionary: &statisticsDictionary, timestamp: timestamp)
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
        view = BigChartView(data: statisticsData)
    }
    
    func addValueToVisitorsChart(dictionary: inout [Double: Int], timestamp: Double) {
        switch state {
        case .byDay, .byWeek:
            dictionary[timestamp]? += 1
            return
        default:
            break
        }
        
        let date = Date(timeIntervalSince1970: timestamp)
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let components = calendar.dateComponents([.year, .month], from: date)
        
        let dateToAdd = calendar.date(from: components)
        let timestampToAdd = dateToAdd?.timeIntervalSince1970
        
        dictionary[timestampToAdd!]? += 1
    }
}
