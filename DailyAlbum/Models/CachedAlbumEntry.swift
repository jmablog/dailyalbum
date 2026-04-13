import Foundation

struct CachedAlbumEntry: Codable {
    let fetchedOnDate: String   // "yyyy-MM-dd"
    let album: CurrentAlbum
    let history: [HistoryEntry]
}
