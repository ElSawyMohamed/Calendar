//
//  KVKCalendarSettings.swift
//  KVKCalendar_Example
//
//  Created by Sergei Kviatkovskii on 5/1/22.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Foundation
import KVKCalendar
import EventKit

protocol KVKCalendarDataModel {
    
    var events: [Event] { get set }
    var style: Style { get }
    
}

protocol KVKCalendarSettings {}

extension KVKCalendarSettings where Self: KVKCalendarDataModel {
    
    func handleChangingEvent(_ event: Event, start: Date?, end: Date?) -> (range: Range<Int>, events: [Event])? {
        var eventTemp = event
        guard let startTemp = start, let endTemp = end else { return nil }
        
        let startTime = timeFormatter(date: startTemp, format: style.timeSystem.format, local: style.locale)
        let endTime = timeFormatter(date: endTemp, format: style.timeSystem.format, local: style.locale)
        eventTemp.start = startTemp
        eventTemp.end = endTemp
        eventTemp.title = TextEvent(timeline: "\(startTime) - \(endTime)\n new time",
                                    month: "\(startTime) - \(endTime)\n new time",
                                    list: "\(startTime) - \(endTime)\n new time")
        
        if let idx = events.firstIndex(where: { $0.compare(eventTemp) }) {
           return (idx..<idx + 1, [eventTemp])
        } else {
            return nil
        }
    }
    
    func handleNewEvent(_ event: Event, date: Date?) -> Event? {
        var newEvent = event
        
        guard let start = date,
              let end = Calendar.current.date(byAdding: .minute, value: 30, to: start) else { return nil }
        
        let startTime = timeFormatter(date: start, format: style.timeSystem.format, local: style.locale)
        let endTime = timeFormatter(date: end, format: style.timeSystem.format, local: style.locale)
        newEvent.start = start
        newEvent.end = end
        newEvent.ID = "\(events.count + 1)"
        newEvent.title = TextEvent(timeline: "\(startTime) - \(endTime)\n new time",
                                   month: "\(startTime) - \(endTime)\n new time",
                                   list: "\(startTime) - \(endTime)\n new time")
        return newEvent
    }
    
    func handleEvents(systemEvents: [EKEvent]) -> [Event] {
        // if you want to get a system events, you need to set style.systemCalendars = ["test"]
        let mappedEvents = systemEvents.compactMap { (event) -> Event in
            let startTime = timeFormatter(date: event.startDate, format: style.timeSystem.format, local: style.locale)
            let endTime = timeFormatter(date: event.endDate, format: style.timeSystem.format, local: style.locale)
            event.title = "\(startTime) - \(endTime)\n\(event.title ?? "")"
            
            return Event(event: event)
        }
        
        return events + mappedEvents
    }
    
    func loadEvents(dateFormat: String, completion: ([Event]) -> Void) {
        let decoder = JSONDecoder()
        
        guard let path = Bundle.main.path(forResource: "events", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe),
              let result = try? decoder.decode(ItemData.self, from: data) else { return }
        
        let events = result.data.compactMap({ (item) -> Event in
            let startDate = formatter(date: item.start, local: style.locale)
            let endDate = formatter(date: item.end, local: style.locale)
            let startTime = timeFormatter(date: startDate, format: dateFormat, local: style.locale)
            let endTime = timeFormatter(date: endDate, format: dateFormat, local: style.locale)

            var event = Event(ID: item.id)
            event.start = startDate
            event.end = endDate
            event.color = Event.Color(item.color)
            event.isAllDay = item.allDay
            event.isContainsFile = !item.files.isEmpty
            
            if item.allDay {
                event.title = TextEvent(timeline: " \(item.title)",
                                        month: "\(item.title) \(startTime)",
                                        list: item.title)
            } else {
                event.title = TextEvent(timeline: "\(startTime) - \(endTime)\n\(item.title)",
                                        month: "\(item.title) \(startTime)",
                                        list: "\(startTime) - \(endTime) \(item.title)")
            }
            var customeStyle = style.event
            if item.id == "14" {
                event.recurringType = .everyMonth
                customeStyle.defaultHeight = 40
                customeStyle.defaultWidth = 100
                event.style = customeStyle
            } else if item.id == "40" {
                event.recurringType = .everyYear
            } else if item.id == "1400" {
                var customeStyle = style.event
                customeStyle.defaultWidth = 100
                event.style = customeStyle
            }
            return event
        })
        completion(events)
    }
    
}

extension KVKCalendarSettings {
    
    var defaultDate: Date {
        Date()
    }
    
    var onlyDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter
    }
    
    func handleCustomEventView(event: Event, style: Style, frame: CGRect) -> EventViewGeneral? {
        switch event.ID {
        case "2":
            return CustomViewEvent(style: style, event: event, frame: frame)
        case "1400":
            return BlockViewEvent(style: style, event: event, frame: frame)
        default:
            return nil
        }
    }
    
    func handleOptionMenu(type: CalendarType) -> (menu: UIMenu, customButton: UIButton?)? {
        guard type == .day else { return nil }
        
        let action = UIAction(title: "Delete", attributes: .destructive) { _ in
            print("test tap")
        }
        
        return (UIMenu(title: "Options", children: [action]), nil)
    }
    
    
    func createCalendarStyle() -> Style {
        var style = Style()
        style.startWeekDay = .sunday
        style.systemCalendars = ["Calendar1", "Calendar2", "Calendar3"]
        style.event.iconFile = UIImage(systemName: "paperclip")
        style.timeline.scrollLineHourMode = .onlyOnInitForDate(defaultDate)
        style.timeline.showLineHourMode = .never
        style.timeline.scrollDirections = [.vertical]
        style.timeline.heightTime = 100
        style.headerScroll.isHidden = true
        return style
    }

    func timeFormatter(date: Date, format: String, local: Locale) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = local
        return formatter.string(from: date)
    }
    
    func formatter(date: String, local: Locale) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.locale = local
        return formatter.date(from: date) ?? Date()
    }
    
}

final class CustomViewEvent: EventViewGeneral {
    override init(style: Style, event: Event, frame: CGRect) {
        super.init(style: style, event: event, frame: frame)
        
        let imageView = UIImageView(image: UIImage(named: "ic_stub"))
        imageView.frame = CGRect(origin: CGPoint(x: 3, y: 1), size: CGSize(width: frame.width - 6, height: frame.height - 2))
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

final class BlockViewEvent: EventViewGeneral {
    override init(style: Style, event: Event, frame: CGRect) {
        var updatedStyle = style
        updatedStyle.event.states = []
        super.init(style: updatedStyle, event: event, frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = event.color?.value
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
    }
}



