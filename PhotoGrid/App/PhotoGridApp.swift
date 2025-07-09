import SwiftUI
import SwiftData

@main
struct PhotoGridApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: FavouritePhoto.self)
    }
}
