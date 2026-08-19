# CoinFlow

### iOS Cryptocurrency Portfolio Tracker

CoinFlow is a native iOS application built with Swift and UIKit. It lets users follow live cryptocurrency markets, explore price charts, save favorite coins, manually record buy and sell transactions, and monitor portfolio performance from a personalized dashboard.

[![Swift](https://img.shields.io/badge/Swift-5-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)](https://developer.apple.com/ios/)
[![UIKit](https://img.shields.io/badge/UI-UIKit-blue.svg)](https://developer.apple.com/documentation/uikit)
[![Architecture](https://img.shields.io/badge/Architecture-MVVM--C-6C63FF.svg)](#architecture)

## Features

- Firebase email/password registration, login, logout, and password reset
- Face ID / Touch ID authentication
- Live cryptocurrency market data from the CoinGecko API
- Pagination, pull-to-refresh, and request-state management
- Debounced cryptocurrency search
- Coin details with selectable historical price ranges
- Favorite coin management
- Manual buy and sell transaction entry
- Portfolio value, invested capital, and profit/loss calculations
- Dashboard with portfolio summary, top holdings, and recent transactions
- Local persistence with Core Data
- Currency and language preferences
- Reusable UI components distributed through Swift Package Manager

## Tech Stack

| Area | Technology |
| --- | --- |
| Language | Swift |
| Interface | UIKit, programmatic UI |
| Architecture | MVVM-C, Clean Architecture |
| Concurrency | Swift Concurrency (async/await, Task) |
| Networking | URLSession, Codable |
| Authentication | Firebase Authentication |
| Persistence | Core Data, UserDefaults |
| Secure storage | Keychain |
| Biometrics | LocalAuthentication |
| Charts | DGCharts |
| Package management | Swift Package Manager |
| Market data | CoinGecko API |
| UI package | [CryptoUI](https://github.com/eceakcay/CryptoUI) |

## Architecture

CoinFlow uses MVVM-C together with Clean Architecture principles. Presentation, business logic, navigation, and data access are separated to improve maintainability and testability. Dependencies are created in a central dependency container.

- **View:** Renders UI and forwards user actions.
- **ViewModel:** Manages presentation state and invokes use cases.
- **Coordinator:** Controls navigation without coupling it to View Controllers.
- **Use Case:** Encapsulates a single business operation.
- **Repository:** Provides an abstraction over remote and local data sources.
- **Dependency Container:** Creates and connects application dependencies.

## Project Structure

```text
CoinFlow/
├── App/
│   ├── AppCoordinator.swift
│   ├── MainTabBarCoordinator.swift
│   └── DependencyContainer.swift
├── Core/
│   ├── Localization/
│   ├── Network/
│   ├── Security/
│   ├── Settings/
│   └── Storage/
├── Modules/
│   ├── Auth/
│   ├── Dashboard/
│   ├── Favorites/
│   ├── Market/
│   ├── Portfolio/
│   └── Profile/
└── Resources/
```

Most feature modules follow this layout:

```text
Feature/
├── Data/
│   ├── DTO
│   ├── Mapper
│   ├── Repository
│   └── Service / Local
├── Domain/
│   ├── Entity
│   ├── Repository
│   └── UseCase
└── Presentation/
    ├── Coordinator
    ├── Model
    ├── View
    └── ViewModel
```

## Data Flow

### Market data

```text
CoinGecko API → APIClient → MarketAPIService
→ MarketRepository → Use Case → ViewModel → View
```

### Portfolio data

Transactions are stored locally with Core Data. The portfolio calculator processes transactions chronologically, builds the remaining position for each asset, and combines those positions with current market prices to calculate invested capital, current value, and profit/loss.

## Getting Started

### Requirements

- macOS with Xcode
- An iOS Simulator or physical iPhone
- A Firebase project with Email/Password authentication enabled
- A CoinGecko Demo API key

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/eceakcay/CoinFlow.git
   cd CoinFlow
   ```

2. Open the project:

   ```bash
   open CoinFlow.xcodeproj
   ```

3. Allow Xcode to resolve the Swift Package Manager dependencies.

4. In Firebase Console, create or select an iOS app, enable **Authentication → Email/Password**, download `GoogleService-Info.plist`, and add it to the `CoinFlow/Resources` group and application target.

5. Create `CoinFlow/Core/Config/APIKeys.swift` and add your CoinGecko key:

   ```swift
   import Foundation

   enum APIKeys {
       static let coinGeckoDemoAPIKey = "YOUR_COINGECKO_DEMO_API_KEY"
   }
   ```

6. Build and run the `CoinFlow` scheme.

> `APIKeys.swift` is ignored by Git and should never be committed.

## Key Implementation Details

- Generic `APIClient.request<T: Decodable>` provides typed networking and centralized error handling.
- Search requests are debounced to reduce unnecessary API traffic.
- Market results are loaded page by page and guarded against duplicate requests.
- Screen states model loading, success, empty, partial-success, and failure scenarios.
- Favorite identifiers and user preferences are stored locally.
- Portfolio transactions are mapped between Core Data entities and Domain models.
- Firebase authentication is wrapped behind repository and use-case abstractions.
- Biometric authentication unlocks an existing authenticated session; Firebase remains the source of authentication state.

## Author

**Ece Akçay**

- GitHub: [@eceakcay](https://github.com/eceakcay)

---

Built with Swift, UIKit, and a focus on modular iOS architecture.
