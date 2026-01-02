//
//  AddLocationView.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import SwiftUI

struct AddLocationView: View {
    @ObservedObject var viewModel: WeatherViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationService = LocationService()
    
    @State private var searchText = ""
    @State private var searchResults: [WeatherLocation] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if !viewModel.canAddMoreLocations() {
                    MaxLocationsReachedView()
                } else {
                    List {
                        if searchText.isEmpty {
                            Section("Popular Cities") {
                                ForEach(popularCities) { location in
                                    LocationRow(location: location)
                                        .onTapGesture {
                                            addLocation(location)
                                        }
                                }
                            }
                        } else {
                            if isSearching {
                                Section("Searching...") {
                                    ProgressView()
                                }
                            } else if searchResults.isEmpty {
                                Section {
                                    NoResultsView()
                                }
                            } else {
                                Section("Results") {
                                    ForEach(searchResults) { location in
                                        LocationRow(location: location)
                                            .onTapGesture {
                                                addLocation(location)
                                            }
                                    }
                                }
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Search city...")
                    .onChange(of: searchText) { oldValue, newValue in
                        Task {
                            await searchLocations(query: newValue)
                        }
                    }
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func searchLocations(query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        do {
            searchResults = try await locationService.searchLocations(query: query)
        } catch {
            searchResults = []
        }
        
        isSearching = false
    }
    
    private func addLocation(_ location: WeatherLocation) {
        viewModel.addLocation(location)
        dismiss()
    }
    
    private var popularCities: [WeatherLocation] {
        [
            WeatherLocation(name: "New York, NY", latitude: 40.7128, longitude: -74.0060),
            WeatherLocation(name: "Los Angeles, CA", latitude: 34.0522, longitude: -118.2437),
            WeatherLocation(name: "Chicago, IL", latitude: 41.8781, longitude: -87.6298),
            WeatherLocation(name: "Miami, FL", latitude: 25.7617, longitude: -80.1918),
            WeatherLocation(name: "Seattle, WA", latitude: 47.6062, longitude: -122.3321)
        ]
    }
}

// MARK: - Location Row

struct LocationRow: View {
    let location: WeatherLocation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(location.name)
                .font(.headline)
        }
    }
}

// MARK: - No Results View

struct NoResultsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No locations found")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Try searching for:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("• A different city")
                Text("• ZIP code")
                Text("• State or country")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: - Max Locations Reached View

struct MaxLocationsReachedView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(.orange)
            
            Text("Maximum Locations Reached")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("You can save up to 3 locations.\n\nRemove a location from your home screen to add new ones.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Go to Home") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    AddLocationView(viewModel: WeatherViewModel())
}
