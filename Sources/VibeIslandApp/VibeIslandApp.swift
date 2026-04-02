import SwiftUI

@main
struct VibeIslandApp: App {
    @State
    private var model = AppModel()

    var body: some Scene {
        WindowGroup("Vibe Island OSS") {
            ControlCenterView(model: model)
                .task {
                    model.startIfNeeded()
                }
        }
        .defaultSize(width: 980, height: 640)

        MenuBarExtra("Vibe Island", systemImage: "circle.hexagongrid.circle.fill") {
            MenuBarContentView(model: model)
        }
        .menuBarExtraStyle(.window)
    }
}
