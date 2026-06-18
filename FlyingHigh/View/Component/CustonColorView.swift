//
//  CustonColorView.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 17/06/26.
//
import SwiftUI

struct CustonColorView: View {
    @Binding var selectedColor: String
    
    private var colors: [ColorName] {
        return [ColorName.userRed, ColorName.userBlue, ColorName.userGreen, ColorName.userPurple]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cor")
                .fontWeight(.semibold)
            HStack{
                ForEach(colors, id: \.self) { color in
                    Circle()
                        .fill(Color(color.stringColor))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(Color(color.stringColor), lineWidth: selectedColor == color.stringColor ? 6 : 0)
                                .stroke(.white, lineWidth: selectedColor == color.stringColor ? 2 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color.stringColor
                        }
                }
            }
        }
    }
    
    enum ColorName: String, CaseIterable {
        case userRed
        case userBlue
        case userGreen
        case userPurple
        
        var stringColor: String {
            switch self {
            case .userRed:
                return "user-red"
            case .userBlue:
                return "user-blue"
            case .userPurple:
                return "user-purple"
            case .userGreen:
                return "user-green"
            }
        }
    }
}

//#Preview {
//    CustonColorView()
//}
