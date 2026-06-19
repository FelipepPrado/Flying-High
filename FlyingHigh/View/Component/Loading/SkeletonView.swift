//
//  SkeletonView.swift
//  FlyingHigh
//
//  Created by Amanda Fonseca Coelho on 18/06/26.
//

import SwiftUI

struct SkeletonView: View {
    @State private var animationOffset: CGFloat = -1
 
    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.primaryBrown.opacity(0.1))
                .overlay(
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color.bgTertiary.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: animationOffset * geometry.size.width)
                )
                .clipped()
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animationOffset = 2
            }
        }
    }
}

#Preview {
    SkeletonView()
}

