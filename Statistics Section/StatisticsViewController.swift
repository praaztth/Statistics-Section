//
//  ViewController.swift
//  Statistics Section
//
//  Created by tryuruy on 16.09.2024.
//

import UIKit
import RealmSwift
import RxRealm
import RxSwift
import RxCocoa

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
        var heightForHeaderInSection: CGFloat?
        
        init(title: String? = nil, section: Sections? = nil, childs: [Cell]? = nil, users: [User]? = nil, headerButtonTitles: [String]? = nil, rowSize: CGFloat? = nil, heightForHeaderInSection: CGFloat? = nil) {
            self.title = title
            self.section = section
            self.childs = childs
            self.users = users
            self.headerButtonTitles = headerButtonTitles
            self.rowSize = rowSize
            self.heightForHeaderInSection = heightForHeaderInSection
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
    
    let bag = DisposeBag()
    
    var datasource = [Cell]()
    var visitorsChartState: BehaviorRelay<State> = BehaviorRelay(value: .byDay)
    var sexAndAgeChartState: BehaviorRelay<State> = BehaviorRelay(value: .byDay)
    
    var users: [User] = []
    
    // Double - timestamp from date (every date in month); Int - count of visits each day
    var visitStatisticsSmallChart = [Double: Int]()
    var visitStatisticsBigChart = [Double: Int]()
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func subscribe() {
        do {
            let realm = try Realm()
            let users = realm.objects(UserModel.self)
            let statistics = realm.objects(StatisticsModel.self)
            
            Observable.collection(from: users).subscribe { results in
                self.getUsers()
                self.tableView.reloadData()
            }.disposed(by: bag)
            
            Observable.collection(from: statistics).subscribe { results in
                if results.element != nil && results.element!.isEmpty {
                    // If no data in database then request to server
                    DispatchQueue.global().async {
                        NetworkManager.shared.fetchStatistics { objects in
                            objects.forEach { object in
                                StorageManager.shared.createStatisticsInstance(userId: object.user_id, type: object.type, listDatesRaw: object.dates)
                            }
                            
                            self.getStatistics()
                        }
                        
                    }
                    return
                }
                
                self.getStatistics()
                self.tableView.reloadData()
            }.disposed(by: bag)
        } catch {
            print(error)
        }
        
        visitorsChartState.asObservable().subscribe { _ in
            self.getStatistics()
            self.tableView.reloadData()
        }.disposed(by: bag)
        
        sexAndAgeChartState.asObservable().subscribe { _ in
            self.getStatistics()
            self.tableView.reloadData()
        }.disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Статистика"
        subscribe()
        loadData()
    }

    func loadData() {
        // Creating a table structure
        datasource = [
            Cell(title: "Посетители", childs: [
                Cell(title: nil, section: .visitors, rowSize: 90)
            ]),
            
            Cell(title: nil, childs: [
                Cell(section: .visitorsChart, rowSize: 208, heightForHeaderInSection: 45)
            ], headerButtonTitles: [
                "По дням",
                "По неделям",
                "По месяцам"
            ]),
            
            Cell(title: "Чаще всех посещают Ваш профиль", section: .topVisitors, rowSize: 60),
            
            Cell(title: "Пол и возраст", childs: [
                Cell(section: .chartBySex, rowSize: 230),
                Cell(section: .chartByAge, rowSize: 300, heightForHeaderInSection: 45)
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
        
        // If no data in database then request to server
        NetworkManager.shared.fetchUsers { users in
            users.forEach { user in
                StorageManager.shared.createUser(id: user.id,
                                                 sex: user.sex,
                                                 username: user.username,
                                                 isOnline: user.isOnline,
                                                 age: user.age)
                
                if let imageUrl = user.files.first(where: { $0.type == "avatar" })?.url {
                    NetworkManager.shared.fetchAvatarForUser(id: user.id, url: imageUrl) { data in
                        StorageManager.shared.setImageData(id: user.id, data: data)
                    }
                }
            }
        }
    }
    
    func getStatistics() {
        // Initializing dictionary in the format "date.timestamp: count" to record the number of events in each day
        let dict = getDaysOfMonth()
        
        visitStatisticsSmallChart = dict
        subscriptionStatistics = dict
        unsubscriptionStatistics = dict
        
        visitStatisticsBigChart = getTimeInterval()
        
        totalVisits = (0, 0)
        totalSubscriptions = 0
        totalUnsubscription = 0
        
        maleVisitorsAge = []
        femaleVisitorsAge = []
        
        do {
            let realm = try Realm()
            let visitStatisticsInstance = realm.objects(StatisticsModel.self).filter("type == %@", StatisticsModel.EventType.visit.rawValue)
            visitStatisticsInstance.forEach { item in
                item.listTimestamps.forEach { timestamp in
                    visitStatisticsSmallChart[timestamp]? += 1
                    
                    let date = Date(timeIntervalSince1970: timestamp)
                    if isDateInCurrentMonth(date) {
                        totalVisits.0 += 1
                    } else if isDateInPreviousMonth(date) {
                        totalVisits.1 += 1
                    }
                    
                    if isDisplayNeededForSectionVisitorsBySexAndAge(timestamp: timestamp) {
                        if let userInstance = realm.object(ofType: UserModel.self, forPrimaryKey: item.userId) {
                            if userInstance.sex == "M" {
                                maleVisitorsAge.append(userInstance.age)
                            } else {
                                femaleVisitorsAge.append(userInstance.age)
                            }
                        }
                    }
                    
                    addValueToVisitorsChart(timestamp: timestamp)
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
        } catch {
            print(error)
        }
    }
    
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
    
    func getTimeInterval() -> [Double: Int] {
        var component: Calendar.Component? = nil
        var components: DateComponents? = nil
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        var multiplier = 1
        
        switch visitorsChartState.value {
        case .byDay:
            component = .day
            components = calendar.dateComponents([.year, .month, .day], from: Date())
        case .byWeek:
            component = .day
            components = calendar.dateComponents([.year, .month, .day], from: Date())
            multiplier = 4
        case .byMonth:
            component = .month
            components = calendar.dateComponents([.year, .month], from: Date())
        default:
            break
        }
        
        let currentDate = calendar.date(from: components!)
        
        var dictionary: [Double: Int] = [:]
        
        for i in 0...(7 * multiplier) {
            let date = calendar.date(byAdding: component!, value: -i, to: currentDate!)
            dictionary[date!.timeIntervalSince1970] = 0
        }
        
        return dictionary
    }
    
    func isDisplayNeededForSectionVisitorsBySexAndAge(timestamp: Double) -> Bool {
        let date = Date(timeIntervalSince1970: timestamp)
        switch sexAndAgeChartState.value {
        case .byDay:
            return isDateInCurrentDay(date)
        case .byWeek:
            return isDateInCurrentWeek(date)
        case .byMonth:
            return isDateInCurrentMonth(date)
        case .byAllPeriod:
            return true
        }
    }
    
    func isDisplayNeededForSectionAllVisitors(timestamp: Double) -> Bool {
        let date = Date(timeIntervalSince1970: timestamp)
        switch visitorsChartState.value {
        case .byDay:
            return isDateInCurrentDay(date)
        case .byWeek:
            return isDateInCurrentWeek(date)
        case .byMonth:
            return isDateInCurrentMonth(date)
        default:
            return false
        }
    }
    
    func addValueToVisitorsChart(timestamp: Double) {
        switch visitorsChartState.value {
        case .byDay, .byWeek:
            visitStatisticsBigChart[timestamp]? += 1
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
        
        visitStatisticsBigChart[timestampToAdd!]? += 1
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
            cell.setup(text: "Количество посетителей в этом месяце \(totalVisits.0 > totalVisits.1 ? "выросло" : "упало")", count: String(totalVisits.0), color: .green, data: visitStatisticsSmallChart)
            
            return cell
            
        case .visitorsChart:
            let cell = VisitorsBigChartTableViewCell()
            cell.setup(data: visitStatisticsBigChart)
            
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
                
                switch visitorsChartState.value {
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
                
                switch sexAndAgeChartState.value {
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
        
        return item.heightForHeaderInSection ?? 50
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StatisticsViewController {
    @objc
    func onVisitorsDayButtonTapped() {
        guard visitorsChartState.value != .byDay else {
            return
        }
        
        visitorsChartState.accept(.byDay)
    }
    
    @objc
    func onVisitorsWeekButtonTapped() {
        guard visitorsChartState.value != .byWeek else {
            return
        }
        
        visitorsChartState.accept(.byWeek)
    }
    
    @objc
    func onVisitorsMonthButtonTapped() {
        guard visitorsChartState.value != .byMonth else {
            return
        }
        
        visitorsChartState.accept(.byMonth)
    }
    
    @objc
    func onSexAndAgeDayButtonTapped() {
        guard sexAndAgeChartState.value != .byDay else {
            return
        }
        
        sexAndAgeChartState.accept(.byDay)
    }
    
    @objc
    func onSexAndAgeWeekButtonTapped() {
        guard sexAndAgeChartState.value != .byWeek else {
            return
        }
        
        sexAndAgeChartState.accept(.byWeek)
    }
    
    @objc
    func onSexAndAgeMonthButtonTapped() {
        guard sexAndAgeChartState.value != .byMonth else {
            return
        }
        
        sexAndAgeChartState.accept(.byMonth)
    }
    
    @objc
    func onSexAndAgeAllPeriodButtonTapped() {
        guard sexAndAgeChartState.value != .byAllPeriod else {
            return
        }
        
        sexAndAgeChartState.accept(.byAllPeriod)
    }
}
