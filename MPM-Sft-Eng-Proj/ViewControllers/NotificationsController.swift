//
//  NotificationsController.swift
//  MPM-Sft-Eng-Proj
//
//  Please note that when testing on a simulator
//  setting up events/reminders will NOT work. You
//  will need a physical device with an apple account.
//
//
//  Created by Sebastian Peden on 9/18/18. Modified
//  by Harrison Ellerm on 11/18/18.
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

/**
    Represents the tableview cell data.
*/
fileprivate struct NotificationCellData {
    let message: String?
    let value: String?
}

class NotificationsController: UIViewController {

    private let log = SwiftyBeaver.self
    private var period: String = "Daily"
    private var time: String = "12:00 PM"
    private var enableCell: EnableButtonCell?
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var reminder: EKEvent?
    private var data = [NotificationCellData]()

    private let NotificationTableView: UITableView = {
        let t = UITableView()
        t.translatesAutoresizingMaskIntoConstraints = false
        t.isScrollEnabled = true
        t.tableFooterView = UIView(frame: .zero)
        t.allowsSelection = true
        t.allowsMultipleSelection = false
        return t
    }()

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
    
    /**
        Grabs a hold of the users event (if it exists) and
        removes it (and all future repeating events of that
        same type).
    */
    private func turnOffReminders() {
        if let event = reminder {
            do {
                //Deleting this event should also remove all future events
                try appDelegate.eventStore?.remove(event, span: EKSpan.futureEvents, commit: true)
            } catch let error {
                log.error(error)
                Service.notifyStaffOfError(#file, "\(#function) \(#line): There was an error removing the users event: \(error.localizedDescription)")
            }
            //Couldn't unwrap event
        } else {
            log.error("Reminder [EKEvent] wasn't intialized properly, therefore failing to unwrap when attempting to switch off")
            Service.notifyStaffOfError(#file, "\(#function) \(#line): Reminder [EKEvent] wasn't intialized properly, therefore failing to unwrap when attempting to switch off")
        }
    }

    /**
        Creates an event reminding the user to log an entry
        at a specified time, repeating over a specified period.
        This function also attaches an alarm to the event, allowing
        the application to prompt them even if the application isn't
        running, or is running in the background.
     
        - Note: The event store should only ever be created once,
                hence it is a field within the application delegate.
    */
    private func createReminder() {
        if let eventStore = appDelegate.eventStore {
            reminder = EKEvent(eventStore: eventStore)
            //If the reminder was correctly initialized
            if let rm = reminder {
                rm.title = "MPM - Time to Log an entry!"
                rm.calendar = appDelegate.eventStore!.defaultCalendarForNewEvents
                //Convert from AM/PM time to 24 hour time
                let dateF = DateFormatter()
                dateF.dateFormat = "h:mm a"
                let date = dateF.date(from: time)
                dateF.dateFormat = "HH:mm"
                let time24Hr = dateF.string(from: date!)
                //Split into hour time components
                let time24HrParts = time24Hr.split(separator: ":").map({ String($0) })
                let hour = time24HrParts[0]
                let min = time24HrParts[1]
                let currDate = Date()
                rm.startDate = DateComponents(calendar: Calendar.current, timeZone: TimeZone.current, era: nil, year: currDate.year, month: currDate.month, day: currDate.day, hour: Int(hour), minute: Int(min), second: 0, nanosecond: 0, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil).date
                if let startDate = rm.startDate {
                    rm.endDate = startDate.add(TimeChunk(seconds: 0, minutes: 5, hours: 0, days: 0, weeks: 0, months: 0, years: 0))
                    var rule: EKRecurrenceRule?
                    switch period {
                    case "Daily":
                        rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.daily, interval: 1, end: nil)
                    case "Weekly":
                        rule = EKRecurrenceRule(recurrenceWith: EKRecurrenceFrequency.weekly, interval: 1, end: nil)
                    default:
                        return
                    }
                    if let setRule = rule {
                        rm.addRecurrenceRule(setRule)
                        //Set alarm one minute earlier (offset must be negative)
                        let alarm = EKAlarm(relativeOffset: 60.0 * -1.0)
                        rm.addAlarm(alarm)
                        do {
                            try eventStore.save(rm, span: EKSpan.thisEvent, commit: true)
                        } catch let error {
                            log.error(error)
                            Service.notifyStaffOfError(#file, "\(#function) \(#line): There was an error saving the users event: \(error.localizedDescription)")
                        }
                    }
                }
                //Couldn't uwnrap reminder
            } else {
                log.error("Reminder [EKEvent] wasn't intialized properly")
                Service.notifyStaffOfError(#file, "\(#function) \(#line): Reminder [EKEvent] wasn't intialized properly")
            }
            //Couldn't unwrap event store
        } else {
            log.error("Event store wasn't intialized properly")
            Service.notifyStaffOfError(#file, "\(#function) \(#line): Event store wasn't intialized properly")
        }
    }
}

/**
    This extension handles all of the delegate tasks that the
    view controller needs to be notified of, for example, setting
    the period and time, and responding to the enabling of notifications
    or disabiling of notifications.
*/
extension NotificationsController: EnableButtonCellDelegate, PeriodEntryCellDelegate, TimeEntryCellDelegate {


    /**
        Called when the enabled button is enabled/disabled. This then
        triggers the process of creating a reminder (first intializing
        the users event store if one does not exist).
     
        - Note: the user will have to grant permission for notifications
                to be enabled.
    */
    internal func buttonActivated(_ button: UISwitch) {
        if button.isOn {
            if appDelegate.eventStore == nil {
                appDelegate.eventStore = EKEventStore()
                appDelegate.eventStore?.requestAccess(to: EKEntityType.event, completion:
                        { (granted, error) in
                            //If an error ocurred, log, notify and then exit
                            if let err = error {
                                Service.showAlert(on: self, style: .alert, title: "Whoops", message: "An error ocurred when requesting access to user permissions. Please try again later.")
                                self.log.error(err)
                                Service.notifyStaffOfError(#file, "\(#function) \(#line): There was an error requesting access to the users event store: \(err.localizedDescription)")
                                return
                            }
                            if !granted {
                                /**
                                    If user hasn't granted permissions, dont enable notifications.
                                    The user will only be prompted once to enable permissions, if they
                                    deny permissions initially they have to go into settings and enable
                                    them manually.
                                 */
                                DispatchQueue.main.sync {
                                    Service.showAlert(on: self, style: .alert, title: "Whoops", message: "We cannot enable notifications without permission! If you chang your mind, you can enable access in Settings -> MyPainManager.")
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
                self.createReminder()
            }
            //User disabled notifications
        } else {
            turnOffReminders()
        }
    }

    /**
        Called when the period cell is set.
    */
    internal func textFieldInCell(cell: PeriodEntryCell, editingChangedInTextField newText: String) {
        period = newText
    }

    /**
        Called when the time cell is set.
    */
    internal func textFieldInCell(cell: TimeEntryCell, editingChangedInTextField newText: String) {
        time = newText
    }
}


/**
    This extension handles all of the boiler-plate code
    needed to setup the tableview. It also assigns the table-cells
    delegates so that the view controller can respond to events.
 */
extension NotificationsController: UITableViewDelegate, UITableViewDataSource {
    
    private func setupTableData() {
        self.data = [NotificationCellData.init(message: "Period", value: "Daily"),
                     NotificationCellData.init(message: "Time", value: "12:00 PM"),
                     NotificationCellData.init(message: "EnableNotificaitons", value: "False")]
    }
    
    fileprivate func setUpTable() {
        view.addSubview(NotificationTableView)
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
}

