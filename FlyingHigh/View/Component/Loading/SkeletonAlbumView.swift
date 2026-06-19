//
//  SkeletonAlbumView.swift
//  FlyingHigh
//
//  Created by Amanda Fonseca Coelho on 18/06/26.
//

import SwiftUI

struct SkeletonAlbumView: View {
    var body: some View {
        ZStack {
            Color(.bgPrimary).ignoresSafeArea()
            VStack(spacing: 26) {
                SkeletonView()
                    .frame(height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 10)
                
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)], spacing: 20){
                    SkeletonCardView()
                    SkeletonCardView()
                    SkeletonCardView()
                    SkeletonCardView()
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct SkeletonCardView: View {
    var body: some View {
        VStack(spacing: 30) {
            SkeletonView()
                .frame(width: 83,height: 83)
                .clipShape(RoundedRectangle(cornerRadius: 42))
            VStack(spacing: 7) {
                SkeletonView()
                    .frame(width: 72,height: 14)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                SkeletonView()
                    .frame(width: 50, height: 14)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.top, 52)
        .padding(.bottom, 32)
        .frame(maxWidth: .infinity)
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.primaryBrown.opacity(0.1), lineWidth: 2)
        }
    }
}

#Preview {
    SkeletonAlbumView()
}
