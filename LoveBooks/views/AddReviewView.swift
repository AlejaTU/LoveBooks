import SwiftUI

struct AddReviewView: View {
    @Environment(\.dismiss) private var dismiss

    let book: Book?

    let onPublished: () -> Void
    @State private var title = ""
    @State private var content = ""

    @State private var reviewVM = ReviewViewModel()

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !content.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.whitebreak).ignoresSafeArea()

                VStack(spacing: 16) {
                    TextField("Título de la reseña", text: $title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)

                    Divider()

                    TextEditor(text: $content)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 1)
                        .frame(maxHeight: .infinity)
                        .onChange(of: content) {
                            if content.count > 1000 {
                                content = String(content.prefix(1000))
                            }
                        }

                    if !reviewVM.errorMessage.isEmpty {
                        Text(reviewVM.errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding()
                .navigationTitle("Nueva reseña")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancelar") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        if reviewVM.isLoading {
                            ProgressView()
                        } else {
                            Button("Publicar") {
                                Task {
                                    let success = await reviewVM.publishReview(
                                        bookID: book?.id,
                                        bookTitle: book?.title,
                                        reviewTitle: title,
                                        content: content
                                    )

                                    if success {
                                        onPublished()
                                        dismiss()
                                    }
                                }
                            }
                            .disabled(!isFormValid)
                        }
                    }
                }
            }
        }
    }
}

