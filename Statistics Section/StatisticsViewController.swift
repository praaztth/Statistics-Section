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
        
        init(title: String? = nil, section: Sections? = nil, childs: [Cell]? = nil, users: [User]? = nil, headerButtonTitles: [String]? = nil) {
            self.title = title
            self.section = section
            self.childs = childs
            self.users = users
            self.headerButtonTitles = headerButtonTitles
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
        DispatchQueue.global(qos: .userInitiated).async {
            self.getUsers()
        }
        
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
            
            Cell(title: "Чаще всех посещают Ваш профиль", section: .topVisitors),
            
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
            let objects = realm.objects(UserModel.self).sorted(by: { $0.numberOfVisits > $1.numberOfVisits })
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
                    }
                }
            }
            
            self?.getUsers()
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
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
            cell.setup(text: "Количество посетителей в этом месяце выросло", count: "1356", color: .green)
            
            return cell
            
        case .visitorsChart:
            let cell = VisitorsBigChartTableViewCell()
            cell.setup()
            
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
