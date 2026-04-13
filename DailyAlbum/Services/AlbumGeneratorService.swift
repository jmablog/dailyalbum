import Foundation

enum AlbumServiceError: LocalizedError {
    case noProjectSlug
    case noAlbumInResponse
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .noProjectSlug:
            return "No project slug configured. Please set your project slug in Settings."
        case .noAlbumInResponse:
            return "The API returned no current album for this project."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to parse response: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid project slug — could not build a valid URL."
        }
    }
}

struct AlbumGeneratorService {
    private let baseURL = "https://1001albumsgenerator.com/api/v1/projects"

    func fetch(projectSlug: String) async throws -> AlbumGeneratorResponse {
        let trimmed = projectSlug.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { throw AlbumServiceError.noProjectSlug }

        guard let url = URL(string: "\(baseURL)/\(trimmed)") else {
            throw AlbumServiceError.invalidURL
        }

        let data: Data
        do {
            let (responseData, _) = try await URLSession.shared.data(from: url)
            data = responseData
        } catch {
            throw AlbumServiceError.networkError(underlying: error)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response: AlbumGeneratorResponse
        do {
            response = try decoder.decode(AlbumGeneratorResponse.self, from: data)
        } catch {
            throw AlbumServiceError.decodingError(underlying: error)
        }

        guard response.currentAlbum != nil else {
            throw AlbumServiceError.noAlbumInResponse
        }

        return response
    }
}
