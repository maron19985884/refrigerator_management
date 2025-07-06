import SwiftUI

struct DateUtils {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter
    }()

    static func color(for date: Date) -> Color {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if date < today {
            return .red
        } else if calendar.isDateInTomorrow(date) {
            return .orange
        } else {
            return .gray
        }
    }

    static func label(for date: Date) -> String {
        let calendar = Calendar.current
        if date < calendar.startOfDay(for: Date()) {
            return "期限切れ"
        } else if calendar.isDateInToday(date) {
            return "本日まで"
        } else if calendar.isDateInTomorrow(date) {
            return "明日まで"
        } else {
            return "期限: \(dateFormatter.string(from: date))"
        }
    }
}
