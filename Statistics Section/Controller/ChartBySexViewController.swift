//
//  ChartBySexViewController.swift
//  Statistics Section
//
//  Created by tryuruy on 22.09.2024.
//

import Foundation
import UIKit
import SwiftUI
import RealmSwift

class ChartBySexViewController {
    enum State {
        case byDay
        case byWeek
        case byMonth
        case byAllPeriod
    }
    
    private var maleVisitorsCount = 0
    private var femaleVisitorsCount = 0
    private var view: ChartBySex? = nil
    private var state: State
    
    internal var chartView: UIView {
        let hostingView = UIHostingController(rootView: view)
        return hostingView.view
    }
    
    init(state: State) {
        self.state = state
        
        prepareStatistics()
        prepareView()
    }
    
    func prepareStatistics() {
        do {
            let realm = try Realm()
            let visitStatisticsInstance = realm.objects(StatisticsModel.self).filter("type == %@", StatisticsModel.EventType.visit.rawValue)
            
            visitStatisticsInstance.forEach { item in
                item.listTimestamps.forEach { timestamp in
                    if isDisplayNeededForSectionVisitorsBySexAndAge(timestamp: timestamp) {
                        if let userInstance = realm.object(ofType: UserModel.self, forPrimaryKey: item.userId) {
                            if userInstance.sex == "M" {
                                maleVisitorsCount += 1
                            } else {
                                femaleVisitorsCount += 1
                            }
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
    }
    
    func prepareView() {
        view = ChartBySex(maleCount: maleVisitorsCount, femaleCount: femaleVisitorsCount)
    }
    
    func isDisplayNeededForSectionVisitorsBySexAndAge(timestamp: Double) -> Bool {
        let date = Date(timeIntervalSince1970: timestamp)
        switch state {
        case .byDay:
            return Constants.shared.isDateInCurrentDay(date)
        case .byWeek:
            return Constants.shared.isDateInCurrentWeek(date)
        case .byMonth:
            return Constants.shared.isDateInCurrentMonth(date)
        case .byAllPeriod:
            return true
        }
    }
}
