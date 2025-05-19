//
//  SplashView.swift
//  LoveBooks
//
//  Created by Alejandra Torres on 19/5/25.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    
    var body: some View {
        if isActive {
            //vista real que sera login
            SignUpView()
        } else {
            
            VStack {
                Spacer()
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    
                    }

                }
            }
        }
    }
}

#Preview {
    SplashView()
}
