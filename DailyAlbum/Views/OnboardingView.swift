import SwiftUI

struct OnboardingView: View {
    @Environment(AlbumViewModel.self) private var viewModel
    @State private var slugInput: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 56))
                .foregroundStyle(.pink)

            Text("Welcome to Daily Album")
                .font(.largeTitle)
                .bold()

            Text("Enter your 1001 Albums Generator project slug to get started.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Link("Find your slug at 1001albumsgenerator.com",
                 destination: URL(string: "https://1001albumsgenerator.com")!)
                .font(.callout)

            TextField("your-project-slug", text: $slugInput)
                .textFieldStyle(.roundedBorder)
                .frame(width: 280)

            Button("Continue") {
                Task { await viewModel.saveProjectSlug(slugInput) }
            }
            .disabled(slugInput.trimmingCharacters(in: .whitespaces).isEmpty)
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(width: 420)
    }
}
