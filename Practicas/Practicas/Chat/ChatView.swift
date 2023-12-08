//
//  ChatView.swift
//  Practicas
//
//  Created by Leo V on 06/12/23.
//

import SwiftUI

struct ChatView: View {
    @StateObject var viewModel: ChatViewModel
    
    var body: some View {
        VStack{
            chatSelection
            ScrollViewReader { scrollView in
                List(viewModel.messages) { message in
                    messageView(for: message)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .id(message.id)
                        .onChange(of: viewModel.messages) {
                            scrollTButtom(scrollView: scrollView)
                        }
                }
                .background(Color(uiColor: .systemGroupedBackground))
                .listStyle(.plain)
                
            }
            messageInputView
        }
        .navigationTitle(viewModel.chat?.topic ?? "Nuevo chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear{
            viewModel.fetchData()
        }
    }
    
    func scrollTButtom(scrollView: ScrollViewProxy) {
        guard !viewModel.messages.isEmpty, let lastMessage = viewModel.messages.last else {
            return }
        
        withAnimation {
            scrollView.scrollTo(lastMessage.id)
        }
    }
    var chatSelection: some View{
        Group{
            if let model = viewModel.chat?.model?.rawValue {
                Text(model)
            } else {
                Picker(selection: $viewModel.selectedModel) {
                    ForEach(ChatModel.allCases, id: \.self) { model in
                        Text(model.rawValue)
                    }
                } label: {
                    Text("")
                        .pickerStyle(.segmented)
                        .padding()
                }
            }
        }
    }
    
    func messageView(for message: AppMessage) -> some View {
        HStack {
            if(message.role == .user){
                Spacer()
            }
            Text(message.text)
                .padding(.horizontal)
                .padding(.vertical, 12)
                .foregroundStyle(message.role == .user ? .white : .black)
                .background(message.role == .user ? .blue : .white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            if(message.role == .assistant){
                Spacer()
            }
        }
    }
    var messageInputView: some View{
        HStack {
            TextField("Envia un mensaje...", text: $viewModel.messageText)
                .padding()
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onSubmit {
                    sendMessage()
                }
            Button{
                sendMessage()
            } label: {
                Text("Enviar")
                    .padding()
                    .foregroundStyle(.white)
                    .bold()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    func sendMessage() {
        Task{
            do{
                try await viewModel.sendMessage()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    ChatView(viewModel: .init(chatId: ""))
}
