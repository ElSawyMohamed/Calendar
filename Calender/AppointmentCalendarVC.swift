// 
//  AppointmentCalendarVC.swift
//  Glamera Business
//
//  Created by Mahmoud Farag on 26/11/2023.
//  Copyright © 2023 Smart Zone. All rights reserved.
//

import UIKit
import FSCalendar

protocol AppointmentCalendarProtocol: AnyObject{
    func didApplyDateRange()
    func getSelectedDateForWebView(date: Date?)
}

protocol AppointmentCalendarProtocolsView {
    func didApplyDateRange()
}

class AppointmentCalendarVC: UIViewController {
    
    //    MARK: Outlets -
    @IBOutlet weak var dismissView:UIView!
    @IBOutlet weak var calendarView: FSCalendar!{
        didSet{
            self.calendarView.delegate = self
            self.calendarView.dataSource = self
        }
    }
    @IBOutlet weak var clearBtn: UIButton!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    private lazy var today: Date = {
        return Date()
    }()
    
    private var currentPage: Date?
    private var firstDate: Date?
    private var lastDate: Date?
    private var datesRange: [Date]?
    private var selectedDate: Date?
    weak var delegate: AppointmentCalendarProtocol?

    private var calendar: FSCalendar?
 
    
    //    MARK: Life cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        handleInitialDesign()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        clearBtn.isHidden = true
        calendarView.allowsMultipleSelection = false
    }
    
    //    MARK: Design -
    func handleInitialDesign(){
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressDismissView)))
    }
    
    //    MARK: Animation -
    func animateViews(){
        
    }
    
    @objc
     func didPressDismissView() {
        self.dismiss(animated: true)
    }
    
    //    MARK: Action -
    @IBAction func nextMonthButtonPressed(_ sender: Any) {
        self.moveCurrentPage(moveUp: true)
    }
        
    @IBAction func previousMonthButtonPressed(_ sender: Any) {
        self.moveCurrentPage(moveUp: false)
    }
    
    @IBAction func clearFilterButtonPressed(_ sender: Any) {
        if let calendar = calendar{
            clearSelectedDate(calendar: calendar)
        }
    }

    @IBAction func applyFilterButtonPressed(_ sender: Any) {
       
            delegate?.getSelectedDateForWebView(date: selectedDate)
            dismiss(animated: true)
    }
    
    func getStringFrom(date: Date?)->String?{
        if let date = date{
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter.string(from: date)
        }
        return nil
   }
}
//    MARK: Extensions -
extension AppointmentCalendarVC: AppointmentCalendarProtocolsView{
    
    func didApplyDateRange(){
        delegate?.didApplyDateRange()
        self.dismiss(animated: true)
    }
}

extension AppointmentCalendarVC: FSCalendarDelegate , FSCalendarDataSource{
    
    private func moveCurrentPage(moveUp: Bool) {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1
        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.calendarView.setCurrentPage(self.currentPage!, animated: true)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            print("did select date \(self.dateFormatter.string(from: date))")
            let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
            print("selected dates is \(selectedDates)")
            if monthPosition == .next || monthPosition == .previous {
                calendar.setCurrentPage(date, animated: true)
            }
            selectedDate = date
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        clearSelectedDate(calendar: calendar)
    }
    
    func datesRange(from: Date, to: Date) -> [Date] {
        if from > to { return [Date]() }
        var tempDate = from
        var array = [tempDate]
        while tempDate < to {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
            array.append(tempDate)
        }
        return array
    }
    
    func clearSelectedDate(calendar: FSCalendar){
        if firstDate != nil && lastDate != nil {
            for d in calendar.selectedDates {
                calendar.deselect(d)
            }
            lastDate = nil
            firstDate = nil
            datesRange = []
            print("datesRange contains: \(datesRange!)")
        }
    }
}



