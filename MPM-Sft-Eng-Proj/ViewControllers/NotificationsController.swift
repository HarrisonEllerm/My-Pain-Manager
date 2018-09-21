//
//  NotificationsController.swift
//  MPM-Sft-Eng-Proj
//
//  Created by Sebastian Peden on 9/18/18.
//  Copyright © 2018 Harrison Ellerm. All rights reserved.

import UIKit
import FirebaseAuth
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import Photos
import SwiftSpinner
import EventKit
import SwiftyBeaver
import DateToolsSwift

fileprivate struct NotificationCellData {
    let message: String?
    let value: String?
}

class NotificationsController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let log = SwiftyBeaver.self
    var period: String?
    var time: String?
    var enableCell: EnableButtonCell?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var parts: [String]?

//    var eventStore = EKEventStore()
    // var calendars: Array<EKCalendar> = []

    private var window: UIWindow?
    // show the view table
    private let NotificationTableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        t.allowsSelection = true
        t.allowsMultipleSelection = false
        return t
    }()

    let label = UILabel()

    private var data = [NotificationCellData]()

    override func viewDidLoad() {
        super.viewDidLoad()
        Service.setupNavBar(controller: self)
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        let vc = navigationController?.viewControllers.first
        let button = UIBarButtonItem(title: "Profile", style: .plain, target: self, action: nil)
        vc?.navigationItem.backBarButtonItem = button
        setUpTable()
        setupTableData()
    }

    private func setupTableData() {
        self.data = [NotificationCellData.init(message: "Period", value: "Daily"),
            NotificationCellData.init(message: "Time", value: "12:00 PM"),
            NotificationCellData.init(message: "EnableNotificaitons", value: "False")]
    }


    fileprivate func setUpTable() {
        view.addSubview(NotificationTableView)
        view.addSubview(label)
        NotificationTableView.register(PeriodEntryCell.self, forCellReuseIdentifier: "periodEntry")
        NotificationTableView.register(TimeEntryCell.self, forCellReuseIdentifier: "timeEntry")
        NotificationTableView.register(EnableButtonCell.self, forCellReuseIdentifier: "buttonCell")
        anchorTable()
        NotificationTableView.delegate = self
        NotificationTableView.dataSource = self
        NotificationTableView.rowHeight = 44
        NotificationTableView.isScrollEnabled = false
        NotificationTableView.allowsSelection = true
    }

    func anchorTable() {
        NotificationTableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        NotificationTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        NotificationTableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        NotificationTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = self.NotificationTableView.dequeueReusableCell(withIdentifier: "periodEntry") as! PeriodEntryCell
            cell.delegate = self
            cell.textFieldName = data[indexPath.row].message
            cell.textFieldValue = data[indexPath.row].value
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else if (indexPath.row == 1) {
            let cell = self.NotificationTableView.dequeueReusableCell(withIdentifier: "timeEntry") as! TimeEntryCell
            cell.delegate = self
            cell.textFieldName = data[indexPath.row].message
            cell.textFieldValue = data[indexPath.row].value
            cell.accessoryType = .disclosureIndicator
            cell.layoutSubviews()
            return cell
        } else {
            enableCell = self.NotificationTableView.dequeueReusableCell(withIdentifier: "buttonCell") as? EnableButtonCell
            enableCell!.delegate = self
            enableCell!.name = "Enabled"
            enableCell!.selectionStyle = UITableViewCellSelectionStyle.none
            return enableCell!
        }
    }

    private func createReminder() {
        let localDate = Date()
        log.debug("CREATING REMINDER")
        let reminder = EKReminder(eventStore: appDelegate.eventStore!)
        reminder.title = "Time to Log an entry!"
        reminder.calendar = appDelegate.eventStore!.defaultCalendarForNewReminders()
        if let hourandmins = parts {
            let hour = Int(hourandmins[0])
            let min = Int(hourandmins[1].trimmingCharacters(in: CharacterSet.init(charactersIn: " PM")))
            if let calHour = hour, let calMin = min {
                log.debug("Was able to set calHour and calMin")
                log.debug("Setting up startDateComponents and endDateComponents")
                reminder.startDateComponents = DateComponents(calendar: nil, timeZone: TimeZone.current, era: nil, year: localDate.year, month: localDate.month, day: localDate.day, hour: calHour, minute: calMin, second: 0, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                reminder.dueDateComponents = DateComponents(calendar: nil, timeZone: TimeZone.current, era: nil, year: localDate.year.advanced(by: 1), month: localDate.month, day: localDate.day, hour: calHour, minute: calMin, second: 0, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
                var rule: EKRecurrenceRule?
                //Set Recurrence
                if let per = period {
                    switch per {
                    case "Daily":
                        log.debug("daily")
                        rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.daily, interval: 1, end: nil)
                    case "Weekly":
                        log.debug("weekly")
                        rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.weekly, interval: 1, end: nil)
                    case "Monthly":
                        log.debug("monthly")
                        rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.monthly, interval: 1, end: nil)
                    default:
                        return
                    }
                }
                if let setRule = rule, let startDateComponents = reminder.startDateComponents {
                    print("Setting Recurrence Rule")
                    reminder.addRecurrenceRule(setRule)
                    //Create alarm
                    let alarm = EKAlarm(absoluteDate: startDateComponents.date!)
                    reminder.addAlarm(alarm)
                    try! appDelegate.eventStore?.save(reminder, commit: true)
                }
            }
        }
    }
}

extension NotificationsController: EnableButtonCellDelegate, PeriodEntryCellDelegate, TimeEntryCellDelegate {

    func buttonActivated(_ button: UISwitch) {
        if button.isOn {
            if appDelegate.eventStore == nil {
                appDelegate.eventStore = EKEventStore()
                appDelegate.eventStore?.requestAccess(to: EKEntityType.reminder, completion:
                        { (granted, error) in
                            if !granted {
                                /**
                                    If user hasn't granted permissions, dont enable notifications.
                                    The user will only be prompted once to enable permissions, if they
                                    deny permissions initially they have to go into settings and enable
                                    them manually.
                                 */
                                DispatchQueue.main.sync {
                                    Service.showAlert(on: self, style: .alert, title: "Whoops", message: "We cannot enable notifications without permission! If you chang your mind, you can enable reminders in Settings -> MyPainManager.")
                                    if let buttonCell = self.enableCell {
                                        buttonCell.switchButton.setOn(false, animated: true)
                                        buttonCell.layoutSubviews()
                                        return
                                    }
                                }
                            } else {
                                //User has granted permission, and event store was initially nil
                                self.createReminder()
                            }
                    })
            } else {
                print("Event Store not nil")
                self.createReminder()
            }
        } else {
            //figure out how to disable notifs if they exist
        }
    }


    func textFieldInCell(cell: PeriodEntryCell, editingChangedInTextField newText: String) {
        period = newText
    }

    func textFieldInCell(cell: TimeEntryCell, editingChangedInTextField newText: String) {
        time = newText
        parts = newText.split(separator: ":").map({ String($0) })
    }
}
