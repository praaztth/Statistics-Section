//
//  ViewController.swift
//  Statistics Section
//
//  Created by tryuruy on 16.09.2024.
//

import UIKit
import RealmSwift
//import RxRealm

class StatisticsViewController: UITableViewController {
    class Cell {
        enum Sections {
            case visitors
            case visitorsChart
            case topVisitors
            case chartBySex
            case chartByAge
            case subscribers
            case unsubscribers
        }
        
        var title: String?
        var section: Sections?
        var childs: [Cell]?
        var users: [User]?
        var headerButtonTitles: [String]?
        var rowSize: CGFloat?
        
        init(title: String? = nil, section: Sections? = nil, childs: [Cell]? = nil, users: [User]? = nil, headerButtonTitles: [String]? = nil, rowSize: CGFloat? = nil) {
            self.title = title
            self.section = section
            self.childs = childs
            self.users = users
            self.headerButtonTitles = headerButtonTitles
            self.rowSize = rowSize
        }
    }
    
    struct User {
        var name: String
        var age: Int
        var isOnline: Bool
        var avatarData: Data?
    }
    
    enum State {
        case byDay
        case byWeek
        case byMonth
        case byAllPeriod
    }
    
    var datasource = [Cell]()
    var visitorsChartState: State = .byDay
    var sexAndAgeChartState: State = .byDay
    
    var users: [User] = []
    
    // Double - timestamp from date (every date in month); Int - count of visits each day
    var visitStatistics = [Double: Int]()
    var subscriptionStatistics = [Double: Int]()
    var unsubscriptionStatistics = [Double: Int]()
    
    // (<count in this month>, <count in last month>)
    var totalVisits = (0, 0)
    
    var totalSubscriptions = 0
    var totalUnsubscription = 0
    
    var maleVisitorsAge = [Int]()
    var femaleVisitorsAge = [Int]()
    
    init() {
        super.init(style: .insetGrouped)
        
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
        
        // Initializing dictionary in format "date.timestamp: count" to record the number of events in each day
        DispatchQueue.global().async { [weak self] in
            guard let dict = self?.getDaysOfMonth() else { return }
            
            self?.visitStatistics = dict
            self?.subscriptionStatistics = dict
            self?.unsubscriptionStatistics = dict
            
            
            
//            DispatchQueue.main.async {
//                self?.tableView.reloadData()
//            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Статистика"
        loadData()
    }

    func loadData() {
        // Load users and statistics in background
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.getUsers()
            self?.getStatistics()
        }
        
        // Creating a table structure
        datasource = [
            Cell(title: "Посетители", childs: [
                Cell(title: nil, section: .visitors, rowSize: 90)
            ]),
            
            Cell(title: nil, childs: [
                Cell(section: .visitorsChart, rowSize: 208)
            ], headerButtonTitles: [
                "По дням",
                "По неделям",
                "По месяцам"
            ]),
            
            Cell(title: "Чаще всех посещают Ваш профиль", section: .topVisitors, rowSize: 60),
            
            Cell(title: "Пол и возраст", childs: [
                Cell(section: .chartBySex, rowSize: 230),
                Cell(section: .chartByAge, rowSize: 300)
            ], headerButtonTitles: [
                "Сегодня",
                "Неделя",
                "Месяц",
                "Все время"
            ]),
            
            Cell(title: "Наблюдатели", childs: [
                Cell(section: .subscribers, rowSize: 90),
                Cell(section: .unsubscribers, rowSize: 90)
            ])
        ]
    }
    
    func getUsers() {
        do {
            let realm = try Realm()
            let objects = realm.objects(UserModel.self).sorted(by: { $0.listVisitTimestamps.count > $1.listVisitTimestamps.count })
            users = objects.prefix(3).map { object in
                User(name: object.username, age: object.age, isOnline: object.isOnline, avatarData: object.imageData)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            
        } catch {
            print(error)
            return
        }
        
        if !users.isEmpty{
            return
        }
        
        NetworkManager.shared.fetchUsers { [weak self] users in
            users.forEach { user in
                StorageManager.shared.createUser(id: user.id,
                                                 sex: user.sex,
                                                 username: user.username,
                                                 isOnline: user.isOnline,
                                                 age: user.age)
                
                if let imageUrl = user.files.first(where: { $0.type == "avatar" })?.url {
                    NetworkManager.shared.fetchAvatarForUser(id: user.id, url: imageUrl) { data in
                        StorageManager.shared.setImageData(id: user.id, data: data)
                        
                        self?.getUsers()
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.tableView.reloadData()
                        }
                    }
                }
            }
            
            self?.getUsers()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    func getStatistics() {
        do {
            let realm = try Realm()
            let visitStatisticsInstance = realm.objects(StatisticsModel.self).filter("type == %@", StatisticsModel.EventType.visit.rawValue)
            visitStatisticsInstance.forEach { item in
                item.listTimestamps.forEach { timestamp in
                    visitStatistics[timestamp]? += 1
                    
                    let date = Date(timeIntervalSince1970: timestamp)
                    if isDateInCurrentMonth(date) {
                        totalVisits.0 += 1
                    } else if isDateInPreviousMonth(date) {
                        totalVisits.1 += 1
                    }
                }
                
                if let userInstance = realm.object(ofType: UserModel.self, forPrimaryKey: item.userId) {
                    if userInstance.sex == "M" {
                        maleVisitorsAge.append(userInstance.age)
                    } else {
                        femaleVisitorsAge.append(userInstance.age)
                    }
                }
            }
            
            let subscribeStatisticsInstance = realm.objects(StatisticsModel.self).filter("type == %@", StatisticsModel.EventType.subscription.rawValue)
            subscribeStatisticsInstance.forEach { item in
                item.listTimestamps.forEach { timestamp in
                    subscriptionStatistics[timestamp]? += 1
                    
                    let date = Date(timeIntervalSince1970: timestamp)
                    if isDateInCurrentMonth(date) {
                        totalSubscriptions += 1
                    }
                }
            }
            
            let unsubscribeStatisticsInstance = realm.objects(StatisticsModel.self).filter("type == %@", StatisticsModel.EventType.unsubscription.rawValue)
            unsubscribeStatisticsInstance.forEach { item in
                item.listTimestamps.forEach { timestamp in
                    unsubscriptionStatistics[timestamp]? += 1
                    
                    let date = Date(timeIntervalSince1970: timestamp)
                    if isDateInCurrentMonth(date) {
                        totalUnsubscription += 1
                    }
                }
            }
            
            if visitStatisticsInstance.isEmpty && subscribeStatisticsInstance.isEmpty && unsubscribeStatisticsInstance.isEmpty {
                NetworkManager.shared.fetchStatistics { [weak self] objects in
                    objects.forEach { object in
                        StorageManager.shared.createStatisticsInstance(userId: object.user_id, type: object.type, listDatesRaw: object.dates)
                    }
                    
                    self?.getStatistics()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        } catch {
            print(error)
        }
    }
    
    func getDaysOfMonth() -> [Double: Int] {
        let now = Date()
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        let monthRange = calendar.range(of: .day, in: .month, for: now) ?? 1..<30
        let components = calendar.dateComponents([.year, .month], from: now)
        var date = calendar.date(from: components)
        
        var dictionary: [Double: Int] = [:]
        
        for _ in monthRange {
            dictionary[date!.timeIntervalSince1970] = 0
            date = calendar.date(byAdding: .day, value: 1, to: date!)
        }
        
        return dictionary
    }
    
    func isDateInCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDateComponents = calendar.dateComponents([.year, .month], from: Date())
        
        let givenDateComponents = calendar.dateComponents([.year, .month], from: date)
        
        return currentDateComponents.year == givenDateComponents.year && currentDateComponents.month == givenDateComponents.month
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

extension StatisticsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = datasource[section]
        if item.section == .topVisitors {
            return users.count
        }
        return item.childs?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = datasource[indexPath.section].childs?[indexPath.row] ?? datasource[indexPath.section]
        
        switch item.section {
        case .visitors:
            let cell = VisitorsSmallChartTableViewCell()
            cell.setup(text: "Количество посетителей в этом месяце \(totalVisits.0 > totalVisits.1 ? "выросло" : "упало")", count: String(totalVisits.0), color: .green, data: visitStatistics)
            
            return cell
            
        case .visitorsChart:
            let cell = VisitorsBigChartTableViewCell()
            cell.setup(data: visitStatistics)
            
            return cell
            
        case .topVisitors:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as? UserCell else {
                return UITableViewCell(frame: .zero)
            }
            
            let user = users[indexPath.row]
            
            cell.setup(title: "\(user.name), \(user.age)", isOnline: user.isOnline, imageData: user.avatarData)
            cell.accessoryType = .disclosureIndicator
            
            return cell
            
        case .chartBySex:
            let cell = ChartBySexTableViewCell()
            cell.setup(maleCount: maleVisitorsAge.count, femaleCount: femaleVisitorsAge.count)
            
            return cell
            
        case .chartByAge:
            let cell = ChartByAgeTableViewCell()
            cell.setup(maleAges: maleVisitorsAge, femaleAges: femaleVisitorsAge)
            
            return cell
            
        case .subscribers:
            let cell = VisitorsSmallChartTableViewCell()
            cell.setup(text: "Новые наблюдатели в этом месяце", count: String(totalSubscriptions), color: .green, data: subscriptionStatistics)
            
            return cell
            
        case .unsubscribers:
            let cell = VisitorsSmallChartTableViewCell()
            cell.setup(text: "Пользователей перестали за Вами наблюдать", count: String(totalUnsubscription), color: .red, data: unsubscriptionStatistics)
            
            return cell
            
        default:
            return UITableViewCell()
        }
        
        
    }
}

extension StatisticsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = datasource[indexPath.section].childs?[indexPath.row] ?? datasource[indexPath.section]
        
        return item.rowSize ?? tableView.estimatedRowHeight
//        switch item.section {
//        case .visitors, .subscribers, .unsubscribers:
//            return 90
//        case .visitorsChart:
//            return 208
//        case .topVisitors:
//            return 60
//        case .chartBySex:
//            return 230
//        case .chartByAge:
//            return 300
//        default:
//            return tableView.estimatedRowHeight
//        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let item = datasource[section]
        
        if let buttons = item.headerButtonTitles,
           let item = item.childs?.first {
            let view = StackButtonsTableViewHeader(buttonTitles: buttons)
            
            switch item.section {
            case .visitorsChart:
                view.dayButton.addTarget(self, action: #selector(onVisitorsDayButtonTapped), for: .touchUpInside)
                view.weekButton.addTarget(self, action: #selector(onVisitorsWeekButtonTapped), for: .touchUpInside)
                view.monthButton.addTarget(self, action: #selector(onVisitorsMonthButtonTapped), for: .touchUpInside)
                
                switch visitorsChartState {
                case .byDay:
                    view.dayButton.isSelected = true
                case .byWeek:
                    view.weekButton.isSelected = true
                case .byMonth:
                    view.monthButton.isSelected = true
                default: break
                }
                
            case .chartBySex:
                view.dayButton.addTarget(self, action: #selector(onSexAndAgeDayButtonTapped), for: .touchUpInside)
                view.weekButton.addTarget(self, action: #selector(onSexAndAgeWeekButtonTapped), for: .touchUpInside)
                view.monthButton.addTarget(self, action: #selector(onSexAndAgeMonthButtonTapped), for: .touchUpInside)
                view.allPeriodButton?.addTarget(self, action: #selector(onSexAndAgeAllPeriodButtonTapped), for: .touchUpInside)
                
                switch sexAndAgeChartState {
                case .byDay:
                    view.dayButton.isSelected = true
                case .byWeek:
                    view.weekButton.isSelected = true
                case .byMonth:
                    view.monthButton.isSelected = true
                case .byAllPeriod:
                    view.allPeriodButton?.isSelected = true
                }
                
            default: break
            }
            
            return view
        }
        
        let label = UILabel()
        label.text = item.title
        label.font = .boldSystemFont(ofSize: label.font.pointSize)
        
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let item = datasource[section].childs?.first ?? datasource[section]
        
        if item.section == .visitorsChart || item.section == .chartByAge {
            return 45
        }
        
        return 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StatisticsViewController {
    @objc
    func onVisitorsDayButtonTapped() {
        guard visitorsChartState != .byDay else {
            return
        }
        
        visitorsChartState = .byDay
        tableView.reloadData()
    }
    
    @objc
    func onVisitorsWeekButtonTapped() {
        guard visitorsChartState != .byWeek else {
            return
        }
        
        visitorsChartState = .byWeek
        tableView.reloadData()
    }
    
    @objc
    func onVisitorsMonthButtonTapped() {
        guard visitorsChartState != .byMonth else {
            return
        }
        
        visitorsChartState = .byMonth
        tableView.reloadData()
    }
    
    @objc
    func onSexAndAgeDayButtonTapped() {
        guard sexAndAgeChartState != .byDay else {
            return
        }
        
        sexAndAgeChartState = .byDay
        tableView.reloadData()
    }
    
    @objc
    func onSexAndAgeWeekButtonTapped() {
        guard sexAndAgeChartState != .byWeek else {
            return
        }
        
        sexAndAgeChartState = .byWeek
        tableView.reloadData()
    }
    
    @objc
    func onSexAndAgeMonthButtonTapped() {
        guard sexAndAgeChartState != .byMonth else {
            return
        }
        
        sexAndAgeChartState = .byMonth
        tableView.reloadData()
    }
    
    @objc
    func onSexAndAgeAllPeriodButtonTapped() {
        guard sexAndAgeChartState != .byAllPeriod else {
            return
        }
        
        sexAndAgeChartState = .byAllPeriod
        tableView.reloadData()
    }
}
