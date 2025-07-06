import Foundation

struct Template: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var items: [TemplateItem]

    init(id: UUID = UUID(), name: String, items: [TemplateItem]) {
        self.id = id
        self.name = name
        self.items = items
    }
}
