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
        } else if calendar.isDate(date, equalTo: today, toGranularity: .day) || calendar.isDateInTomorrow(date) {
            return .orange
        } else if isExpiringSoon(date) {
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

    /// 3日以内に期限が来るかを判定
    static func isExpiringSoon(_ date: Date) -> Bool {
        let calendar = Calendar.current
        guard let limit = calendar.date(byAdding: .day, value: 3, to: Date()) else { return false }
        return date <= limit
    }
}
