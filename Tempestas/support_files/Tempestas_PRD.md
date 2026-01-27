# Product Requirements Document (PRD)
# Tempestas - Simple Weather App

---

## Document Information
- **Product Name:** Tempestas
- **Version:** 1.0 (MVP)
- **Date:** December 28, 2025
- **Author:** Product Team
- **Status:** Draft

---

## 1. Executive Summary

### 1.1 Product Overview
Tempestas (Latin for "weather") is a minimalist iOS weather application that provides users with essential weather information for their current location and up to three saved locations. The app leverages Apple's WeatherKit API to deliver accurate, real-time weather data with an emphasis on simplicity, speed, and elegant design.

### 1.2 Product Vision
To create the most straightforward, beautiful weather app that gives users exactly what they need—current conditions and forecasts—without overwhelming them with unnecessary features or cluttered interfaces.

### 1.3 Target Audience
- **Primary:** iOS users (iPhone) seeking a clean, simple weather app
- **Secondary:** Apple ecosystem enthusiasts who appreciate native iOS design
- **Tertiary:** Users frustrated with ad-heavy or overly complex weather apps

### 1.4 Business Goals
- Launch MVP within 3-4 months
- Achieve 1,000 downloads in first month
- Maintain 4.5+ star rating on App Store
- Build foundation for future Apple Watch and iPad extensions
- Demonstrate proficiency with WeatherKit API

---

## 2. Problem Statement

### 2.1 User Pain Points
- Most weather apps are cluttered with ads, excessive features, and confusing UIs
- Users want quick access to essential weather info without distractions
- Many apps require account creation or subscriptions for basic features
- Heavy apps that drain battery and use excessive data
- Privacy concerns with third-party weather services

### 2.2 Solution
Tempestas provides a lightweight, privacy-focused weather app that:
- Shows essential weather information instantly
- Requires no account or login
- Uses Apple's trusted WeatherKit service
- Implements smart caching to minimize data usage
- Delivers a native iOS experience with elegant design

---

## 3. Core Features & Requirements

### 3.1 Current Location Weather
**Priority:** P0 (Must Have)

**Description:**
Display current weather conditions for the user's location automatically.

**Requirements:**
- Auto-detect user's location using CoreLocation
- Display current temperature (in °F and °C)
- Show weather condition (e.g., "Sunny", "Cloudy", "Rainy")
- Display condition icon/animation
- Show "feels like" temperature
- Include high/low for the day
- Display humidity percentage
- Show wind speed and direction
- Include UV index
- Show sunrise/sunset times

**Technical Notes:**
- Request "When In Use" location permission
- Handle location permission denial gracefully
- Fallback to last known location if GPS unavailable
- Cache location data for 10 minutes

### 3.2 Today's Forecast
**Priority:** P0 (Must Have)

**Description:**
Provide hourly weather forecast for the remainder of the current day.

**Requirements:**
- Show hourly forecast from current time until midnight
- Display minimum of 6 hours, maximum of remaining hours in day
- Each hour shows:
  - Time (12-hour format)
  - Temperature
  - Weather condition icon
  - Precipitation chance (if > 0%)
- Horizontal scrollable list
- Highlight current hour

**Technical Notes:**
- Use WeatherKit hourly forecast endpoint
- Cache hourly data for 1 hour
- Update automatically when user returns to app

### 3.3 7-Day Forecast
**Priority:** P0 (Must Have)

**Description:**
Show daily weather forecast for the next 7 days (including today/tonight or starting tomorrow).

**Requirements:**
- Display next 7 days
- Each day shows:
  - Day name (e.g., "Monday", "Today")
  - Weather condition icon
  - High temperature
  - Low temperature
  - Precipitation chance
- Vertical list or card layout
- Tap to expand (optional)

**Technical Notes:**
- Use WeatherKit daily forecast endpoint (max 10 days available, showing 7)
- Cache daily data for 2 hours
- Dates should account for user's timezone

### 3.4 Saved Locations
**Priority:** P0 (Must Have)

**Description:**
Allow users to save up to 3 additional locations beyond current location.

**Requirements:**
- Search for locations by:
  - City name
  - ZIP code
  - State/Country
- Display specific town/city name for "Current Location" (using Reverse Geocoding)
- Display search results with disambiguation
- Save up to 3 locations
- View weather for any saved location by tapping the card
- Navigate to Detail View for full forecast
- Delete saved locations via "Swipe-to-Delete" gesture
- Reorder saved locations (drag and drop) - *Future/In Progress*
- Show all locations on home screen with quick view data:
  - Location name
  - Current temperature
  - Current condition icon
  - High/Low temperatures

**Technical Notes:**
- Use Apple MapKit for location search & CLGeocoder for reverse geocoding
- Store locations locally (UserDefaults or Core Data)
- Cache weather data per location separately
- Current location always shown first

### 3.5 Settings
**Priority:** P1 (Should Have)

**Description:**
Provide basic app configuration options.

**Requirements:**
- Temperature units toggle (°F / °C)
- Wind speed units (mph / km/h)
- 12-hour / 24-hour time format
- Location permissions management link
- About section with:
  - App version
  - WeatherKit attribution
  - Privacy policy link
  - Terms of service link
- Contact/feedback option

**Technical Notes:**
- Store preferences in UserDefaults
- Apply unit changes immediately across app
- Sync with iOS system preferences where applicable

### 3.6 Data Caching
**Priority:** P0 (Must Have)

**Description:**
Implement intelligent caching to minimize WeatherKit API calls and improve performance, while allowing forced refresh.

**Requirements:**
- Cache current weather data for 10 minutes
- Cache hourly forecast for 1 hour
- Cache daily forecast for 2 hours
- Cache per location independently
- Show last updated timestamp
- Pull-to-refresh to force update (bypasses cache)
- Background refresh when app returns from background (if cache expired)
- Persist cache to disk for offline viewing

**Technical Notes:**
- Use CacheService with CacheEntry struct
- Maximize cache usage to stay within WeatherKit free tier limits

### 3.7 Climate & Historical Data
**Priority:** P1 (Implemented)

**Description:**
Provide biological and historical weather context for locations.

**Requirements:**
- **Historical Context:** Display "Average High" and "Average Low" for the current date in the Detail View.
- **Climate View:** Dedicated tab/view showing:
  - Monthly Average Temperature (High/Low) Chart
  - Monthly Average Precipitation Chart
- **Data Source:** Use Open-Meteo Archive API for historical data (last 10 years).
- **Unit Comparison:** Charts and data must respect user's temperature (F/C) and precipitation (in/mm) preferences.

**Technical Notes:**
- Fetch data from Open-Meteo asynchronously
- Local aggregation of 10-year daily data into monthly averages
- Use SwiftUI Charts framework

---

## 4. User Flows

### 4.1 First Launch Flow
1. User opens app for first time
2. Welcome screen appears with app name and tagline
3. "Get Started" button
4. Location permission request with explanation
5. If granted → Load current location weather → Home screen
6. If denied → Show manual location entry screen

### 4.2 Primary User Flow (Returning User)
1. User opens app
2. App checks cache validity for current location
3. If cache valid → Display cached data immediately
4. If cache expired → Show cached data + refresh indicator → Update with fresh data
5. User can:
   - Scroll through hourly forecast
   - View 3-day forecast
   - Switch between saved locations
   - Pull to refresh

### 4.3 Add Location Flow
1. User taps "+" or "Add Location" button
2. Search screen appears
3. User types location name/ZIP
4. Search results appear as user types
5. User selects location from results
6. Location added to saved list (if < 3 locations)
7. Weather data loads for new location
8. User returns to home with new location visible

### 4.4 View Saved Location Flow
1. User taps on saved location card
2. App checks cache for that location
3. Full weather view displays for selected location
4. User can switch back to current location or other saved locations

---

## 5. Non-Functional Requirements

### 5.1 Performance
- App launch time: < 2 seconds (cold start)
- Weather data load time: < 1 second (with cache)
- Weather data load time: < 3 seconds (fresh API call)
- Smooth scrolling at 60 FPS minimum
- App size: < 20 MB

### 5.2 Compatibility
- **iOS Version:** iOS 16.0+ (required for WeatherKit)
- **Devices:** iPhone only (MVP)
- **Screen Sizes:** Support all iPhone screen sizes from iPhone SE to iPhone 15 Pro Max
- **Orientation:** Portrait only (MVP)
- **Dark Mode:** Full support required
- **Accessibility:** VoiceOver support, Dynamic Type support

### 5.3 Data & Privacy
- No user accounts or authentication required
- No personal data collected or stored on servers
- Location data never leaves the device except for WeatherKit API calls
- Weather data cached locally only
- Comply with Apple App Store privacy requirements
- Privacy policy published and linked in app
- WeatherKit attribution displayed as required by Apple

### 5.4 Reliability
- Graceful handling of network errors
- Offline mode: Display last cached data
- Handle API rate limiting appropriately
- No crashes on background/foreground transitions
- Target crash-free rate: 99.5%+

### 5.5 Security
- HTTPS only for all API calls
- Secure storage of cached data
- No sensitive data stored
- No third-party analytics (MVP)

---

## 6. Technical Requirements

### 6.1 Platform & Framework
- **Language:** Swift 5.9+
- **UI Framework:** SwiftUI
- **Minimum iOS:** 16.0
- **Xcode:** 15.0+
- **Architecture:** MVVM (Model-View-ViewModel)

### 6.2 Apple Services & APIs
- **WeatherKit:** Weather data
- **CoreLocation:** GPS and location services
- **MapKit:** Location search
- **UserDefaults:** Settings and saved locations
- **FileManager:** Persistent cache storage
- **Combine:** Reactive programming for data flow
- **CLGeocoder:** Reverse geocoding for city names

### 6.3 External Services & APIs
- **Open-Meteo Archive API:** Historical weather data (last 10 years) for Climate View

### 6.4 Key Libraries/Dependencies
- Native iOS frameworks only (no third-party dependencies for MVP)
- Consider SwiftLint for code quality (development only)
- **SwiftUI Charts:** For Climate View visualization

### 6.5 Data Models
```swift
struct WeatherLocation {
    let id: UUID
    let name: String
    let latitude: Double
    let longitude: Double
    let isCurrentLocation: Bool
}

struct CurrentWeather {
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

struct HourlyForecast {
    let time: Date
    let temperature: Double
    let condition: String
    let conditionCode: String
    let precipitationChance: Int
}

struct DailyForecast {
    let date: Date
    let highTemp: Double
    let lowTemp: Double
    let condition: String
    let conditionCode: String
    let precipitationChance: Int
}

struct MonthlyClimateStats {
    let month: Int
    let monthName: String
    let averageHighTemperature: Double
    let averageLowTemperature: Double
    let averagePrecipitation: Double
}

struct DailyStatistics {
    let averageHighTemperature: Measurement<UnitTemperature>
    let averageLowTemperature: Measurement<UnitTemperature>
}
```

### 6.6 Caching Strategy
\`\`\`swift
struct CacheEntry<T> {
    let data: T
    let timestamp: Date
    let expirationInterval: TimeInterval
    
    var isExpired: Bool {
        Date().timeIntervalSince(timestamp) > expirationInterval
    }
}

// Cache durations
- Current weather: 10 minutes
- Hourly forecast: 1 hour
- Daily forecast: 2 hours
\`\`\`

---

## 7. Design Requirements

### 7.1 Design Principles
- **Minimalist:** Clean, uncluttered interface
- **Native:** Feels like a natural iOS app
- **Fast:** Information displayed immediately
- **Beautiful:** Elegant typography and animations
- **Accessible:** Easy to read and navigate for all users

### 7.2 Visual Style
- **Color Palette:**
  - Dynamic colors that adapt to weather conditions
  - Light mode: Bright, airy backgrounds
  - Dark mode: Deep, rich backgrounds
  - Accent color: Subtle blue (#007AFF or custom)
  
- **Typography:**
  - SF Pro (System font)
  - Large, readable temperature displays
  - Dynamic Type support
  
- **Iconography:**
  - SF Symbols for weather conditions
  - Custom weather icons (optional enhancement)
  - Consistent icon sizes
  
- **Layout:**
  - Card-based design for locations
  - Generous whitespace
  - Clear visual hierarchy
  - Smooth transitions and animations

### 7.3 Key Screens Design

**Home Screen:**
- Top: Current location weather (large)
- Middle: Saved locations (cards)
- Bottom: Navigation or add location button
- Pull-to-refresh gesture

**Weather Detail View:**
- Hero section: Large temperature + condition
- Hourly forecast (horizontal scroll)
- 3-day forecast (vertical list)
- Additional data (humidity, wind, UV, etc.)
- Last updated timestamp

**Location Search:**
- Search bar at top
- Results list
- Empty state for no results
- Loading state while searching

**Settings:**
- Grouped list style
- Toggle switches for preferences
- Navigation to sub-pages

### 7.4 Animations
- Smooth page transitions
- Weather icon animations (subtle)
- Loading skeletons for data fetching
- Pull-to-refresh animation
- Success feedback for adding locations

---

## 8. Success Metrics & KPIs

### 8.1 Launch Metrics (First 30 Days)
- **Downloads:** 1,000+
- **App Store Rating:** 4.5+ stars
- **Crash-free Rate:** 99.5%+
- **Day 1 Retention:** 60%+
- **Day 7 Retention:** 30%+

### 8.2 Usage Metrics
- **Daily Active Users (DAU):** Track growth
- **Average Session Duration:** 30-60 seconds (expected for weather app)
- **Sessions per Day:** 3-5 (morning, afternoon, evening checks)
- **Saved Locations per User:** Average 1.5-2
- **Pull-to-Refresh Usage:** 20%+ of sessions

### 8.3 Technical Metrics
- **API Calls per User per Day:** < 50 (to stay under free tier)
- **Cache Hit Rate:** > 70%
- **Average Load Time:** < 2 seconds
- **App Size:** < 20 MB

### 8.4 User Satisfaction
- **App Store Reviews:** Monitor and respond
- **Support Requests:** Track common issues
- **Feature Requests:** Collect for future versions

---

## 9. Development Phases

### 9.1 Phase 1: Foundation (Weeks 1-3)
- Project setup and architecture
- WeatherKit integration
- CoreLocation implementation
- Basic data models and services
- Cache implementation
- Unit tests for core logic

**Deliverable:** Weather data successfully fetched and cached

### 9.2 Phase 2: Core UI (Weeks 4-6)
- Home screen with current location
- Weather detail view
- Hourly forecast component
- Daily forecast component
- Basic navigation
- Light/Dark mode support

**Deliverable:** Functioning single-location weather view

### 9.3 Phase 3: Saved Locations (Weeks 7-8)
- Location search implementation
- Add/remove/reorder locations
- Multi-location caching
- Location switching UI

**Deliverable:** Full saved locations feature

### 9.4 Phase 4: Polish & Settings (Weeks 9-10)
- Settings screen
- Unit preferences
- Animations and transitions
- Error handling and edge cases
- Accessibility improvements
- Loading and empty states

**Deliverable:** Feature-complete MVP

### 9.5 Phase 5: Testing & Launch (Weeks 11-12)
- Beta testing (TestFlight)
- Bug fixes
- Performance optimization
- App Store assets (screenshots, description)
- Privacy policy and terms
- App Store submission
- Marketing materials

**Deliverable:** App live on App Store

---

## 10. Future Enhancements (Post-MVP)

### 10.1 Version 1.1
- **Apple Watch App:** Glanceable weather on wrist
- **Widgets:** Home screen and Lock Screen widgets
- **Notifications:** Daily weather summary, severe weather alerts
- **More Locations:** Increase from 3 to 10 saved locations

### 10.2 Version 1.2
- **iPad Support:** Optimized layout for larger screens
- **Weather Maps:** Radar, temperature maps, precipitation
- **Historical Data:** Past weather trends
- **Detailed Charts:** Temperature curves, precipitation graphs

### 10.3 Version 2.0
- **Weather Alerts:** Push notifications for severe weather
- **Air Quality:** AQI data and health recommendations
- **Pollen Count:** Allergy information
- **Astronomy:** Moon phases, meteor showers
- **Custom Themes:** User-selectable color schemes
- **Social Sharing:** Share weather with friends

### 10.4 Version 2.5
- **Siri Integration:** "Hey Siri, what's the weather in San Francisco?"
- **Shortcuts Support:** Automation integration
- **Live Activities:** Dynamic Island support (iPhone 14 Pro+)
- **Weather Summaries:** AI-generated daily weather insights

---

## 11. Risks & Mitigation

### 11.1 Technical Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| WeatherKit API limitations | High | Medium | Implement robust caching, monitor usage |
| iOS version compatibility issues | Medium | Low | Thorough testing on multiple iOS versions |
| Location permission denial | Medium | Medium | Provide manual location entry fallback |
| Cache corruption | Medium | Low | Implement cache validation and recovery |

### 11.2 Business Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Low adoption rate | High | Medium | Focus on App Store optimization, quality |
| Negative reviews | Medium | Low | Beta test thoroughly, respond to feedback |
| WeatherKit pricing changes | Medium | Low | Monitor usage, have alternative APIs researched |
| Competing apps | Low | High | Differentiate with simplicity and design |

### 11.3 User Experience Risks
| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Confusing interface | High | Low | User testing, follow iOS HIG |
| Slow performance | High | Low | Performance testing, optimization |
| Battery drain | Medium | Low | Minimize background activity, efficient code |
| Poor accessibility | Medium | Low | Implement VoiceOver, Dynamic Type |

---

## 12. App Store Listing

### 12.1 App Name
**Primary:** Tempestas - Simple Weather
**Subtitle:** Clean Weather Forecasts

### 12.2 Description
**Short:**
Your weather, beautifully simple. Tempestas delivers accurate forecasts for your location and favorite places—no clutter, no ads, just the weather you need.

**Full:**
Tempestas brings you accurate, beautiful weather forecasts powered by Apple's WeatherKit. Named after the Latin word for weather, Tempestas offers a clean, minimalist experience focused on what matters most.

**Features:**
• Current weather for your location
• Hourly forecasts for today
• 3-day forecast at a glance
• Save up to 3 favorite locations
• Beautiful, native iOS design
• Dark mode support
• Privacy-focused—no account required
• Fast, with smart caching

**Perfect for:**
• Quick weather checks throughout your day
• Planning weekend activities
• Checking weather in multiple cities
• Anyone who values simplicity and design

No ads. No subscriptions. No complicated features. Just beautiful, accurate weather.

### 12.3 Keywords
weather, forecast, temperature, conditions, simple weather, clean weather, minimal weather, local weather, hourly forecast, daily forecast

### 12.4 Categories
- Primary: Weather
- Secondary: Utilities

### 12.5 Age Rating
4+ (No objectionable content)

---

## 13. Budget & Resources

### 13.1 Development Costs
- **Developer Time:** 12 weeks @ $X/hour (or solo development)
- **Apple Developer Program:** $99/year
- **WeatherKit API:** Free tier (500K calls/month)
- **Design Assets:** $0-500 (if hiring designer for custom icons)
- **Beta Testing:** $0 (TestFlight is free)

**Estimated Total:** $99-$599 (excluding developer time)

### 13.2 Ongoing Costs (Annual)
- Apple Developer Program: $99/year
- WeatherKit API: $0 (assuming stay under free tier)
- Domain (if needed for privacy policy): $12-15/year

**Estimated Annual:** $111-$114/year

### 13.3 Team
- **MVP:** 1 iOS Developer (can be solo)
- **Post-MVP:** Consider adding UI/UX designer for enhancements

---

## 14. Legal & Compliance

### 14.1 Required Documents
- Privacy Policy
- Terms of Service
- WeatherKit Attribution (as required by Apple)

### 14.2 Compliance
- Apple App Store Guidelines
- WeatherKit Terms of Use
- iOS Location Services Guidelines
- Accessibility Guidelines (WCAG 2.1 Level AA target)

### 14.3 Data Handling
- No personal data collected
- Location data used only for weather fetching
- Cached data stored locally only
- No third-party data sharing

---

## 15. Appendix

### 15.1 Competitive Analysis

| App | Pros | Cons | Differentiation |
|-----|------|------|-----------------|
| Apple Weather | Native, accurate, free | Can be cluttered, many features | Tempestas is simpler, focused |
| Weather.com | Comprehensive data | Ads, cluttered UI | Tempestas is ad-free, cleaner |
| Carrot Weather | Personality, widgets | Subscription required, complex | Tempestas is free, simpler |
| Dark Sky (discontinued) | Clean, accurate | No longer available | Tempestas fills this gap |

### 15.2 WeatherKit API Details

**Available Data:**
- Current weather
- Minute-by-minute precipitation (next hour)
- Hourly forecast (10 days)
- Daily forecast (10 days)
- Weather alerts
- Historical data (limited)

**Rate Limits:**
- 500,000 calls/month (free)
- $0.50 per 10,000 calls beyond free tier

**For Tempestas:**
- Estimated 4 calls per user per day (current + hourly + daily per location)
- With caching: ~40-50 calls per user per day worst case
- Free tier supports: ~10,000-12,500 daily active users

### 15.3 Glossary
- **MVP:** Minimum Viable Product
- **WeatherKit:** Apple's weather data API service
- **CoreLocation:** iOS framework for location services
- **DAU:** Daily Active Users
- **P0/P1:** Priority levels (P0 = must have, P1 = should have)
- **HIG:** Human Interface Guidelines (Apple's design standards)

---

## Document Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Dec 28, 2025 | Product Team | Initial PRD creation |

---

**Next Steps:**
1. Review and approve PRD
2. Set up development environment
3. Begin Phase 1 development
4. Schedule weekly progress reviews
5. Plan beta testing timeline

---

*This PRD is a living document and will be updated as the product evolves.*
