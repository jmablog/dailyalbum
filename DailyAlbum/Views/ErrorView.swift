import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () async -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Try Again") {
                Task { await retryAction() }
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: 320)
    }
}
