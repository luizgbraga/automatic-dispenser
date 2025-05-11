//
//  MainTabView.swift
//  AutomaticDispenser
//
//  Created by Luiz Guilherme Amadi Braga on 08/05/25.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var connectionService = DispenserConnectionService()
    @StateObject private var mockDataService = MockDataService()
    
    var body: some View {
        TabView {
            DeviceDiscoveryView()
                .environmentObject(connectionService)
                .tabItem {
                    Label("Connect", systemImage: "wifi")
                }
            
            DeviceConfigurationView()
                .environmentObject(connectionService)
                .environmentObject(mockDataService)
                .tabItem {
                    Label("Configure", systemImage: "gear")
                }
            
            HistoryView()
                .environmentObject(mockDataService)
                .tabItem {
                    Label("History", systemImage: "clock")
                }
            
            AlertsView()
                .environmentObject(mockDataService)
                .tabItem {
                    Label("Alerts", systemImage: "bell")
                }
        }
        .accentColor(.blue)
        .onAppear {
            NotificationService.shared.requestPermissions()
        }
    }
}

#Preview {
    MainTabView()
}
