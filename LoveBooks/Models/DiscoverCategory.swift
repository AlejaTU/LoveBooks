//
//  DiscoverCategory.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 27/5/25.
//

import Foundation
import SwiftUI

struct DiscoverCategory: Identifiable {
    let id: String
    let title: String         // Título visible en la tarjeta
    let color: Color          // Color principal (para fondo y texto)
    let icon: String          // Nombre del SF Symbol (ícono)
    let query: String         // Texto clave que usaremos para buscar libros en la API
}


