# Tempestas - MVP Wireframes
**Version:** 1.0  
**Date:** December 28, 2025  
**Platform:** iOS Mobile App (iPhone)

---

## Screen Flow Overview

```
Launch Screen
    ↓
First Launch: Welcome Screen
    ↓
Location Permission Request
    ↓
Home Screen (Current Location + Saved Locations)
    ↓
├── Weather Detail View (for any location)
├── Add Location Search
└── Settings
```

---

## 1. Launch Screen

```
┌─────────────────────────┐
│                         │
│                         │
│                         │
│                         │
│       🌤️               │
│                         │
│     Tempestas           │
│                         │
│    [Loading...]         │
│                         │
│                         │
│                         │
│                         │
│                         │
└─────────────────────────┘
```

**Elements:**
- Weather icon/logo (animated)
- App name "Tempestas"
- Subtle loading indicator
- Clean, minimal design
- Duration: 1-2 seconds max

---

## 2. First Launch: Welcome Screen

```
┌─────────────────────────┐
│                         │
│                         │
│       🌤️               │
│                         │
│     Tempestas           │
│                         │
│   Your weather,         │
│   beautifully simple    │
│                         │
│                         │
│   • Current conditions  │
│   • Hourly forecasts    │
│   • 3-day outlook       │
│   • Save locations      │
│                         │
│                         │
│                         │
│   ┌─────────────────┐   │
│   │  Get Started    │   │
│   └─────────────────┘   │
│                         │
└─────────────────────────┘
```

**Elements:**
- App logo/icon
- App name
- Brief tagline
- 4 key feature bullet points
- Primary CTA button "Get Started"
- Light, welcoming design

---

## 3. Location Permission Request

```
┌─────────────────────────┐
│                         │
│        📍              │
│                         │
│   Location Access       │
│                         │
│   Tempestas needs your  │
│   location to show      │
│   accurate weather for  │
│   where you are.        │
│                         │
│   Your location is      │
│   never shared and      │
│   stays private.        │
│                         │
│                         │
│   iOS Permission Dialog │
│   ┌─────────────────┐   │
│   │ Allow While     │   │
│   │ Using App       │   │
│   ├─────────────────┤   │
│   │ Allow Once      │   │
│   ├─────────────────┤   │
│   │ Don't Allow     │   │
│   └─────────────────┘   │
│                         │
│   [Enter Location       │
│    Manually]            │
│                         │
└─────────────────────────┘
```

**Elements:**
- Location icon
- Clear explanation of why location is needed
- Privacy reassurance
- iOS native permission dialog
- Fallback option to enter location manually
- Link styled as secondary action

---

## 4. Home Screen (Main View)

```
┌─────────────────────────┐
│  Tempestas         ⚙️   │
├─────────────────────────┤
│                         │
│  📍 Current Location    │
│  ┌───────────────────┐  │
│  │                   │  │
│  │   San Francisco   │  │
│  │                   │  │
│  │      ☀️           │  │
│  │                   │  │
│  │       72°         │  │
│  │     Sunny         │  │
│  │                   │  │
│  │   H: 78°  L: 65°  │  │
│  │                   │  │
│  │   Feels like 70°  │  │
│  │                   │  │
│  └───────────────────┘  │
│  ↓ Pull to refresh      │
│                         │
│  Saved Locations        │
│                         │
│  ┌───────────────────┐  │
│  │  New York    🌧️  │  │
│  │  58°              │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │  Tokyo       ⛅   │  │
│  │  65°              │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │  + Add Location   │  │
│  └───────────────────┘  │
│                         │
│                         │
│  Last updated: 2m ago   │
│                         │
└─────────────────────────┘
```

**Elements:**
- Header: App name + Settings gear icon
- Current location card (large, prominent):
  - GPS pin icon + "Current Location"
  - City name
  - Large weather icon
  - Large temperature display
  - Condition text
  - High/Low temps
  - Feels like temperature
- Pull-to-refresh hint
- "Saved Locations" section header
- Saved location cards (compact):
  - City name
  - Small weather icon
  - Current temperature
  - Tap to view details
- Add location button
- Last updated timestamp (small, bottom)
- Clean card-based design with shadows

---

## 5. Weather Detail View

```
┌─────────────────────────┐
│  ← San Francisco    ⚙️  │
├─────────────────────────┤
│                         │
│  [HERO SECTION]         │
│  ┌───────────────────┐  │
│  │                   │  │
│  │       ☀️          │  │
│  │                   │  │
│  │       72°         │  │
│  │     Sunny         │  │
│  │                   │  │
│  │   H: 78°  L: 65°  │  │
│  │   Feels like 70°  │  │
│  │                   │  │
│  └───────────────────┘  │
│                         │
│  Today's Forecast       │
│  ┌─────────────────────┤
│  │ 2PM 3PM 4PM 5PM 6PM │ ← scroll →
│  │ 73° 74° 75° 73° 70° │
│  │ ☀️  ☀️  ⛅  ⛅  🌤️  │
│  └─────────────────────┤
│                         │
│  3-Day Forecast         │
│  ┌───────────────────┐  │
│  │ Tomorrow      ⛅  │  │
│  │ H: 75° L: 63°     │  │
│  │ Partly Cloudy 10% │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Monday        🌧️ │  │
│  │ H: 68° L: 58°     │  │
│  │ Rain 60%          │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Tuesday       ⛅  │  │
│  │ H: 70° L: 60°     │  │
│  │ Partly Cloudy 20% │  │
│  └───────────────────┘  │
│                         │
│  Details                │
│  ┌─────────┬─────────┐  │
│  │ 💧 Humidity     │  │
│  │ 65%             │  │
│  ├─────────┬─────────┤  │
│  │ 💨 Wind         │  │
│  │ 8 mph NW        │  │
│  ├─────────┬─────────┤  │
│  │ ☀️ UV Index     │  │
│  │ 6 (High)        │  │
│  ├─────────┬─────────┤  │
│  │ 🌅 Sunrise      │  │
│  │ 6:48 AM         │  │
│  ├─────────┬─────────┤  │
│  │ 🌇 Sunset       │  │
│  │ 5:32 PM         │  │
│  └─────────┴─────────┘  │
│                         │
│  Updated: 2 min ago     │
│                         │
└─────────────────────────┘
```

**Elements:**
- Header: Back button + Location name + Settings
- Hero section (large card):
  - Animated weather icon
  - Large temperature
  - Condition text
  - High/Low
  - Feels like
- "Today's Forecast" section:
  - Horizontal scrollable hourly view
  - Time, temp, icon for each hour
  - Shows remaining hours of the day
- "3-Day Forecast" section:
  - 3 day cards (vertical)
  - Day name, icon, high/low, precipitation %
  - Brief condition description
- "Details" section:
  - Grid of weather details
  - Icons + labels for each metric
  - Humidity, Wind, UV Index, Sunrise, Sunset
- Last updated timestamp
- Scrollable content
- Pull-to-refresh enabled

---

## 6. Add Location - Search Screen

```
┌─────────────────────────┐
│  ← Add Location         │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │ 🔍 Search city... │  │
│  └───────────────────┘  │
│                         │
│  Recent Searches        │
│                         │
│  ┌───────────────────┐  │
│  │ Los Angeles, CA   │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Chicago, IL       │  │
│  └───────────────────┘  │
│                         │
│  Popular Cities         │
│                         │
│  ┌───────────────────┐  │
│  │ New York, NY      │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Los Angeles, CA   │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Miami, FL         │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Seattle, WA       │  │
│  └───────────────────┘  │
│                         │
│                         │
└─────────────────────────┘
```

**Elements:**
- Header: Back button + "Add Location"
- Search bar with magnifying glass icon
- Placeholder: "Search city..."
- Recent searches section (if available)
- Popular cities suggestion list
- Each city row is tappable
- Clean list design

---

## 7. Add Location - Search Results

```
┌─────────────────────────┐
│  ← Add Location         │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │ 🔍 Portland       │  │
│  └───────────────────┘  │
│                         │
│  Results                │
│                         │
│  ┌───────────────────┐  │
│  │ Portland, OR      │  │
│  │ United States     │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ Portland, ME      │  │
│  │ United States     │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ Portland          │  │
│  │ United Kingdom    │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ Portland, VIC     │  │
│  │ Australia         │  │
│  └───────────────────┘  │
│                         │
│                         │
│                         │
│                         │
└─────────────────────────┘
```

**Elements:**
- Search bar with user's query
- "Results" header
- List of matching locations
- Each result shows:
  - City name, State/Province
  - Country (disambiguation)
- Tap to add location
- Real-time search (updates as typing)

---

## 8. Add Location - Search Loading State

```
┌─────────────────────────┐
│  ← Add Location         │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │ 🔍 New York       │  │
│  └───────────────────┘  │
│                         │
│  Searching...           │
│                         │
│  ┌───────────────────┐  │
│  │ ░░░░░░░░░░░░      │  │
│  │ ░░░░░░░░░░        │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ ░░░░░░░░░░░░      │  │
│  │ ░░░░░░░░░░        │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ ░░░░░░░░░░░░      │  │
│  │ ░░░░░░░░░░        │  │
│  └───────────────────┘  │
│                         │
│                         │
│                         │
│                         │
└─────────────────────────┘
```

**Elements:**
- Search bar with query
- "Searching..." text
- Skeleton loaders for results
- Subtle animation (shimmer effect)

---

## 9. Add Location - No Results

```
┌─────────────────────────┐
│  ← Add Location         │
├─────────────────────────┤
│                         │
│  ┌───────────────────┐  │
│  │ 🔍 Atlantis       │  │
│  └───────────────────┘  │
│                         │
│                         │
│                         │
│       🔍               │
│                         │
│   No locations found    │
│                         │
│   Try searching for:    │
│   • A different city    │
│   • ZIP code            │
│   • State or country    │
│                         │
│                         │
│                         │
│                         │
│                         │
│                         │
│                         │
└─────────────────────────┘
```

**Elements:**
- Search bar with failed query
- Empty state icon (magnifying glass)
- "No locations found" message
- Helpful suggestions
- Clean, centered design

---

## 10. Add Location - Max Locations Reached

```
┌─────────────────────────┐
│  ← Add Location         │
├─────────────────────────┤
│                         │
│                         │
│                         │
│       ⚠️               │
│                         │
│   Maximum Locations     │
│   Reached               │
│                         │
│   You can save up to    │
│   3 locations.          │
│                         │
│   Remove a location     │
│   from your home        │
│   screen to add new     │
│   ones.                 │
│                         │
│                         │
│   ┌─────────────────┐   │
│   │  Go to Home     │   │
│   └─────────────────┘   │
│                         │
│                         │
└─────────────────────────┘
```

**Elements:**
- Warning icon
- Clear message about limit
- Explanation of constraint
- Instructions on how to proceed
- Button to return to home
- Appears before search if limit reached

---

## 11. Settings Screen

```
┌─────────────────────────┐
│  ← Settings             │
├─────────────────────────┤
│                         │
│  UNITS                  │
│  ┌───────────────────┐  │
│  │ Temperature       │  │
│  │ °F         [◉○]   │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Wind Speed        │  │
│  │ mph        [◉○]   │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Time Format       │  │
│  │ 12-hour    [◉○]   │  │
│  └───────────────────┘  │
│                         │
│  PERMISSIONS            │
│  ┌───────────────────┐  │
│  │ Location Access > │  │
│  └───────────────────┘  │
│                         │
│  ABOUT                  │
│  ┌───────────────────┐  │
│  │ WeatherKit Data > │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Privacy Policy  > │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Terms of Use    > │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ Contact Support > │  │
│  └───────────────────┘  │
│                         │
│  Version 1.0.0          │
│                         │
└─────────────────────────┘
```

**Elements:**
- Header: Back button + "Settings"
- Grouped list style (iOS native)
- **Units section:**
  - Temperature (°F / °C) toggle
  - Wind Speed (mph / km/h) toggle
  - Time Format (12 / 24 hour) toggle
- **Permissions section:**
  - Location Access (links to iOS Settings)
- **About section:**
  - WeatherKit attribution (required by Apple)
  - Privacy Policy link
  - Terms of Use link
  - Contact/Support option
- App version number at bottom
- Standard iOS settings design patterns

---

## 12. Weather Detail - Loading State

```
┌─────────────────────────┐
│  ← San Francisco    ⚙️  │
├─────────────────────────┤
│                         │
│  [HERO SECTION]         │
│  ┌───────────────────┐  │
│  │                   │  │
│  │    [Spinner]      │  │
│  │                   │  │
│  │  ░░░░░░░░░        │  │
│  │  ░░░░░░░░░        │  │
│  │                   │  │
│  │  ░░░░░ ░░░░░      │  │
│  │  ░░░░░░░░░░       │  │
│  │                   │  │
│  └───────────────────┘  │
│                         │
│  Today's Forecast       │
│  ┌─────────────────────┤
│  │ ░░  ░░  ░░  ░░  ░░ │
│  │ ░░  ░░  ░░  ░░  ░░ │
│  │ ░░  ░░  ░░  ░░  ░░ │
│  └─────────────────────┤
│                         │
│  3-Day Forecast         │
│  ┌───────────────────┐  │
│  │ ░░░░░░░░░░░  ░░   │  │
│  │ ░░░░░ ░░░░░       │  │
│  └───────────────────┘  │
│  ┌───────────────────┐  │
│  │ ░░░░░░░░░░░  ░░   │  │
│  │ ░░░░░ ░░░░░       │  │
│  └───────────────────┘  │
│                         │
│  Loading weather data...│
│                         │
└─────────────────────────┘
```

**Elements:**
- Same layout as detail view
- Skeleton loaders (shimmer effect)
- Loading spinner in hero section
- "Loading weather data..." text
- Maintains layout structure

---

## 13. Error State - No Internet

```
┌─────────────────────────┐
│  Tempestas         ⚙️   │
├─────────────────────────┤
│                         │
│                         │
│                         │
│       📡               │
│       ✕                │
│                         │
│   No Internet           │
│   Connection            │
│                         │
│   Showing last saved    │
│   weather data          │
│                         │
│   Last updated:         │
│   15 minutes ago        │
│                         │
│                         │
│   ┌─────────────────┐   │
│   │  Try Again      │   │
│   └─────────────────┘   │
│                         │
│                         │
│                         │
└─────────────────────────┘
```

**Elements:**
- Offline icon
- Clear error message
- Explanation that cached data is shown
- Last updated timestamp
- "Try Again" button
- Non-blocking (user can still see cached data below)

---

## 14. Error State - Location Permission Denied

```
┌─────────────────────────┐
│  Tempestas         ⚙️   │
├─────────────────────────┤
│                         │
│                         │
│                         │
│       📍               │
│       ✕                │
│                         │
│   Location Access       │
│   Denied                │
│                         │
│   To show weather for   │
│   your current location,│
│   enable location       │
│   permissions.          │
│                         │
│                         │
│   ┌─────────────────┐   │
│   │ Open Settings   │   │
│   └─────────────────┘   │
│                         │
│   ┌─────────────────┐   │
│   │ Add Location    │   │
│   │   Manually      │   │
│   └─────────────────┘   │
│                         │
└─────────────────────────┘
```

**Elements:**
- Location icon with X
- Clear error message
- Explanation of issue
- Two action options:
  - Open iOS Settings (to enable permission)
  - Add location manually (workaround)
- Helpful, non-technical language

---

## 15. Home Screen - Manage Locations (Edit Mode)

```
┌─────────────────────────┐
│  ← Done                 │
├─────────────────────────┤
│                         │
│  Manage Locations       │
│                         │
│  Saved Locations        │
│                         │
│  ┌───────────────────┐  │
│  │ ≡ New York   🌧️  │🗑│
│  │   58°             │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ ≡ Tokyo      ⛅   │🗑│
│  │   65°             │  │
│  └───────────────────┘  │
│                         │
│  ┌───────────────────┐  │
│  │ ≡ London     🌦️  │🗑│
│  │   52°             │  │
│  └───────────────────┘  │
│                         │
│                         │
│  ┌───────────────────┐  │
│  │  + Add Location   │  │
│  └───────────────────┘  │
│                         │
│  Drag to reorder        │
│  Tap 🗑 to delete       │
│                         │
└─────────────────────────┘
```

**Elements:**
- Header: "Done" button (exits edit mode)
- Title: "Manage Locations"
- Each location card shows:
  - Drag handle (≡ icon)
  - Location name and icon
  - Delete button (trash can)
- Add location button still available
- Instructions at bottom
- Accessed via long-press on location card or edit button

---

## 16. Pull-to-Refresh Animation

```
┌─────────────────────────┐
│  Tempestas         ⚙️   │
├─────────────────────────┤
│         ↓               │
│    Refreshing...        │
│      [Spinner]          │
│                         │
│  📍 Current Location    │
│  ┌───────────────────┐  │
│  │                   │  │
│  │   San Francisco   │  │
│  │                   │  │
│  │      ☀️           │  │
│  │                   │  │
│  │       72°         │  │
│  │     Sunny         │  │
│  │                   │  │
│  │   H: 78°  L: 65°  │  │
│  │                   │  │
│  └───────────────────┘  │
│                         │
│  Saved Locations        │
│  ...                    │
│                         │
└─────────────────────────┘
```

**Elements:**
- Pull-down gesture reveals refresh area
- Downward arrow and "Refreshing..." text
- Spinner animation
- Content dims slightly during refresh
- Smooth animation and haptic feedback
- Auto-hides when complete

---

## Design Specifications

### Colors

**Light Mode:**
- Background: #FFFFFF
- Card Background: #F8F9FA
- Text Primary: #1A1A1A
- Text Secondary: #666666
- Accent Blue: #007AFF (iOS default)
- Border: #E5E5E5
- Success: #34C759
- Warning: #FF9500
- Error: #FF3B30

**Dark Mode:**
- Background: #000000
- Card Background: #1C1C1E
- Text Primary: #FFFFFF
- Text Secondary: #98989D
- Accent Blue: #0A84FF
- Border: #38383A
- Success: #32D74B
- Warning: #FF9F0A
- Error: #FF453A

**Dynamic Weather Colors (Subtle background tints):**
- Sunny: Warm yellow gradient
- Cloudy: Cool gray gradient
- Rainy: Blue-gray gradient
- Stormy: Dark gray gradient
- Night: Deep blue/purple gradient

### Typography

**SF Pro Display (Headers):**
- Location Name: 20pt, Semibold
- Temperature (Large): 64pt, Light
- Temperature (Medium): 40pt, Regular
- Section Headers: 18pt, Semibold

**SF Pro Text (Body):**
- Body Text: 16pt, Regular
- Secondary Text: 14pt, Regular
- Caption: 12pt, Regular
- Weather Condition: 18pt, Regular

### Spacing & Layout

- Screen Padding: 16px (left/right)
- Card Padding: 16px (internal)
- Card Margin: 12px (between cards)
- Element Spacing: 8px (small), 16px (medium), 24px (large)
- Section Spacing: 32px

### Card Design

- Border Radius: 16px
- Shadow: 0 2px 12px rgba(0,0,0,0.08) light mode
- Shadow: 0 2px 12px rgba(0,0,0,0.4) dark mode
- Border: None (shadow only)

### Icons

**Weather Icons:**
- Size: 80pt (hero), 48pt (medium), 32pt (small)
- Use SF Symbols or custom icons
- Animated when appropriate (subtle)
- Color: Dynamic based on condition

**UI Icons:**
- Size: 20pt (standard), 16pt (small)
- SF Symbols for system icons
- Consistent weight (Regular or Medium)

### Animations

**Transitions:**
- Screen push/pop: iOS default (300ms)
- Modal present: iOS default sheet
- Card appear: Fade + slide up (250ms)

**Interactions:**
- Button tap: Scale to 0.96 (150ms)
- Card tap: Scale to 0.98 + shadow increase
- Pull-to-refresh: iOS standard with haptics

**Weather Animations:**
- Icon transitions: Cross-fade (300ms)
- Data updates: Fade (200ms)
- Loading skeletons: Shimmer effect

### Accessibility

**VoiceOver:**
- All interactive elements labeled
- Weather conditions described
- Temperature values announced with units
- Navigation hints provided

**Dynamic Type:**
- Support all text sizes
- Layout adjusts for larger text
- Maintain readability at all sizes

**Color Contrast:**
- WCAG AA minimum (4.5:1 for text)
- High contrast mode support
- Test with color blindness simulators

**Touch Targets:**
- Minimum 44x44pt for all interactive elements
- Adequate spacing between targets
- Easy thumb reach for primary actions

---

## Interaction Patterns

### Gestures

1. **Tap:**
   - Location card → View weather detail
   - Search result → Add location
   - Settings row → Navigate/toggle

2. **Long Press:**
   - Location card → Enter edit mode
   - (Future: Quick actions menu)

3. **Swipe:**
   - Location card left → Delete option
   - Between locations (future enhancement)

4. **Drag:**
   - Location card in edit mode → Reorder

5. **Pull Down:**
   - Weather view → Refresh data

### Navigation

**Tab-less MVP:**
- Stack-based navigation
- Back button always visible
- Settings accessible from header
- Modal for add location

**Future Enhancement:**
- Consider tab bar if app grows
- Widget integration
- Today view extension

---

## State Management

### Data States

1. **Loading:**
   - Skeleton loaders
   - Spinner in center
   - Maintain layout structure

2. **Loaded:**
   - Full data display
   - Smooth fade-in
   - Last updated timestamp

3. **Error:**
   - Clear error message
   - Actionable recovery options
   - Show cached data if available

4. **Empty:**
   - Empty state illustrations
   - Helpful guidance text
   - Clear next actions

5. **Offline:**
   - Show cached data with indicator
   - Explain offline status
   - Offer retry option

---

## Developer Notes

### Layout Considerations

1. **Safe Areas:**
   - Respect iOS safe area insets
   - Account for notch/Dynamic Island
   - Bottom padding for home indicator

2. **Scrolling:**
   - All content scrollable where needed
   - Bounce effect enabled
   - Scroll indicators as needed

3. **Keyboard:**
   - Search dismisses on scroll
   - Auto-capitalize city names
   - Return key = "Search"

4. **Orientation:**
   - Portrait only for MVP
   - Lock orientation in code

### Performance

1. **Image Loading:**
   - Async loading for icons
   - Cached weather icons
   - Placeholder during load

2. **Data Fetching:**
   - Check cache first
   - Background refresh
   - Debounce search input

3. **Memory:**
   - Release cached data when needed
   - Limit image cache size
   - Monitor memory usage

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Dec 28, 2025 | Initial wireframes created |

---

**Next Steps:**
1. Review wireframes with team
2. Create high-fidelity mockups in Figma/Sketch
3. Build interactive prototype
4. Conduct user testing
5. Begin development with approved designs

---

*These wireframes represent the MVP. Additional screens and flows will be added in future versions.*
