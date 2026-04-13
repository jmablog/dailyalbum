import Foundation

struct AlbumCacheService {
    private let userDefaultsKey = "cachedAlbumEntry"
    private let dateFormat = "yyyy-MM-dd"

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: Date())
    }

    private var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }

    private var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }

    func loadTodaysCached() -> (album: CurrentAlbum, history: [HistoryEntry])? {
        guard
            let data = UserDefaults.standard.data(forKey: userDefaultsKey),
            let entry = try? decoder.decode(CachedAlbumEntry.self, from: data),
            entry.fetchedOnDate == todayString
        else { return nil }
        return (entry.album, entry.history)
    }

    func save(album: CurrentAlbum, history: [HistoryEntry]) {
        let entry = CachedAlbumEntry(fetchedOnDate: todayString, album: album, history: history)
        if let data = try? encoder.encode(entry) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }

    func clearCache() {
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
