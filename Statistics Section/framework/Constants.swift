//
//  Constants.swift
//  Statistics Section
//
//  Created by tryuruy on 22.09.2024.
//

import Foundation

class Constants {
    static let shared = Constants()
    
    func getDaysOfMonth() -> [Double: Int] {
        let now = Date()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let monthRange = calendar.range(of: .day, in: .month, for: now) ?? 1..<30
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        var date = calendar.date(from: components)
        
        var dictionary: [Double: Int] = [:]
        
        for _ in monthRange {
            dictionary[date!.timeIntervalSince1970] = 0
            date = calendar.date(byAdding: .day, value: -1, to: date!)
        }
        
        return dictionary
    }
    
    func getTimeInterval(components: Set<Calendar.Component>, componentStep: Calendar.Component, multiplier: Int) -> [Double: Int] {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let dateComponents = calendar.dateComponents(components, from: Date())
        let currentDate = calendar.date(from: dateComponents)
        
        var dictionary: [Double: Int] = [:]
        
        for i in 0...(7 * multiplier) {
            let date = calendar.date(byAdding: componentStep, value: -i, to: currentDate!)
            dictionary[date!.timeIntervalSince1970] = 0
        }
        
        return dictionary
    }
    
    func isDateInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.year, .month], from: Date())
        
        let givenDateComponents = calendar.dateComponents([.year, .month], from: date)
        
        return currentDateComponents.year == givenDateComponents.year && currentDateComponents.month == givenDateComponents.month
    }
    
    func isDateInCurrentWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        
        let givenDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        return currentDateComponents.year == givenDateComponents.year && currentDateComponents.month == givenDateComponents.month && currentDateComponents.day! - givenDateComponents.day! <= 7
    }
    
    func isDateInCurrentDay(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        
        let givenDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        return currentDateComponents.year == givenDateComponents.year && currentDateComponents.month == givenDateComponents.month && currentDateComponents.day == givenDateComponents.day
    }
    
    func isDateInPreviousMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        
        let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        let previousMonthComponents = calendar.dateComponents([.year, .month], from: previousMonthDate)
        
        let givenDateComponents = calendar.dateComponents([.year, .month], from: date)
        
        return previousMonthComponents.year == givenDateComponents.year && previousMonthComponents.month == givenDateComponents.month
    }
}
