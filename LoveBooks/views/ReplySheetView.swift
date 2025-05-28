import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ReplySheetView: View {
    let parentReviewID: String
    @Environment(\.dismiss) var dismiss
    @State private var replyText: String = ""

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Responder a la reseña")
                    .font(.headline)

                TextEditor(text: $replyText)
                    .frame(height: 150)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))

                Spacer()

                Button("Enviar respuesta") {
                    Task {
                        await sendReply()
                        dismiss()
                    }
                }
                .disabled(replyText.trimmingCharacters(in: .whitespaces).isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Responder")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func sendReply() async {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()

        let userDoc = try? await db.collection("users").document(currentUser.uid).getDocument()
        let username = userDoc?.get("username") as? String ?? "Usuario"
        let photoURL = userDoc?.get("photoURL") as? String

        let reply: [String: Any] = [
            "id": UUID().uuidString,
            "parentID": parentReviewID,
            "userID": currentUser.uid,
            "content": replyText.trimmingCharacters(in: .whitespacesAndNewlines),
            "date": Date(),
            "username": username,
            "photoURL": photoURL ?? ""
        ]

        do {
            try await db.collection("replies").addDocument(data: reply)
        } catch {
            print("❌ Error al enviar la respuesta:", error.localizedDescription)
        }
    }
}
