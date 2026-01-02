//
//  HomeView.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var showSettings = false
    @State private var showAddLocation = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Current Location Weather
                    if let currentLocation = viewModel.currentLocation {
                        CurrentLocationCard(
                            location: currentLocation,
                            weather: viewModel.currentWeather,
                            preferences: settingsViewModel.preferences
                        )
                        .onTapGesture {
                            // Navigate to detail view
                        }
                    }
                    
                    // Saved Locations
                    if !viewModel.savedLocations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Saved Locations")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.savedLocations) { location in
                                SavedLocationCard(
                                    location: location,
                                    weather: viewModel.savedLocationsWeather[location.id],
                                    preferences: settingsViewModel.preferences
                                )
                                .onTapGesture {
                                    // Navigate to detail view
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation {
                                            viewModel.removeLocation(location)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    
                    // Add Location Button
                    if viewModel.canAddMoreLocations() {
                        Button(action: { showAddLocation = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Location")
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Last Updated
                    if let lastUpdated = viewModel.lastUpdated {
                        Text("Updated \(lastUpdated.relativeTime())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical)
            }
            .refreshable {
                await viewModel.refreshWeatherData()
            }
            .navigationTitle("Tempestas")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showAddLocation) {
                AddLocationView(viewModel: viewModel)
            }
            .overlay {
                if viewModel.isLoading && viewModel.currentWeather == nil {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading weather...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemBackground).opacity(0.9))
                    .cornerRadius(12)
                }
            }
            .alert("Weather Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
