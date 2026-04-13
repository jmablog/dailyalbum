import SwiftUI

struct HistoryAlbumRow: View {
    let entry: HistoryEntry
    @Environment(AlbumViewModel.self) private var viewModel
    @State private var isExpanded = false

    private var formattedDate: String? {
        guard let dateString = entry.generatedAt else { return nil }
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = isoFormatter.date(from: dateString) else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                // Thumbnail
                AsyncImage(url: entry.album.bestImageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(1, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.quaternary)
                        .overlay {
                            Image(systemName: "music.note")
                                .foregroundStyle(.tertiary)
                        }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 6))

                // Album info
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.album.name)
                        .font(.body)
                        .bold()
                        .lineLimit(1)
                    Text(entry.album.artist)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    HStack(spacing: 8) {
                        if let date = formattedDate {
                            Text(date)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        ratingView
                    }
                }

                Spacer()

                // Action buttons
                HStack(spacing: 6) {
                    if entry.album.appleMusicId != nil {
                        Button {
                            viewModel.openInAppleMusic(album: entry.album)
                        } label: {
                            Image(systemName: "play.circle.fill")
                                .font(.title3)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .controlSize(.large)
                        .pointerStyle(.link)
                        .help("Open in Apple Music")
                    }

                    if entry.album.globalReviewsUrl != nil {
                        Button {
                            viewModel.openOn1001Albums(album: entry.album)
                        } label: {
                            Image(systemName: "link")
                                .font(.title3)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .controlSize(.large)
                        .pointerStyle(.link)
                        .help("Open on 1001 Albums Generator")
                    }
                }
            }

            // Review text
            if let review = entry.review, !review.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text(review)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .lineLimit(isExpanded ? nil : 2)
                    if review.count > 100 {
                        Button(isExpanded ? "Show less" : "Show more") {
                            isExpanded.toggle()
                        }
                        .font(.caption)
                        .buttonStyle(.borderless)
                    }
                }
                .padding(.leading, 68)
            }
        }
        .padding(.vertical, 6)
    }

    @ViewBuilder
    private var ratingView: some View {
        switch entry.rating {
        case .score(let n):
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= n ? "star.fill" : "star")
                        .font(.caption2)
                        .foregroundStyle(i <= n ? AnyShapeStyle(.yellow) : AnyShapeStyle(.tertiary))
                }
            }
        case .didNotListen:
            Text("Did not listen")
                .font(.caption)
                .foregroundStyle(.tertiary)
        case .none:
            EmptyView()
        }
    }
}
