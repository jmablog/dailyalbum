import SwiftUI

struct AlbumDetailView: View {
    let album: CurrentAlbum
    @Environment(AlbumViewModel.self) private var viewModel

    var body: some View {
        VStack(spacing: 24) {
            // Album art
            AsyncImage(url: album.bestImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            } placeholder: {
                Rectangle()
                    .fill(.quaternary)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "music.note")
                            .font(.system(size: 64))
                            .foregroundStyle(.tertiary)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 16, y: 6)

            // Title, artist, year, genres — centred
            VStack(spacing: 16) {
                VStack(spacing: 6) {
                    Text(album.name)
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)

                    Text(album.artist)
                        .font(.title)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                if let year = album.releaseYear {
                    Text(year)
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                if !album.genres.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(album.genres, id: \.self) { genre in
                            Text(genre)
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.quaternary, in: Capsule())
                        }
                    }
                }

                // Action buttons
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Button {
                            viewModel.openRatingPage()
                        } label: {
                            Label("View project page", systemImage: "person.2.fill")
                                .font(.title3)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.large)
                        .interactiveButton()

                        if album.appleMusicId != nil {
                            Button {
                                viewModel.openInAppleMusic(album: album)
                            } label: {
                                Label("Open in Apple Music", systemImage: "play.circle.fill")
                                    .font(.title3)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            .controlSize(.large)
                            .interactiveButton()
                        } else {
                            Label("Not on Apple Music", systemImage: "xmark.circle")
                                .foregroundStyle(.secondary)
                                .font(.title3)
                        }
                    }

                    HStack(spacing: 16) {
                        Button {
                            viewModel.openOnWikipedia(album: album)
                        } label: {
                            Label("View on Wikipedia", systemImage: "book.fill")
                                .font(.title3)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .controlSize(.large)
                        .interactiveButton()

                        if album.globalReviewsUrl != nil {
                            Button {
                                viewModel.openOn1001Albums(album: album)
                            } label: {
                                Label("View on 1001 Albums", systemImage: "link")
                                    .font(.title3)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue)
                            .controlSize(.large)
                            .interactiveButton()
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(24)
        .padding(.bottom, 8)
    }
}

// MARK: - Interactive button modifier

private struct InteractiveButtonModifier: ViewModifier {
    @State private var isHovered = false
    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.94 : isHovered ? 1.04 : 1.0)
            .brightness(isHovered && !isPressed ? 0.08 : 0)
            .animation(.spring(response: 0.15, dampingFraction: 0.65), value: isPressed)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in state = true }
            )
            .onHover { isHovered = $0 }
            .pointerStyle(.link)
    }
}

private extension View {
    func interactiveButton() -> some View {
        modifier(InteractiveButtonModifier())
    }
}
