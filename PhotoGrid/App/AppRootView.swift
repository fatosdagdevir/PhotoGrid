import SwiftUI
import SwiftData

struct AppRootView: View {
    // MARK: - Private Properties
    private let dependencyFactory: DependencyFactoryProtocol
    
    // MARK: - Dependencies
    @StateObject private var photoGridNavigator: Navigator
    @StateObject private var favouritesNavigator: Navigator
    @State private var photoService: PhotoServicing
    @State private var favouritesManager: FavouritesManaging
    
    // MARK: - Initialization
    init(dependencyFactory: DependencyFactoryProtocol = DependencyFactory()) {
        self.dependencyFactory = dependencyFactory
        
        let photoGridNav = self.dependencyFactory.makeNavigator() as! Navigator
        let favouritesNav = self.dependencyFactory.makeNavigator() as! Navigator
        
        self._photoGridNavigator = StateObject(wrappedValue: photoGridNav)
        self._favouritesNavigator = StateObject(wrappedValue: favouritesNav)
        self._photoService = State(wrappedValue: self.dependencyFactory.makePhotoService())
        self._favouritesManager = State(wrappedValue: self.dependencyFactory.makeFavouritesManager())
    }
    
    var body: some View {
        TabView {
            NavigationStack(path: $photoGridNavigator.path) {
                PhotoGridCoordinator(
                    navigator: photoGridNavigator,
                    photoService: photoService,
                    favouritesManager: favouritesManager
                )
            }
            .tabItem {
                Image(systemName: "photo.on.rectangle.angled")
                Text("Photo Grid")
            }
            
            NavigationStack(path: $favouritesNavigator.path) {
                FavouritesCoordinator(
                    navigator: favouritesNavigator,
                    photoService: photoService,
                    favouritesManager: favouritesManager
                )
            }
            .tabItem {
                Image(systemName: "heart.fill")
                Text("Favourites")
            }
        }
    }
}
