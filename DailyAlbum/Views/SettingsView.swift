import SwiftUI

struct SettingsView: View {
    @Environment(AlbumViewModel.self) private var viewModel
    @State private var slugInput: String = ""

    var body: some View {
        Form {
            Section("Project") {
                TextField("Project Slug", text: $slugInput)
                Text("Your 1001 Albums Generator project identifier (from your profile URL)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("Save") {
                    Task { await viewModel.saveProjectSlug(slugInput) }
                }
                .disabled(slugInput.trimmingCharacters(in: .whitespaces).isEmpty ||
                          slugInput == viewModel.projectSlug)
            }

            Section("Cache") {
                Button("Refresh Album Now") {
                    Task { await viewModel.forceRefresh() }
                }
                Text("Forces a fresh fetch from 1001 Albums Generator, ignoring today's cache.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 380, height: 240)
        .onAppear { slugInput = viewModel.projectSlug }
    }
}
