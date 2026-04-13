import Foundation

struct AlbumGeneratorResponse: Decodable {
    let currentAlbum: CurrentAlbum?
    let history: [HistoryEntry]
}

struct CurrentAlbum: Codable {
    let name: String
    let artist: String
    let appleMusicId: String?
    let images: [AlbumImage]
    let genres: [String]
    let releaseDate: String?
    let globalReviewsUrl: String?
    let slug: String?

    var bestImageURL: URL? {
        images.sorted { $0.width > $1.width }.first.flatMap { URL(string: $0.url) }
    }

    var releaseYear: String? {
        releaseDate.map { String($0.prefix(4)) }
    }
}

struct AlbumImage: Codable {
    let url: String
    let width: Int
    let height: Int
}

struct HistoryEntry: Codable, Identifiable {
    let generatedAlbumId: String
    let album: CurrentAlbum
    let rating: AlbumRating?
    let review: String?
    let generatedAt: String?

    var id: String { generatedAlbumId }
}

enum AlbumRating: Codable {
    case score(Int)
    case didNotListen

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self = .score(int)
        } else if let str = try? container.decode(String.self), str == "did-not-listen" {
            self = .didNotListen
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unknown rating format")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .score(let n): try container.encode(n)
        case .didNotListen: try container.encode("did-not-listen")
        }
    }
}
