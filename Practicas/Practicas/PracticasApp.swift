//
//  PracticasApp.swift
//  Practicas
//
//  Created by Leo V on 06/12/23.
//

import SwiftUI

@main
struct PracticasApp: App {
    @ObservedObject var appState: AppState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn{
                NavigationStack(path: $appState.navigationPath){
                    ChatListView()
                        .environmentObject(appState)
                }
               // ContentView()
            } else {
                AuthView()
                    .environmentObject(appState)
            }
        }
    }
}
