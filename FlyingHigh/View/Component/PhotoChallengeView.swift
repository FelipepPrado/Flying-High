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
    var imageChallenge: UIImage
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: -6){
                HStack {
                    Spacer()
                    if status == 0 {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color(.blue), lineWidth: 2)
                            .frame(width: 24, height: 24)
                            .padding(10)
                    }
                    else {
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(.secondary)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(10)
                    }
                    
                }
                .frame(maxWidth: .infinity)
                VStack {
                    VStack(alignment: .center) {
                        if status == 0 {
                            Image(systemName: "camera")
                                .font(.system(size: 44, weight: .light))
                                .foregroundStyle(Color.accentColor)
                        }
                        else {
                            Image(systemName: "film")
                                .font(.system(size: 44, weight: .light))
                                .foregroundStyle(Color.secondary.tertiary)
                        }
                        
                    }
                    .frame(maxHeight: .infinity)
                    VStack(spacing: 0) {
                        if status == 0 {
                            Text("Registre")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                            Text("\(textChallenge)")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.accentColor)
                        }
                        else {
                            Text("Registre")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.secondary)
                            Text("\(textChallenge)")
                                .fontWeight(.medium)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                .aspectRatio(3/4, contentMode: .fit)
                .padding(.horizontal, 16)
                .padding(.bottom, 28)
                
                
            }
            .frame(maxWidth: .infinity)
            .frame(height: 232)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay{
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(status == 0 ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: 2)
            }
            .overlay {
                if status == 2 {
                    Rectangle()
                        .fill(.green)
                        .overlay {
                            Image(uiImage: imageChallenge)
                                .resizable()
                                .scaledToFill()
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .rotationEffect(.degrees(6))
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 2)
                        .zIndex(999)
                    
                }
                
            }
        }
    }
}
