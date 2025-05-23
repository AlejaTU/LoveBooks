//
//  UserProfile.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 23/5/25.
//


import Foundation
import FirebaseFirestore

struct UserProfile: Identifiable, Codable {
    @DocumentID var id: String? // UID del usuario (Auth)
    var username: String        // nombre visible
    var email: String           // solo para uso interno si quieres
    var bio: String             // biografía / descripción
    var photoURL: String?       // URL de la foto de perfil (en Storage)
    var followersCount: Int     // número de seguidores
    var followingCount: Int     // número de seguidos
    var reviewsCount: Int       // número de reseñas escritas
}

