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
    
    // (<count in this month>, <count in last month>)
    var totalVisits = (0, 0)
    
    var totalSubscriptions = 0
    var totalUnsubscription = 0
    
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
                if results.element != nil && results.element!.isEmpty || results.element == nil {
                    return
                }
                
                self.prepareUsers(usersInstances: results.element!.toArray())
                self.tableView.reloadData()
                
            }.disposed(by: bag)
            
            Observable.collection(from: statistics).subscribe { results in
                if results.element != nil && results.element!.isEmpty || results.element == nil {
                    return
                }
                
                self.prepareStatistics(statisticsInstances: results.element!.toArray())
                self.tableView.reloadData()
                
            }.disposed(by: bag)
        } catch {
            print(error)
        }
        
        visitorsChartState.asObservable().subscribe { _ in
            self.tableView.reloadData()
        }.disposed(by: bag)
        
        sexAndAgeChartState.asObservable().subscribe { _ in
            self.tableView.reloadData()
        }.disposed(by: bag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Статистика"
        subscribe()
        prepareTableStructure()
    }

    func prepareTableStructure() {
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
    
    func prepareUsers(usersInstances: [UserModel]) {
        users = usersInstances.prefix(3).map { object in
            User(name: object.username, age: object.age, isOnline: object.isOnline, avatarData: object.imageData)
        }
    }
    
    func prepareStatistics(statisticsInstances: [StatisticsModel]) {
        totalVisits = (0, 0)
        totalSubscriptions = 0
        totalUnsubscription = 0
        
        do {
            let realm = try Realm()
            let visitStatisticsInstance = realm.objects(StatisticsModel.self).filter("type == %@", StatisticsModel.EventType.visit.rawValue)
            visitStatisticsInstance.forEach { item in
                item.listTimestamps.forEach { timestamp in
                    let date = Date(timeIntervalSince1970: timestamp)
                    if Constants.shared.isDateInCurrentMonth(date) {
                        totalVisits.0 += 1
                        
                    } else if Constants.shared.isDateInPreviousMonth(date) {
                        totalVisits.1 += 1
                        
                    }
                }
            }
            
            let subscribeStatisticsInstance = realm.objects(StatisticsModel.self).filter("type == %@", StatisticsModel.EventType.subscription.rawValue)
            subscribeStatisticsInstance.forEach { item in
                item.listTimestamps.forEach { timestamp in
                    let date = Date(timeIntervalSince1970: timestamp)
                    if Constants.shared.isDateInCurrentMonth(date) {
                        totalSubscriptions += 1
                    }
                }
            }
            
            let unsubscribeStatisticsInstance = realm.objects(StatisticsModel.self).filter("type == %@", StatisticsModel.EventType.unsubscription.rawValue)
            unsubscribeStatisticsInstance.forEach { item in
                item.listTimestamps.forEach { timestamp in
                    let date = Date(timeIntervalSince1970: timestamp)
                    if Constants.shared.isDateInCurrentMonth(date) {
                        totalUnsubscription += 1
                    }
                }
            }
        } catch {
            print(error)
        }
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
            let cell = SmallChartTableViewCell()
            cell.setup(text: "Количество посетителей в этом месяце \(totalVisits.0 > totalVisits.1 ? "выросло" : "упало")", count: String(totalVisits.0), color: .green, type: .visit)
            
            return cell
            
        case .visitorsChart:
            let cell = VisitorsBigChartTableViewCell()
            
            var state: VisitorsChartViewController.State? = nil
            switch visitorsChartState.value {
            case .byDay:
                state = .byDay
            case .byWeek:
                state = .byWeek
            case .byMonth:
                state = .byMonth
            default: break
            }
            
            cell.setup(state: state!)
            
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
            
            var state: ChartBySexViewController.State? = nil
            switch sexAndAgeChartState.value {
            case .byDay:
                state = .byDay
            case .byWeek:
                state = .byWeek
            case .byMonth:
                state = .byMonth
            default: 
                state = .byAllPeriod
            }
            
            cell.setup(state: state!)
            
            return cell
            
        case .chartByAge:
            let cell = ChartByAgeTableViewCell()
            
            var state: ChartByAgeViewController.State? = nil
            switch sexAndAgeChartState.value {
            case .byDay:
                state = .byDay
            case .byWeek:
                state = .byWeek
            case .byMonth:
                state = .byMonth
            default:
                state = .byAllPeriod
            }
            
            cell.setup(state: state!)
            
            return cell
            
        case .subscribers:
            let cell = SmallChartTableViewCell()
            cell.setup(text: "Новые наблюдатели в этом месяце", count: String(totalSubscriptions), color: .green, type: .subscription)
            
            return cell
            
        case .unsubscribers:
            let cell = SmallChartTableViewCell()
            cell.setup(text: "Пользователей перестали за Вами наблюдать", count: String(totalUnsubscription), color: .red, type: .unsubscription)
            
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
