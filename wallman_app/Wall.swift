import Foundation

struct Wall {
    var screenId: UInt32
    var displayName: String
    var connected: Bool
    var enabled: Bool
    var locked: String? = nil
    var unlocked: String? = nil
}

extension Wall: Decodable, Encodable {
}

extension Wall: Equatable {
}

extension [Wall]: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Wall].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
