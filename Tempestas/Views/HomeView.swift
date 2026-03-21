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
    @State private var hasAppeared = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationStack {
            List {
                // Current Location Weather
                if let currentLocation = viewModel.currentLocation {
                    Section {
                        ZStack {
                            CurrentLocationCard(
                                location: currentLocation,
                                weather: viewModel.currentWeather,
                                preferences: settingsViewModel.preferences
                            )
                            NavigationLink(value: currentLocation) {
                                EmptyView()
                            }
                            .opacity(0)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                
                // Saved Locations
                if !viewModel.savedLocations.isEmpty {
                    Section(header: Text("Saved Locations")) {
                        ForEach(viewModel.savedLocations) { location in
                            ZStack {
                                SavedLocationCard(
                                    location: location,
                                    weather: viewModel.savedLocationsWeather[location.id],
                                    preferences: settingsViewModel.preferences
                                )
                                NavigationLink(value: location) {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
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
                    Section {
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
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.clear)
                    }
                }
                
                // Last Updated
                if let lastUpdated = viewModel.lastUpdated {
                    Section {
                        Text("Updated \(lastUpdated.relativeTime())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .refreshable {
                await viewModel.refreshWeatherData()
            }
            .navigationTitle("Tempestas")
            .navigationDestination(for: WeatherLocation.self) { location in
                WeatherDetailView(
                    location: location,
                    viewModel: location.isCurrentLocation ? viewModel : WeatherViewModel(runSetup: false),
                    preferences: settingsViewModel.preferences,
                    onDeleteLocation: { loc in
                        if !loc.isCurrentLocation {
                            viewModel.removeLocation(loc)
                        }
                    }
                )
            }
            .onAppear {
                if hasAppeared {
                    Task { await viewModel.refreshWeatherData() }
                }
                hasAppeared = true
            }
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
            .task {
                ClimateDataPrefetchService.shared.prefetchAllIfNeeded(currentLocation: viewModel.currentLocation)
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    ClimateDataPrefetchService.shared.prefetchAllIfNeeded(currentLocation: viewModel.currentLocation)
                }
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
