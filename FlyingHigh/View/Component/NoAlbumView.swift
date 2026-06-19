//
//  NoAlbumView.swift
//  FlyingHigh
//
//  Created by Amanda Fonseca Coelho on 18/06/26.
//

import SwiftUI

struct NoAlbumView: View {
    var body: some View {
        VStack{
            VStack(spacing: 10){
                Image("no-album")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 254, height: 249)
                    .padding(.vertical, 10)
                    .accessibilityHidden(true)
                VStack(spacing: 8){
                    Text("Parece que você ainda não criou uma experiência")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.description)
                    Text("Clique no + para criar uma experiência")
                        .accessibilityLabel(Text("Clique no 'adicionar experiência' para criar uma experiência"))
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.description)
                }
                .frame(maxWidth: 235)
            }
            .padding(.bottom, 80)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NoAlbumView()
}
