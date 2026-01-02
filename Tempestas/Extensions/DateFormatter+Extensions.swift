//
//  DateFormatter+Extensions.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import Foundation

extension Date {
    func formatted(timeFormat: TimeFormat) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateFormat = timeFormat == .twelveHour ? "h:mm a" : "HH:mm"
        return formatter.string(from: self)
    }
    
    func dayName() -> String {
        let formatter = DateFormatter()
        
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInTomorrow(self) {
            return "Tomorrow"
        } else {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        }
    }
    
    func relativeTime() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
