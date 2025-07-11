# PhotoGrid 📸

A modern iOS photo gallery app built with SwiftUI, featuring a clean architecture, comprehensive testing, and a custom networking layer.

## Features ✨

- **Photo Grid**: Browse photos from Picsum Photos API in a responsive grid layout
- **Photo Details**: High-resolution photos with full-screen experience
- **Favourites**: Save and manage your favourite photos with local persistence

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
- **Clean Architecture**: Separation of concerns with clean layers
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
- **Error handling**: Error management

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
- **Xcode**: 16.0+
- **Swift**: 5.0+

## Installation 🚀

### Prerequisites
1. Install Xcode 16.0 or later
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


### Key Components 🛠️

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


## Future Improvements 🚀
- **Architecture Review**: Evaluate MVVM-C adaptation for SwiftUI - navigation is tightly coupled with views in SwiftUI, requiring careful consideration of coordinator pattern implementation and potential alternatives like NavigationStack-based routing
- **Networking Package Unit Tests**: Add comprehensive unit tests for the Networking package to ensure all network operations, error handling, and request/response parsing work correctly
- **Image Caching Improvements**: Current implementation uses basic NSCache - needs enhancement with disk caching, cache size management, automatic cleanup, cache warming strategies, and intelligent prefetching for better performance and offline support
- **Logging**: Implement comprehensive logging system with different log levels, structured logging, and integration with crash reporting tools for better debugging and monitoring
- **Modular Architecture**: Break down into separate Swift Packages
- **Dependency Injection**: Implement a proper DI container
- **Analytics**: User behavior tracking and crash reporting
- **Localization**: Multi-language support
