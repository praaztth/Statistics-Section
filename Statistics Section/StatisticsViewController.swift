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
        
        struct User {
            var name: String
            var age: Int
            var avatarUrl: String
        }
        
        var title: String?
        var section: Sections?
        var childs: [Cell]?
        var users: [User]?
        var headerButtonTitles: [String]?
        
        init(title: String? = nil, section: Sections? = nil, childs: [Cell]? = nil, users: [User]? = nil, headerButtonTitles: [String]? = nil) {
            self.title = title
            self.section = section
            self.childs = childs
            self.users = users
            self.headerButtonTitles = headerButtonTitles
        }
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
    
    var users: [UserModel] = []
    
    init() {
        super.init(style: .insetGrouped)
        
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.reuseIdentifier)
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
//        DispatchQueue.global(qos: .userInitiated).async {
//            self.getUsers()
//        }
        
        datasource = [
            Cell(title: "Посетители", childs: [
                Cell(title: nil, section: .visitors)
            ]),
            
            Cell(title: nil, childs: [
                Cell(section: .visitorsChart)
            ], headerButtonTitles: [
                "По дням",
                "По неделям",
                "По месяцам"
            ]),
            
            Cell(title: "Чаще всех посещают Ваш профиль", section: .topVisitors, users: [
                    Cell.User(name: "ann.aeom", age: 25, avatarUrl: "gfsdfg"),
                    Cell.User(name: "akimovahuiw", age: 23, avatarUrl: "gfsdfg"),
                    Cell.User(name: "gulia.filova", age: 32, avatarUrl: "gfsdfg")
            ]),
            
            Cell(title: "Пол и возраст", childs: [
                Cell(section: .chartBySex),
                Cell(section: .chartByAge)
            ], headerButtonTitles: [
                "Сегодня",
                "Неделя",
                "Месяц",
                "Все время"
            ]),
            
            Cell(title: "Наблюдатели", childs: [
                Cell(section: .subscribers),
                Cell(section: .unsubscribers)
            ])
        ]
    }
    
    func getUsers() {
        do {
            let realm = try Realm()
//            users = realm.objects(UserModel.self)
        } catch {
            print(error)
        }
        
        if !users.isEmpty{
            return
        }
        
        NetworkManager.shared.fetchUsers { users in
            users.forEach { user in
                let userInstance = UserModel()
                userInstance.id = user.id
                userInstance.sex = user.sex
                userInstance.username = user.username
                userInstance.isOnline = user.isOnline
                userInstance.age = user.age
                
                userInstance.imageUrl = user.files.first(where: { $0.type == "avatar" })?.url
                
                do {
                    let realm = try Realm()
                    
                    try realm.write {
                        realm.add(userInstance)
                    }
                } catch {
                    print(error)
                }
            }
        }
        
        
    }
}

extension StatisticsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = datasource[section]
        
        return item.childs?.count ?? item.users?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = datasource[indexPath.section].childs?[indexPath.row] ?? datasource[indexPath.section]
        
        switch item.section {
        case .visitors:
            let cell = VisitorsSmallChartTableViewCell()
            cell.setup(text: "Количество посетителей в этом месяце выросло", count: "1356", color: .green)
            
            return cell
            
        case .visitorsChart:
            let cell = VisitorsBigChartTableViewCell()
            cell.setup()
            
            return cell
            
        case .topVisitors:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.reuseIdentifier, for: indexPath) as? UserCell,
                  let user = item.users?[indexPath.row] else {
                return UITableViewCell(frame: .zero)
            }
            
            cell.setup(title: user.name)
            cell.accessoryType = .disclosureIndicator
            
            return cell
            
        case .chartBySex:
            let cell = ChartBySexTableViewCell()
            cell.setup()
            
            return cell
            
        case .chartByAge:
            let cell = ChartByAgeTableViewCell()
            cell.setup()
            
            return cell
            
        case .subscribers:
            let cell = VisitorsSmallChartTableViewCell()
            cell.setup(text: "text", count: "count", color: .green)
            
            return cell
            
        case .unsubscribers:
            let cell = VisitorsSmallChartTableViewCell()
            cell.setup(text: "text", count: "count", color: .red)
            
            return cell
            
        default:
            return UITableViewCell()
        }
        
        
    }
}

extension StatisticsViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = datasource[indexPath.section].childs?[indexPath.row] ?? datasource[indexPath.section]
        
        switch item.section {
        case .visitors, .subscribers, .unsubscribers:
            return 90
        case .visitorsChart:
            return 208
        case .topVisitors:
            return 60
        case .chartBySex:
            return 230
        case .chartByAge:
            return 300
        default:
            return tableView.estimatedRowHeight
        }
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
