import SwiftUI

struct ContentView: View {
    @Environment(AlbumViewModel.self) private var viewModel

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "calendar") }

            HistoryView()
                .tabItem { Label("History", systemImage: "clock") }
        }
        .frame(minWidth: 480, minHeight: 560)
        .task { await viewModel.onAppear() }
        .sheet(isPresented: Bindable(viewModel).showOnboarding) {
            OnboardingView()
        }
    }
}
