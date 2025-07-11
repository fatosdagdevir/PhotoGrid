# PhotoGrid 📸

A modern iOS photo gallery app built with SwiftUI, featuring a clean architecture, comprehensive testing, and a custom networking layer.

## Features ✨

- **Photo Grid**: Browse photos from Picsum Photos API in a responsive grid layout
- **Photo Details**: View high-resolution photos with full-screen experience
- **Favourites**: Save and manage your favourite photos with local persistence
- **Offline Support**: Graceful handling of network connectivity issues
- **Accessibility**: Full VoiceOver support and accessibility features

## Architecture 🏗️

### Project Structure
```
PhotoGrid/
├── App/                          # App entry point and lifecycle
├── Core/                         # Core application layer
│   ├── Constants/               # App-wide constants
│   ├── Domain/                  # Business logic and models
│   │   ├── DOs/                # Data objects
│   │   ├── FavouritesManager/  # Favourites persistence
│   │   └── PhotoService/       # Photo business logic
│   ├── Navigating/             # Navigation coordination
│   ├── Providers/              # Data providers and DTOs
│   └── Utils/                  # Utilities and helpers
├── Features/                    # Feature modules
│   ├── Photo Grid/             # Photo grid feature
│   │   ├── Views/             # UI components
│   │   ├── ViewModels/        # Presentation logic
│   │   └── Coordinator/       # Navigation
│   ├── Photo Detail/          # Photo detail feature
│   │   ├── Views/            # UI components
│   │   └── ViewModels/       # Presentation logic
│   └── Favourites/           # Favourites feature
│       ├── Views/            # UI components
│       ├── ViewModels/       # Presentation logic
│       └── Coordinator/      # Navigation
├── Shared/                     # Shared components
│   ├── Components/           # Reusable UI components
│   ├── Extensions/           # SwiftUI extensions
│   ├── Mocks/                # Test mocks
│   └── Preview Helpers/      # SwiftUI preview helpers
└── Resources/                 # App resources
    └── Assets.xcassets/      # Images and colors
```

### Architecture
- **MVVMC**: Model-View-ViewModel-Coordinator architecture
- **Clean Architecture**: Separation of concerns with clear layers
- **Protocol-Oriented Design**: Dependency injection and testability
- **Repository Pattern**: Data access abstraction - PhotoProvider

### Clean Architecture Layers
- **Presentation Layer**: Views, ViewModels, and Coordinators
- **Domain Layer**: Business logic, entities, and services
- **Data Layer**: Providers, data sources, and external APIs

## Networking 🌐

### Custom Networking Package
The app includes a custom Swift Package for networking:

```
Networking/
├── Sources/Networking/
│   ├── Network.swift          # Core networking implementation
│   ├── NetworkError.swift     # Error handling
│   ├── RequestProtocol.swift  # Request abstraction
│   ├── EndpointProtocol.swift # Endpoint definition
│   ├── HTTP.swift            # HTTP utilities
│   ├── URLRequest.swift      # URLRequest extensions
│   └── URL+Endpoint.swift    # URL construction
└── Tests/NetworkingTests/     # Unit tests
```

### Features
- **Protocol-oriented**: Easy mocking and testing
- **Async/await**: Modern Swift concurrency
- **Type-safe**: Compile-time request/response safety
- **Error handling**: Comprehensive error management
- **Customizable**: Configurable timeouts and encoders

## Testing 🧪

### Test Coverage
- **Unit Tests**: Comprehensive business logic testing
- **Mock Objects**: Isolated testing with protocol mocks

### Test Structure
```
PhotoGridTests/
├── Core/                      # Core layer tests
│   ├── Domain/               # Business logic tests
│   ├── Navigation/           # Navigation tests
│   └── Providers/            # Data provider tests
└── Features/                 # Feature tests
    ├── Photo Grid/           # Photo grid tests
    ├── Photo Detail/         # Photo detail tests
    └── Favourites/           # Favourites tests
```

## Requirements 📋

- **iOS**: 17.6+
- **Xcode**: 15.0+
- **Swift**: 6.0+
- **SwiftUI**: Latest
- **SwiftData**: For local persistence

## Installation 🚀

### Prerequisites
1. Install Xcode 15.0 or later
2. Ensure you have iOS 17.6+ simulator or device

### Setup
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd PhotoGrid
   ```

2. Open the project in Xcode:
   ```bash
   open PhotoGrid.xcodeproj
   ```

3. Build and run:
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

### Dependencies
- **Networking**: Custom Swift Package (included)
- **SwiftData**: Built-in iOS framework
- **SwiftUI**: Built-in iOS framework

## Usage 📱

### Photo Grid
- Browse photos in a responsive grid layout
- Tap any photo to view details
- Photos are automatically cached for performance
- Pull to refresh for new photos

### Photo Details
- Full-screen photo viewing
- Tap heart icon to add/remove from favourites
- Tap X to dismiss and return to grid

### Favourites
- View all your saved photos
- Swipe left to remove from favourites
- Tap any photo to view details
- Persistent storage with SwiftData

## Development 🛠️

### Running Tests
```bash
# Run all tests
xcodebuild test -scheme PhotoGrid -destination 'platform=iOS Simulator,name=iPhone 16'

# Run specific test target
xcodebuild test -scheme PhotoGrid -only-testing:PhotoGridTests
```


### Key Components

#### Presentation Layer
- **PhotoGridCoordinator**: Navigation and flow coordination
- **PhotoGridViewModel**: Presentation logic and state management
- **PhotoDetailViewModel**: Detail view presentation logic
- **FavouritesViewModel**: Favourites presentation logic

#### Domain Layer
- **PhotoService**: Business logic for photo operations
- **FavouritesManager**: Domain logic and persistence for favourites management
- **Photo**: Core domain entities

#### Data Layer
- **PhotoProvider**: Data access and API integration
- **DTOs**: Data transfer objects for API communication

## API Integration 🔌

### Picsum Photos API
- **Base URL**: `https://picsum.photos/v2`
- **Endpoint**: `/list`
- **Parameters**: `limit=100`
- **Response**: Array of photo objects

### Photo Object Structure
```swift
struct Photo: Identifiable, Hashable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let url: String
    let downloadUrl: String
    
    var smallImageURL: URL?    // 300px width
    var bigImageURL: URL?      // 1500px width
}
```

## Performance 🚀

### Optimizations
- **Lazy Loading**: Images loaded on-demand
- **Caching**: Network and image caching
- **Memory Management**: Efficient image handling
- **Background Processing**: Non-blocking operations

### Image Loading
- **NetworkImageView**: Custom image loading component
- **Placeholder**: Loading states and error handling
- **Caching**: NSCache-based image caching
- **Cancellation**: Proper task cancellation

## Accessibility ♿

### Features
- **VoiceOver**: Complete screen reader support
- **Dynamic Type**: Scalable text sizes
- **High Contrast**: Enhanced visibility
- **Reduced Motion**: Respects user preferences

### Implementation
- **Accessibility Labels**: Descriptive text for UI elements
- **Accessibility Hints**: Action guidance
- **Accessibility Traits**: Proper element classification
- **Semantic Views**: Meaningful view hierarchy

## Error Handling ⚠️

### Network Errors
- **Offline Detection**: Automatic offline state handling
- **Retry Logic**: Automatic retry with exponential backoff
- **User Feedback**: Clear error messages and actions
- **Graceful Degradation**: App remains functional

### Error Types
- **NetworkError**: Comprehensive network error handling
- **DecodingError**: JSON parsing error management
- **ValidationError**: Data validation errors
- **PersistenceError**: Local storage errors

## Future Improvements 🚀
- **Architecture Review**: Evaluate MVVM-C adaptation for SwiftUI - navigation is tightly coupled with views in SwiftUI, requiring careful consideration of coordinator pattern implementation and potential alternatives like NavigationStack-based routing
- **Networking Package Unit Tests**: Add comprehensive unit tests for the Networking package to ensure all network operations, error handling, and request/response parsing work correctly
- **Image Caching Improvements**: Current implementation uses basic NSCache - needs enhancement with disk caching, cache size management, automatic cleanup, cache warming strategies, and intelligent prefetching for better performance and offline support
- **Logging**: Implement comprehensive logging system with different log levels, structured logging, and integration with crash reporting tools for better debugging and monitoring
- **Modular Architecture**: Break down into separate Swift Packages
- **Dependency Injection**: Implement a proper DI container
- **Analytics**: User behavior tracking and crash reporting
- **Localization**: Multi-language support