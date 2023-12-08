//
//  AuthView.swift
//  Practicas
//
//  Created by Leo V on 06/12/23.
//

import SwiftUI

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel = AuthViewModel()
    @EnvironmentObject var appState: AppState
    
    
    var body: some View {
        VStack{
            Text("Practicas")
                .font(.title)
                .bold()
            
            TextField("Correo electrónico", text: $viewModel.emailText)
                .padding()
                .background(Color.gray.opacity(0.1))
                .textInputAutocapitalization(.never)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if viewModel.isPasswordVisible{
                SecureField("Contraseña", text: $viewModel.passwordText)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .textInputAutocapitalization(.never)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            if viewModel.isLoading{
                ProgressView()
            }else{
                Button {
                    viewModel.authenticate(appState: appState)
                } label: {
                    Text(viewModel.userExists ? "Iniciar":"Crear usuario")
                }
                .padding()
                .foregroundStyle(.white)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }

        }
        .padding()
    }
}

#Preview {
    AuthView()
}
