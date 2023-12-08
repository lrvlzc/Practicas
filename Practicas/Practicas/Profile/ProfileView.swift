//
//  ProfileView.swift
//  Practicas
//
//  Created by Leo V on 06/12/23.
//

import SwiftUI

struct ProfileView: View {
    @State var apiKey: String = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    
    var body: some View {
        List {
            Section("OpenAI API Key") {
                TextField("Enter Key", text: $apiKey) {
                    UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
                    
                }
            }
        }
    }
}

#Preview {
    ProfileView()
}
