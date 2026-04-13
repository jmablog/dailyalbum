import SwiftUI

struct TodayView: View {
    @Environment(AlbumViewModel.self) private var viewModel

    var body: some View {
        ScrollView {
            switch viewModel.loadingState {
            case .idle, .loading:
                ProgressView("Loading today's album…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 80)

            case .error(let message):
                ErrorView(message: message) {
                    await viewModel.onAppear()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)

            case .loaded:
                if let album = viewModel.currentAlbum {
                    AlbumDetailView(album: album)
                        .frame(maxWidth: 520)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(minWidth: 480, maxWidth: 560)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button {
                    Task { await viewModel.refresh() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.loadingState == .loading)
                .pointerStyle(.link)
            }
        }
    }
}
