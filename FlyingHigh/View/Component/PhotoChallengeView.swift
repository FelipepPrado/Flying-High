//
//  PhotoChallengeView.swift
//  FlyingHigh
//
//  Created by Amanda Fonseca Coelho on 11/06/26.
//

import SwiftUI

struct PhotoChallengeView: View {
    var status: Int
    var textChallenge: String
    var imageChallenge: UIImage?
    var challengeIcon: UIImage?
    var colorAlbum:  String
    
    var body: some View {
        VStack(spacing: -6){
            HStack {
                Spacer()
                if status == 1 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Color(colorAlbum))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                }
                else {
                    Rectangle()
                        .frame(width: 24, height: 24)
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                        .opacity(0)
                }
            }
            .frame(maxWidth: .infinity)
            VStack(alignment: .center, spacing: 4) {
                Image(uiImage: challengeIcon!)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 111, height: 110)
                    .colorMultiply(status == 1 ? Color(colorAlbum) : Color.secondaryBrown)
                    .padding(.vertical, 10)
                
                VStack(spacing: 0) {
                    if status == 0 {
                        Text("Registre")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.secondaryBrown)
                        Text("\(textChallenge)")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.secondaryBrown)
                    }
                    else {
                        if status == 3 {
                            Text("\(textChallenge)")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.secondaryBrown)
                            Text("Sem Registro")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.secondaryBrown)
                        }
                        else {
                            Text("Revelando")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(colorAlbum))
                            Text("\(textChallenge)")
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(colorAlbum))
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity)
        .aspectRatio(3/4, contentMode: .fit)
        .background(status == 1 ? Color.bgTertiary : Color.secondary.opacity(0))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(status == 1 ? Color(colorAlbum) : Color.secondaryBrown, lineWidth: 2)
        }
        .overlay {
            if status == 2 {
                Rectangle()
                    .fill(.green)
                    .overlay {
                        Image(uiImage: imageChallenge!)
                            .resizable()
                            .scaledToFill()
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .rotationEffect(.degrees(0))
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)
                    .zIndex(999)
            }
        }
    }
}
