//
//  ViewController.swift
//  Calender
//
//  Created by mac on 22/01/1446 AH.
//

import UIKit
import KVKCalendar
import EventKit

class ViewController: UIViewController, KVKCalendarDataModel, KVKCalendarSettings {
    
    @IBOutlet weak var empolyessCollectionView: UICollectionView!
    @IBOutlet weak var dateLbL: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    private var employeesWorkingHours: [WorkingHoursData] = []
    
    private lazy var calenderView: KVKCalendarView = {
        var frame = containerView.bounds
        frame.origin.y = 0
        let calendar = KVKCalendarView(frame: frame, date: selectDate, style: style)
        calendar.delegate = self
        calendar.dataSource = self
        return calendar
    }()
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var events = [Event]() {
        didSet {
            calenderView.reloadData()
        }
    }
    var selectDate: Date = Date() {
        didSet {
            let dateString = self.dateFormatter.string(from: selectDate)
            self.dateLbL.text = Formatter.formatDate(dateString: dateString, inputFormat: "yyyy-MM-dd", outputFormat: "EEEE,dd MMM yyyy")
            
        }
    }
    
    
    var style: Style {
        createCalendarStyle()
    }
    var eventViewer = EventViewer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setUpCollectionView()
    }
    
    private func setUpCollectionView() {
        empolyessCollectionView.register(UINib(nibName: "EmployeeCelll", bundle: nil), forCellWithReuseIdentifier: "EmployeeCelll")
        empolyessCollectionView.delegate = self
        empolyessCollectionView.dataSource = self
    }
    
    private func setUpView() {
        selectDate = defaultDate
        containerView.addSubview(calenderView)
        guard let ddd = dateFormatter.date(from: "2024-7-24") else {return}
        getAppointments(date:ddd )
        getWorkingHours(date: ddd)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        var frame = containerView.bounds
        frame.origin.y = 0
        calenderView.reloadFrame(frame)
    }
    
    @IBAction func selectDate(_ sender: Any) {
        let vc: AppointmentCalendarVC = AppointmentCalendarVC.loadFromNib()
        vc.delegate = self
        vc.modalPresentationStyle = .overFullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    
    
}

extension ViewController: CalendarDelegate {
    func didChangeEvent(_ event: Event, start: Date?, end: Date?) {
        if let result = handleChangingEvent(event, start: start, end: end) {
            events.replaceSubrange(result.range, with: result.events)
        }
    }
    
    func didSelectEvent(_ event: Event, type: CalendarType, frame: CGRect?) {
        print(type, event)
        switch type {
        case .day:
            eventViewer.text = event.title.timeline
        default:
            break
        }
    }
    
    func didDeselectEvent(_ event: Event, animated: Bool) {
        print(event)
    }
    
    func didSelectMore(_ date: Date, frame: CGRect?) {
        print(date)
    }
    
    func didChangeViewerFrame(_ frame: CGRect) {
        eventViewer.reloadFrame(frame: frame)
    }
    
    func didAddNewEvent(_ event: Event, _ date: Date?) {
        if let newEvent = handleNewEvent(event, date: date) {
            events.append(newEvent)
        }
    }
}

// MARK: - Calendar datasource

extension ViewController: CalendarDataSource {
    
    func willSelectDate(_ date: Date, type: CalendarType) {
        print(date, type)
    }
    
    @available(iOS 14.0, *)
    func willDisplayEventOptionMenu(_ event: Event, type: CalendarType) -> (menu: UIMenu, customButton: UIButton?)? {
        handleOptionMenu(type: type)
    }
    
    func eventsForCalendar(systemEvents: [EKEvent]) -> [Event] {
        // if you want to get a system events, you need to set style.systemCalendars = ["test"]
        handleEvents(systemEvents: systemEvents)
    }
    
}

extension ViewController: AppointmentCalendarProtocol {
    func didApplyDateRange() {
        print("")
    }
    
    func getSelectedDateForWebView(date: Date?) {
        guard let date = date else {return}
        selectDate = date
        events = []
        getAppointments(date: date)
        getWorkingHours(date: date)
    }
    
}

extension ViewController {
    
    private func getWorkingHours(date: Date) {
        let stringDate = dateFormatter.string(from: selectDate)
        APIService.shared.fetchData(url: "https://api-dev.glamera.com/api/v5/web/appointments/calendar/employees?workingHoursDate=\(stringDate)", type: WorkingHourResponse.self) { result in
            switch result {
            case .success(let response):
                self.employeesWorkingHours = response.data ?? []
                DispatchQueue.main.async {
                    self.empolyessCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getBranchDetails(date: Date) {
        let stringDate = dateFormatter.string(from: selectDate)
        APIService.shared.fetchData(url: "https://api-dev.glamera.com/api/v5/web/appointments/calendar/branch/working-hours?date=\(stringDate)", type: BranchDetails.self) { result in
            switch result {
            case .success(let response):
                print(response)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func getAppointments(date: Date) {
        let stringDate = dateFormatter.string(from: selectDate)
        let resquest = AppointmentRequest(dateFrom: stringDate, dateTo: stringDate)
        APIService.shared.fetchData(url: "https://api-dev.glamera.com/api/v5/web/appointments/calendar", type: AppointmentResponse.self,parameters: resquest, method: "POST") { result in
            switch result {
            case .success(let response):
                self.didGetAppointment(appointments: response.data)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func didGetAppointment(appointments: [AppointmentResponseData]?) {
        guard let appointments = appointments else {return}
        let events = appointments.compactMap { (appointment) -> Event? in
            guard let startTime = getTime(time: appointment.date), let endTime = getTime(time: appointment.date) else {return nil}
            
            var event = Event(ID: String(appointment.transactionId ?? 0))
            event.start = startTime
            event.end = endTime
            event.title = TextEvent(timeline: "\(appointment.clientName ?? "")",
                                    month: "",
                                    list: "")
            event.color = Event.Color(.brown)
            var customeStyle = style.event
            event.recurringType = .everyDay
            customeStyle.defaultHeight = 40
            customeStyle.defaultWidth = 100
            event.style = customeStyle
            return  event
        }
        
        self.events = events
        
    }
    
    private func getTime(time: String?) -> Date? {
        guard let time = time else {return nil}
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        guard let date = dateFormatter.date(from: time) else {
            return nil
        }
        return date
        
    }
}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        employeesWorkingHours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmployeeCelll", for: indexPath) as! EmployeeCelll
        cell.setUpCell(employee: employeesWorkingHours[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 100, height: collectionView.bounds.height)
    }
    
}
