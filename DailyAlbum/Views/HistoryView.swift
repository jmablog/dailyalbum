import SwiftUI

struct HistoryView: View {
    @Environment(AlbumViewModel.self) private var viewModel

    private var sortedHistory: [HistoryEntry] {
        viewModel.history.sorted {
            ($0.generatedAt ?? "") > ($1.generatedAt ?? "")
        }
    }

    var body: some View {
        Group {
            if viewModel.history.isEmpty && viewModel.loadingState == .loaded {
                VStack(spacing: 12) {
                    Image(systemName: "clock")
                        .font(.system(size: 40))
                        .foregroundStyle(.tertiary)
                    Text("No history yet")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    Text("Albums you've been recommended will appear here.")
                        .font(.callout)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else if viewModel.history.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(sortedHistory) { entry in
                    HistoryAlbumRow(entry: entry)
                        .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                }
                .listStyle(.plain)
            }
        }
        .frame(minWidth: 480)
    }
}
