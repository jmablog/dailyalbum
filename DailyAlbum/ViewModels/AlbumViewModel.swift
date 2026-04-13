import Foundation
import AppKit
import Observation

@Observable
@MainActor
final class AlbumViewModel {

    // MARK: - Persisted State

    var projectSlug: String = UserDefaults.standard.string(forKey: "projectSlug") ?? "" {
        didSet { UserDefaults.standard.set(projectSlug, forKey: "projectSlug") }
    }

    // MARK: - Runtime State

    var currentAlbum: CurrentAlbum?
    var history: [HistoryEntry] = []
    var loadingState: LoadingState = .idle
    var showOnboarding: Bool = false

    // MARK: - Services

    private let apiService = AlbumGeneratorService()
    private let cacheService = AlbumCacheService()

    // MARK: - Enums

    enum LoadingState: Equatable {
        case idle, loading, loaded, error(String)
    }

    // MARK: - Lifecycle

    func onAppear() async {
        guard !projectSlug.trimmingCharacters(in: .whitespaces).isEmpty else {
            showOnboarding = true
            return
        }

        if let cached = cacheService.loadTodaysCached() {
            currentAlbum = cached.album
            history = cached.history
            loadingState = .loaded
            return
        }

        await fetchFromAPI()
    }

    func forceRefresh() async {
        cacheService.clearCache()
        await fetchFromAPI()
    }

    // MARK: - Fetching

    private func fetchFromAPI() async {
        loadingState = .loading
        do {
            let response = try await apiService.fetch(projectSlug: projectSlug)
            if let album = response.currentAlbum {
                currentAlbum = album
                history = response.history
                cacheService.save(album: album, history: response.history)
                loadingState = .loaded
            } else {
                loadingState = .error("No current album found for this project.")
            }
        } catch {
            loadingState = .error(error.localizedDescription)
        }
    }

    // MARK: - Project Slug

    func saveProjectSlug(_ slug: String) async {
        projectSlug = slug.trimmingCharacters(in: .whitespaces)
        showOnboarding = false
        currentAlbum = nil
        history = []
        loadingState = .idle
        await onAppear()
    }

    func refresh() async {
        currentAlbum = nil
        loadingState = .idle
        await onAppear()
    }

    // MARK: - Deep Links

    func openInAppleMusic(album: CurrentAlbum) {
        guard let id = album.appleMusicId,
              let url = URL(string: "https://music.apple.com/album/\(id)") else { return }
        NSWorkspace.shared.open(url)
    }

    func openOn1001Albums(album: CurrentAlbum) {
        guard let urlString = album.globalReviewsUrl,
              let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    func openOnWikipedia(album: CurrentAlbum) {
        let query = "\(album.name) \(album.artist) album"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "https://en.wikipedia.org/wiki/Special:Search?search=\(query)") else { return }
        NSWorkspace.shared.open(url)
    }

    func openRatingPage() {
        let slug = projectSlug.trimmingCharacters(in: .whitespaces)
        guard !slug.isEmpty,
              let url = URL(string: "https://1001albumsgenerator.com/\(slug)") else { return }
        NSWorkspace.shared.open(url)
    }
}
