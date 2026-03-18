# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Building & Running

This is a native Xcode project with no external package managers (no CocoaPods, no SPM dependencies).

- **Open project:** `open Tempestas.xcodeproj`
- **Build & run:** Use Xcode (⌘R) — requires a physical device or simulator with iOS 16.0+
- **Run tests:** ⌘U in Xcode, or `xcodebuild test -scheme Tempestas -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Run single test:** Use Xcode's test navigator or add `.only` to a `#expect` block in Swift Testing

**Requirements:**
- Xcode 15.0+
- iOS 16.0+ deployment target
- Apple Developer account (paid) — WeatherKit requires a provisioned bundle ID with WeatherKit capability enabled in App Store Connect

## Architecture

MVVM with a unidirectional data flow:

```
Views (SwiftUI) → ViewModels (@Observable/@Published) → Services → External APIs
```

**WeatherViewModel** (`ViewModels/WeatherViewModel.swift`) is the central state manager. It orchestrates location setup via `LocationService`, fetches weather data via `WeatherService`, and persists locations/preferences via `StorageService`. Views receive a single `WeatherViewModel` instance injected at the top level in `TempestasApp`.

**SettingsViewModel** (`ViewModels/SettingsViewModel.swift`) manages user preferences (temperature unit °F/°C, wind speed unit mph/km/h, time format 12h/24h) and persists them via `StorageService`.

## Data Sources

Two external APIs are used:

1. **Apple WeatherKit** — current conditions, hourly forecasts (next 24h), daily forecasts (next 10 days). Requires entitlement in `Tempestas.entitlements` and App Store Connect configuration. Free tier: 500K calls/month.

2. **Open-Meteo Archive API** — historical climate data used in `ClimateView`. Free, no API key required. Fetches both a recent 10-year baseline and a 1980–1999 historical baseline for monthly averages (temperature highs/lows and precipitation).

## Caching

`CacheService` persists data as JSON files in `~/Library/Caches/WeatherCache/`. Cache keys are based on location coordinates. Expiry times:
- Current weather: 10 minutes
- Hourly forecast: 1 hour
- Daily forecast: 2 hours

Climate/historical data from Open-Meteo does not use the cache (it changes rarely).

## Key Conventions

- **Temperature formatting** — always use `TemperatureFormatter` extension, not raw values. It reads `UserPreferences` to apply °F/°C conversion.
- **Wind speed formatting** — use `WindFormatter` extension similarly.
- **Date formatting** — use `DateFormatter+Extensions` for consistent 12h/24h output.
- **Location model** — `WeatherLocation` wraps a `CLLocationCoordinate2D` plus display name. The "current location" is always index 0 in the locations array; saved locations follow.
- **Error handling** — services throw errors that propagate to ViewModels, which set an `errorMessage: String?` property that views display.

## Tests

Tests are scaffolded but not yet implemented. The project uses **Swift Testing** (not XCTest) — test functions use `@Test` and `#expect()`.
