//
//  AppState.swift
//  Practicas
//
//  Created by Leo V on 06/12/23.
//

import Foundation
import FirebaseAuth
import SwiftUI
import Firebase

class AppState: ObservableObject { //si se ha iniciado sesión la aplicación se mantiene con la sesión
    @Published var currentUser: User?
    @Published var navigationPath = NavigationPath()
    
    var isLoggedIn: Bool{
        return currentUser != nil
    }
    init(){
        FirebaseApp.configure()
        
        if let currentUser = Auth.auth().currentUser{
            self.currentUser = currentUser
        }
    }
    
}
