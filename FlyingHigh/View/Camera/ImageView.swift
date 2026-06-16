//
//  ImageView.swift
//  FlyingHigh
//
//  Created by Tainara Nascimento on 15/06/26.
//

import SwiftUI

struct ImageView: View {
    var image: Image?
    var descriptionChallenge: Bool
    let challengeTitle: String
    
    @EnvironmentObject var model: CameraModel
    @State private var showLastAttemptAlert = false
    
    var body: some View {
        GeometryReader { geometry in
      
                VStack{
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                    }
                    
                    
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height)
                .padding(.horizontal, 20)
                .background(Color.vibrantPrimary)

            
        }
        .navigationTitle(challengeTitle)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.vibrantPrimary, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .alert(
            "Última tentativa",
            isPresented: $showLastAttemptAlert
        ) {
            Button("Voltar",role: .cancel) {}
            
            Button("Continuar") {
                model.retryPhoto()
            }
        }message: {
            Text("Esta será sua última tentativa de foto.")
        }
        .background(Color.vibrantPrimary)
    }
}
