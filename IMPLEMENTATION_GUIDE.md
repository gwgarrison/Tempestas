# Tempestas - Implementation Guide

## Overview
This scaffolding implements the architecture for the Tempestas weather app based on the PRD and wireframes. The app uses MVVM architecture with SwiftUI.

## Project Structure

```
Tempestas/
├── Models/                     # Data models
│   ├── WeatherLocation.swift   # Location model
│   ├── CurrentWeather.swift    # Current weather data
│   ├── HourlyForecast.swift    # Hourly forecast data
│   ├── DailyForecast.swift     # Daily forecast data
│   ├── CacheEntry.swift        # Generic cache wrapper
│   └── UserPreferences.swift   # User settings model
│
├── Services/                   # Business logic layer
│   ├── WeatherService.swift    # WeatherKit API integration
│   ├── LocationService.swift   # CoreLocation wrapper
│   ├── CacheService.swift      # Data caching
│   └── StorageService.swift    # UserDefaults wrapper
│
├── ViewModels/                 # View state management
│   ├── WeatherViewModel.swift  # Main weather logic
│   └── SettingsViewModel.swift # Settings logic
│
├── Views/                      # SwiftUI views
│   ├── HomeView.swift          # Main home screen
│   ├── CurrentLocationCard.swift
│   ├── SavedLocationCard.swift
│   ├── WeatherDetailView.swift # Detailed weather view
│   ├── AddLocationView.swift   # Location search
│   └── SettingsView.swift      # Settings screen
│
├── Extensions/                 # Helper extensions
│   ├── TemperatureFormatter.swift
│   ├── DateFormatter+Extensions.swift
│   └── WindFormatter.swift
│
└── Utilities/                  # Utility classes
```

## Key Features Implemented

### 1. Data Models (✅ Complete)
- `WeatherLocation`: Location representation with coordinates
- `CurrentWeather`: Current weather conditions
- `HourlyForecast`: Hourly forecast data
- `DailyForecast`: Daily forecast data
- `CacheEntry`: Generic caching wrapper
- `UserPreferences`: User settings (units, formats)

### 2. Services (✅ Complete)
- **WeatherService**: Integrates with WeatherKit API
  - Fetch current weather
  - Fetch hourly forecast
  - Fetch daily forecast
  
- **LocationService**: Manages location permissions and search
  - Request location permission
  - Get current location
  - Search locations via MapKit
  
- **CacheService**: Intelligent data caching
  - 10-minute cache for current weather
  - 1-hour cache for hourly forecast
  - 2-hour cache for daily forecast
  - Automatic expiration handling
  
- **StorageService**: Persistent data storage
  - Save/load saved locations
  - Save/load user preferences

### 3. ViewModels (✅ Complete)
- **WeatherViewModel**: 
  - Manages weather data fetching
  - Handles location management
  - Integrates caching logic
  
- **SettingsViewModel**:
  - Manages user preferences
  - Persists settings changes

### 4. Views (✅ Complete)
- **HomeView**: Main screen with current location and saved locations
- **WeatherDetailView**: Full weather details with hourly/daily forecasts
- **AddLocationView**: Search and add new locations
- **SettingsView**: User preferences configuration
- Various card components for displaying weather data

### 5. Extensions (✅ Complete)
- Temperature conversion and formatting
- Date/time formatting
- Wind speed conversion and direction formatting

## Next Steps for Development

### Phase 1: Setup & Configuration (Week 1)
1. ✅ Project scaffolding created
2. ⚠️ **Add WeatherKit capability** in Xcode:
   - Open project settings
   - Select Tempestas target
   - Go to "Signing & Capabilities"
   - Click "+ Capability"
   - Add "WeatherKit"
   
3. ⚠️ **Configure Info.plist** (already created):
   - Location usage description added
   - Ensure it's linked to the target

4. ⚠️ **Add files to Xcode project**:
   - All created files need to be added to the Xcode project
   - In Xcode: File → Add Files to "Tempestas"
   - Select all folders (Models, Services, ViewModels, Views, Extensions)
   - Ensure "Copy items if needed" is checked
   - Ensure "Tempestas" target is selected

### Phase 2: Testing & Integration (Week 2)
1. Test WeatherKit API integration
2. Test location permissions flow
3. Test caching functionality
4. Add error handling improvements
5. Test on real device (WeatherKit requires device or simulator with location)

### Phase 3: UI Polish (Week 3)
1. Add loading states and animations
2. Implement pull-to-refresh
3. Add error state views
4. Polish card designs and shadows
5. Add dark mode refinements
6. Test accessibility (VoiceOver, Dynamic Type)

### Phase 4: Additional Features (Week 4)
1. Implement location reordering
2. Add swipe-to-delete for locations
3. Implement offline mode messaging
4. Add weather condition animations
5. Performance optimization

## Important Notes

### WeatherKit Requirements
- **Apple Developer Account** required (paid)
- **WeatherKit entitlement** must be enabled
- **Bundle ID** must be registered
- Testing on **real device or simulator with location** enabled

### API Usage
- Free tier: 500,000 calls/month
- Implemented caching reduces API calls significantly
- Expected usage: ~40-50 calls/user/day with 4 locations

### Location Permissions
- Added `NSLocationWhenInUseUsageDescription` to Info.plist
- App requests permission on first launch
- Graceful fallback if permission denied

### Caching Strategy
- Current weather: 10 minutes
- Hourly forecast: 1 hour  
- Daily forecast: 2 hours
- Old cache data (>24 hours) automatically cleared

## Known Issues / TODOs

1. **WeatherKit Integration**: The `WeatherService` class has a naming conflict (using `WeatherService.shared` inside the class). This needs to be fixed:
   ```swift
   // Current (incorrect):
   private let weatherService = WeatherService.shared
   
   // Should be:
   private let weatherKit = WeatherKit.shared
   ```

2. **Navigation**: HomeView needs navigation links to WeatherDetailView for each location card

3. **Saved Location Weather**: SavedLocationCard currently shows placeholder data. Need to fetch and cache weather for each saved location

4. **Error Handling**: Add more robust error handling and user-facing error messages

5. **Testing**: Need to add unit tests for services and view models

6. **UI Refinements**: Add animations, transitions, and loading skeletons

## Building and Running

1. Open `Tempestas.xcodeproj` in Xcode
2. Add all created source files to the project (if not already added)
3. Add WeatherKit capability
4. Select a target device or simulator
5. Build and run (⌘R)

## File Checklist

### Models ✅
- [x] WeatherLocation.swift
- [x] CurrentWeather.swift
- [x] HourlyForecast.swift
- [x] DailyForecast.swift
- [x] CacheEntry.swift
- [x] UserPreferences.swift

### Services ✅
- [x] WeatherService.swift (needs fix)
- [x] LocationService.swift
- [x] CacheService.swift
- [x] StorageService.swift

### ViewModels ✅
- [x] WeatherViewModel.swift
- [x] SettingsViewModel.swift

### Views ✅
- [x] HomeView.swift
- [x] CurrentLocationCard.swift
- [x] SavedLocationCard.swift
- [x] WeatherDetailView.swift
- [x] AddLocationView.swift
- [x] SettingsView.swift

### Extensions ✅
- [x] TemperatureFormatter.swift
- [x] DateFormatter+Extensions.swift
- [x] WindFormatter.swift

### Configuration ✅
- [x] Info.plist
- [x] TempestasApp.swift (updated)
- [x] ContentView.swift (updated)

## Architecture Diagram

```
┌─────────────────┐
│     Views       │
│  (SwiftUI)      │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   ViewModels    │
│  (ObservableObject)
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│    Services     │
│  (Business Logic)
└────────┬────────┘
         │
    ┌────┴────┬───────────┬────────────┐
    ↓         ↓           ↓            ↓
WeatherKit CoreLocation Cache    UserDefaults
```

## Resources

- [WeatherKit Documentation](https://developer.apple.com/documentation/weatherkit)
- [CoreLocation Documentation](https://developer.apple.com/documentation/corelocation)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [MapKit Documentation](https://developer.apple.com/documentation/mapkit)

---

**Ready for Development!** 🚀

The scaffolding is complete. Follow the "Next Steps" section to integrate everything and start testing.
