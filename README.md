# Tempestas - Simple Weather App

<div align="center">

![Tempestas Logo](https://img.shields.io/badge/Tempestas-Weather-blue)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-16.0+-blue.svg)](https://www.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

*Your weather, beautifully simple.*

</div>

---

## 📱 Overview

Tempestas (Latin for "weather") is a minimalist iOS weather application that provides users with essential weather information for their current location and up to three saved locations. The app leverages Apple's WeatherKit API to deliver accurate, real-time weather data with an emphasis on simplicity, speed, and elegant design.

## ✨ Features

- **Current Location Weather**: Automatic weather detection with detailed current conditions
- **Hourly Forecasts**: See weather changes throughout the day
- **3-Day Forecast**: Plan ahead with daily forecasts
- **Saved Locations**: Save up to 3 favorite locations (plus current location)
- **Smart Caching**: Intelligent data caching to minimize API calls and improve performance
- **Beautiful Design**: Clean, native iOS design with full Dark Mode support
- **Privacy-Focused**: No account required, no data collection
- **Customizable Units**: Choose between °F/°C, mph/km/h, 12/24-hour time

## 🏗️ Architecture

Tempestas follows the **MVVM (Model-View-ViewModel)** architecture pattern with clear separation of concerns:

```
┌─────────────────┐
│     Views       │  ← SwiftUI Views
│  (SwiftUI)      │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   ViewModels    │  ← Business Logic & State Management
│  (@Published)   │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│    Services     │  ← API Integration & Data Management
│                 │
└────────┬────────┘
         │
    ┌────┴────┬───────────┬────────────┐
    ↓         ↓           ↓            ↓
WeatherKit CoreLocation Cache    UserDefaults
```

### Project Structure

```
Tempestas/
├── Models/                     # Data models
│   ├── WeatherLocation.swift   # Location representation
│   ├── CurrentWeather.swift    # Current weather data
│   ├── HourlyForecast.swift    # Hourly forecast data
│   ├── DailyForecast.swift     # Daily forecast data
│   ├── CacheEntry.swift        # Generic cache wrapper
│   └── UserPreferences.swift   # User settings model
│
├── Services/                   # Business logic & API integration
│   ├── WeatherService.swift    # WeatherKit API wrapper
│   ├── LocationService.swift   # CoreLocation management
│   ├── CacheService.swift      # Data caching layer
│   └── StorageService.swift    # UserDefaults persistence
│
├── ViewModels/                 # State management
│   ├── WeatherViewModel.swift  # Main weather logic
│   └── SettingsViewModel.swift # Settings management
│
├── Views/                      # SwiftUI views
│   ├── HomeView.swift          # Main home screen
│   ├── WeatherDetailView.swift # Detailed weather view
│   ├── AddLocationView.swift   # Location search
│   ├── SettingsView.swift      # Settings screen
│   └── Components/             # Reusable UI components
│       ├── CurrentLocationCard.swift
│       ├── SavedLocationCard.swift
│       └── ...
│
├── Extensions/                 # Helper extensions
│   ├── TemperatureFormatter.swift
│   ├── DateFormatter+Extensions.swift
│   └── WindFormatter.swift
│
└── Utilities/                  # Utility classes
```

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+**
- **iOS 16.0+** (WeatherKit requirement)
- **Apple Developer Account** (paid, required for WeatherKit)
- **macOS Ventura or later**

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/Tempestas.git
   cd Tempestas
   ```

2. **Open in Xcode**
   ```bash
   open Tempestas.xcodeproj
   ```

3. **Configure WeatherKit in Apple Developer Portal** ⚠️ **CRITICAL**
   
   WeatherKit requires setup in **TWO places**:
   
   **A. Services → WeatherKit:**
   - Go to https://developer.apple.com/account
   - Click "Certificates, Identifiers & Profiles"
   - Click "Services" (left sidebar)
   - Find "WeatherKit" and configure it for your Bundle ID
   - Accept terms and conditions
   
   **B. Identifiers → Your App ID:**
   - Click "Identifiers" (left sidebar)
   - Click your Bundle ID
   - Check ✅ "WeatherKit" capability
   - Click "Save"
   
   **Both must be enabled or JWT authentication will fail!**
   
   See `WEATHERKIT_SOLUTION_APP_SERVICES.md` for detailed instructions.

4. **Add WeatherKit Capability in Xcode**
   - Select the Tempestas target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "WeatherKit"

5. **Configure Signing**
   - Select your development team
   - Ensure automatic signing is enabled

6. **Build and Run**
   - Select a target device or simulator
   - Press ⌘R to build and run
   - **Note**: WeatherKit works best on a real device with location services

## 🔑 API Usage & Caching

### WeatherKit API
- **Free Tier**: 500,000 calls/month
- **Cost**: $0.50 per 10,000 calls beyond free tier

### Caching Strategy
To minimize API usage, Tempestas implements intelligent caching:

| Data Type | Cache Duration | Rationale |
|-----------|----------------|-----------|
| Current Weather | 10 minutes | Conditions change slowly |
| Hourly Forecast | 1 hour | Hourly data is relatively stable |
| Daily Forecast | 2 hours | Daily forecasts are long-range |

**Expected Usage**: ~40-50 API calls/user/day with 4 locations
**Free tier supports**: ~10,000-12,500 daily active users

## 📐 Key Components

### Models

#### WeatherLocation
```swift
struct WeatherLocation: Identifiable, Codable {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let isCurrentLocation: Bool
}
```

#### CurrentWeather
```swift
struct CurrentWeather: Codable {
    let temperature: Double
    let feelsLike: Double
    let condition: String
    let conditionCode: String
    let highTemp: Double
    let lowTemp: Double
    let humidity: Int
    let windSpeed: Double
    let windDirection: Int
    let uvIndex: Int
    let sunrise: Date
    let sunset: Date
    let lastUpdated: Date
}
```

### Services

#### WeatherService
Manages all WeatherKit API interactions:
- `fetchCurrentWeather(for: WeatherLocation)`
- `fetchHourlyForecast(for: WeatherLocation)`
- `fetchDailyForecast(for: WeatherLocation)`

#### LocationService
Handles location permissions and search:
- `requestLocationPermission()`
- `requestLocation()`
- `searchLocations(query: String)`

#### CacheService
Intelligent data caching with automatic expiration:
- `cache<T>(_ data: T, forKey: String, duration: TimeInterval)`
- `retrieve<T>(forKey: String, as: T.Type)`
- `clearExpiredCache()`

### ViewModels

#### WeatherViewModel
Main view model managing weather data and locations:
- Fetches and caches weather data
- Manages saved locations (add, remove, reorder)
- Handles location permissions
- Provides loading and error states

## 🎨 Design Principles

1. **Minimalist**: Clean, uncluttered interface
2. **Native**: Feels like a natural iOS app
3. **Fast**: Information displayed immediately via caching
4. **Beautiful**: Elegant typography and smooth animations
5. **Accessible**: VoiceOver and Dynamic Type support

### Color Palette

**Light Mode**
- Background: `#FFFFFF`
- Card Background: `#F8F9FA`
- Text Primary: `#1A1A1A`
- Accent: `#007AFF` (iOS Blue)

**Dark Mode**
- Background: `#000000`
- Card Background: `#1C1C1E`
- Text Primary: `#FFFFFF`
- Accent: `#0A84FF`

## 🔒 Privacy & Data

Tempestas is designed with privacy as a core principle:

- ✅ **No account required**
- ✅ **No personal data collected**
- ✅ **Location data never leaves the device** (except for WeatherKit API calls)
- ✅ **All data cached locally only**
- ✅ **No third-party analytics**
- ✅ **No ads**

## 🧪 Testing

### Unit Tests (TODO)
- [ ] Model tests
- [ ] Service tests (WeatherService, CacheService)
- [ ] ViewModel tests

### UI Tests (TODO)
- [ ] Navigation flow tests
- [ ] Location search tests
- [ ] Settings tests

### Manual Testing Checklist
- [ ] Location permission flow
- [ ] Weather data fetching
- [ ] Caching functionality
- [ ] Add/remove/reorder locations
- [ ] Settings changes persist
- [ ] Pull-to-refresh
- [ ] Dark mode
- [ ] VoiceOver support
- [ ] Dynamic Type support

## 📱 Screenshots

*Coming soon*

## 🛣️ Roadmap

### MVP (v1.0) - Current Phase
- [x] Core architecture and scaffolding
- [x] WeatherKit integration
- [x] Location management
- [x] Caching system
- [ ] UI polish and animations
- [ ] Testing and bug fixes
- [ ] App Store submission

### v1.1
- [ ] Apple Watch app
- [ ] Widgets (Home Screen & Lock Screen)
- [ ] Weather notifications
- [ ] Increase saved locations to 10

### v2.0
- [ ] iPad support
- [ ] Weather maps (radar, temperature)
- [ ] Historical weather data
- [ ] Weather alerts

### v2.5
- [ ] Siri integration
- [ ] Shortcuts support
- [ ] Live Activities (Dynamic Island)
- [ ] AI-generated weather summaries

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards
- Follow Swift API Design Guidelines
- Use SwiftLint for code quality
- Write meaningful commit messages
- Add comments for complex logic
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Weather data powered by [Apple WeatherKit](https://weatherkit.apple.com)
- Location services via CoreLocation
- UI built with SwiftUI
- Icons from SF Symbols

## 📞 Contact & Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/Tempestas/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/Tempestas/discussions)
- **Email**: support@example.com

---

<div align="center">

**Built with ❤️ using Swift and SwiftUI**

[Report Bug](https://github.com/yourusername/Tempestas/issues) · [Request Feature](https://github.com/yourusername/Tempestas/issues) · [Documentation](IMPLEMENTATION_GUIDE.md)

</div>
