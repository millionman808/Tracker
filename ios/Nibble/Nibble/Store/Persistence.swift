//
//  Persistence.swift
//  Nibble — Sprout Snacks
//
//  Saves the SaveState as JSON to a file in Application Support. All data stays
//  on-device; nothing is uploaded.
//

import Foundation

enum Persistence {

    private static let filename = "nibble.save.v1.json"

    private static var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory,
                                           in: .userDomainMask).first!
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(filename)
    }

    private static func makeEncoder() -> JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }

    private static func makeDecoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    static func load() -> SaveState? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? makeDecoder().decode(SaveState.self, from: data)
    }

    static func save(_ state: SaveState) {
        guard let data = try? makeEncoder().encode(state) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }

    static func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }

    // MARK: String helpers (export / import)

    static func encodeString(_ state: SaveState) -> String? {
        guard let data = try? makeEncoder().encode(state) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    static func decodeString(_ json: String) -> SaveState? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? makeDecoder().decode(SaveState.self, from: data)
    }
}
