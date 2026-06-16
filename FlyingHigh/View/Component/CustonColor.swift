//
//  CustonColor.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 16/06/26.
//

import SwiftUI

struct CustonColor: View {
    @State private var colors: Color = .blue
    var body: some View {
        
        VStack(spacing: 20) {

            // 2. O ColorPicker nativo
            RoundedRectangle(cornerRadius: 50)
                .fill(colors)
                .frame(width: 150, height: 150)
        }
            ColorPicker("Escolha uma cor", selection: $colors)
                .padding()
           
    }
}

#Preview {
    CustonColor()
    }
