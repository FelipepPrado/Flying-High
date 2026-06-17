//
//  FilmCameraView.swift
//  FlyingHigh
//
//  Created by Amanda Fonseca Coelho on 12/06/26.
//

import SwiftUI

struct FilmCameraView: View {
    let filmNumber: Int
    
    var body: some View {
        HStack {
            HStack{
                Text("\(filmNumber)")
                    .font(.system(size: 28, weight: .bold))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(10)
            }
            .frame(width: 38, height: 55)
            .background(Color(.black))
            .padding(.horizontal,6)
        }
        .overlay {
            TrailingBorder()
                .stroke(style: StrokeStyle(lineWidth: 8, dash: [5, 10]))
                .foregroundStyle(.white)
            LeadingBorder()
                .stroke(style: StrokeStyle(lineWidth: 8, dash: [5, 10]))
                .foregroundStyle(.white)
        }
        .frame(width: 58, height: 56)
        .background(Color(.black))
        .overlay{
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.black, lineWidth: 4)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        
    }
}

struct TrailingBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.maxX, y: rect.minY-5))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        
        return path
    }
}

struct LeadingBorder: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY-5))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        
        return path
    }
}

#Preview {
    FilmCameraView(filmNumber: 3)
}
