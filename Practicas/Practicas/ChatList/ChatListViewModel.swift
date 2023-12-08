//
//  ChatListViewModel.swift
//  Practicas
//
//  Created by Leo V on 06/12/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import OpenAI

class ChatListViewModel: ObservableObject {
    @Published var chats: [AppChat] = []
    @Published var loadingState: chatListState = .none
    @Published var isShowingProfileView = false
    
    private let db = Firestore.firestore()
    
    func fetchData(user: String?){
        /*
        self.chats = [AppChat(id: "1", topic: "Some topic", model: .gpt3_5_turbo, lastMessageSent: Date(), owner: "123"),
                      AppChat(id: "2", topic: "Some other topic", model: .gpt4, lastMessageSent: Date(), owner: "123")]
        self.loadingState = .resultFound
         */
        
        if loadingState == .none {
            loadingState = .loading
            db.collection("chats").whereField("owner", isEqualTo: user ?? "").addSnapshotListener{ [ weak self] querySnapshot, error in
                guard let self = self, let documents = querySnapshot?.documents, !documents.isEmpty else {
                    self?.loadingState = .noResult
                    return
                }
                self.chats = documents.compactMap({ snapshot -> AppChat?  in
                    return try? snapshot.data(as: AppChat.self)
                })
                .sorted(by: {$0.lastMessageSent > $1.lastMessageSent})
                self.loadingState = .resultFound
            }
        }
        
    }
    
    func createChat(user: String?) async throws -> String {
        let document = try await db.collection("chats").addDocument(data: ["lastMessageSent": Date(), "owner": user ?? ""])
        return document.documentID
    }
    
    func showProfile(){ //muestra el perfil
        isShowingProfileView = true
        
    }
    
    func deleteChat(chat: AppChat){ // eliminar la conversación elegida, deslizando esta a la izquierda
        guard let id = chat.id else {
            return
        }
        db.collection("chats").document(id).delete()
    }
}

enum chatListState {
    case none
    case loading
    case noResult
    case resultFound
}

struct AppChat: Codable, Identifiable {
    @DocumentID var id: String?
    let topic: String?
    var model: ChatModel?
    let lastMessageSent: FirestoreDate
    let owner: String
    
    var lastMessageTimeAgo: String {
        let now = Date() //toma la fecha actual
        let components = Calendar.current.dateComponents([.second, .minute, .hour, .day,.month, .year], from: lastMessageSent.date, to: now)
        
        let timeUnits: [(value: Int?, unit: String)] = [
            (components.year, "year"),
            (components.month, "month"),
            (components.day, "day"),
            (components.hour, "hour"),
            (components.minute, "minute"),
            (components.second, "second")
        ]
        
        for timeUnit in timeUnits { //muestra hace cuanto tiempo se creo la conversación
            if let value = timeUnit.value, value > 0 {
                return "\(value) \(timeUnit.unit)\(value == 1 ? "" : "s") ago"
            }
        }
        return "just now"
    }
}

enum ChatModel: String, Codable, CaseIterable, Hashable {
    case gpt3_5_turbo = "GPT 3.5 Turbo"
    case gpt4 = "GPT 4"
    
    var tintColor: Color{ //de acuerdo a la elección del modelo se cambia el color
        switch self {
        case .gpt3_5_turbo:
            return .green
        case .gpt4:
            return .purple
        }
    }
    
    var model: Model{ //se selecciona el modelo para la conversación
        switch self {
        case .gpt3_5_turbo:
            return .gpt3_5Turbo
        case .gpt4:
            return .gpt4
        }
    }
}


struct FirestoreDate: Codable, Hashable, Comparable {
    var date: Date
    
    init(_ date: Date = Date()) {
        self.date = date
    } // crea la instancia y le asigna la fecha actual
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let timestamp = try container.decode(Timestamp.self)
        date = timestamp.dateValue()
    } // decodifica el valor de la fecha
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let timestamp = Timestamp(date: date)
        try container.encode(timestamp)
    } //codifica el valor de la fecha y lo envia a la instancia en firebase
    
    static func < (lhs: FirestoreDate, rhs: FirestoreDate) -> Bool {
        lhs.date < rhs.date
    } //compara las fechas almacenads
}
