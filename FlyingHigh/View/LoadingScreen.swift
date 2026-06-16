//
//  LoadingScreen.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 15/06/26.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        VStack{
            ProgressView()
            Text("Carregando...")
        }

    }
}

#Preview {
    LoadingScreen()
}
