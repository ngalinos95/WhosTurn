import Foundation

public actor WTStorage {
    public static let shared = WTStorage()

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private func fileURL(for key: String) -> URL {
        documentsURL.appendingPathComponent("\(key).json")
    }

    private func save<T: Codable & Sendable>(_ value: T, forKey key: String) throws {
        let data = try encoder.encode(value)
        try data.write(to: fileURL(for: key), options: .atomic)
    }

    private func load<T: Codable & Sendable>(forKey key: String) throws -> T? {
        let url = fileURL(for: key)
        guard FileManager.default.fileExists(atPath: url.path()) else { return nil }
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }

    public func loadTeamMembers() throws -> [TeamMember] {
        try load(forKey: "teamMembers") ?? []
    }

    public func saveTeamMembers(_ members: [TeamMember]) throws {
        try save(members, forKey: "teamMembers")
    }

    public func loadPickRecords() throws -> [PickRecord] {
        try load(forKey: "pickRecords") ?? []
    }

    public func savePickRecords(_ records: [PickRecord]) throws {
        try save(records, forKey: "pickRecords")
    }

    public func clearPickRecords() throws {
        let url = fileURL(for: "pickRecords")
        if FileManager.default.fileExists(atPath: url.path()) {
            try FileManager.default.removeItem(at: url)
        }
    }

    public func loadDailyExclusions() throws -> DailyExclusions {
        let exclusions: DailyExclusions? = try load(forKey: "dailyExclusions")
        guard let exclusions, exclusions.isToday else {
            return DailyExclusions()
        }
        return exclusions
    }

    public func saveDailyExclusions(_ exclusions: DailyExclusions) throws {
        try save(exclusions, forKey: "dailyExclusions")
    }
}
