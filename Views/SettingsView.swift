//
//  SettingsView.swift
//  Tempestas
//
//  Created by Gary Garrison on 12/28/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Units Section
                Section("Units") {
                    Picker("Temperature", selection: $viewModel.preferences.temperatureUnit) {
                        ForEach(TemperatureUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .onChange(of: viewModel.preferences.temperatureUnit) { _, newValue in
                        viewModel.updateTemperatureUnit(newValue)
                    }
                    
                    Picker("Wind Speed", selection: $viewModel.preferences.windSpeedUnit) {
                        ForEach(WindSpeedUnit.allCases, id: \.self) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    .onChange(of: viewModel.preferences.windSpeedUnit) { _, newValue in
                        viewModel.updateWindSpeedUnit(newValue)
                    }
                    
                    Picker("Time Format", selection: $viewModel.preferences.timeFormat) {
                        ForEach(TimeFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .onChange(of: viewModel.preferences.timeFormat) { _, newValue in
                        viewModel.updateTimeFormat(newValue)
                    }
                }
                
                // MARK: - Permissions Section
                Section("Permissions") {
                    Button("Location Access") {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                            openURL(settingsUrl)
                        }
                    }
                }
                
                // MARK: - About Section
                Section("About") {
                    Link("WeatherKit Data", destination: URL(string: "https://weatherkit.apple.com")!)
                    Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                    Link("Terms of Use", destination: URL(string: "https://example.com/terms")!)
                    Link("Contact Support", destination: URL(string: "mailto:support@example.com")!)
                }
                
                // MARK: - App Version
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView()
}
