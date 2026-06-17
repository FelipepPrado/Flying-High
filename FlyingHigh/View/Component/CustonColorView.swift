//
//  CustonColorView.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 17/06/26.
//
import SwiftUI

struct CustonColorView: View {
    // 1. Defini suas cores personalizadas com os valores RGB corretos que você queria
    let corRed = Color(red: 207/255, green: 109/255, blue: 131/255)
    let corBlue = Color(red: 135/255, green: 168/255, blue: 184/255)
    let corPurple = Color(red: 147/255, green: 136/255, blue: 187/255)
    let corGreen = Color(red: 127/255, green: 161/255, blue: 144/255)

    // 2. Agora guardamos o INDEX (número) da cor selecionada, começando em 0
    @State private var selectedColorIndex: Int = 0
    
    // 3. Juntei suas cores personalizadas dentro de uma array para o loop usar
    private var colors: [Color] {
        return [corRed, corBlue, corPurple, corGreen]
    }
    
    var body: some View {
        // O VStack organiza tudo verticalmente na tela
        VStack(spacing: 20) {
            Text("Lista de cores")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                // Percorre os índices da nossa array de cores (0 até 3)
                ForEach(colors.indices, id: \.self) { index in
                    Circle()
                        .fill(colors[index])
                        .frame(width: 70, height: 70)
                        .overlay(
                            Circle()
                                // Se o index atual for o selecionado, mostra a borda
                                .stroke(Color.primary, lineWidth: selectedColorIndex == index ? 4 : 0)
                        )
                        .onTapGesture {
                            // Quando clica, atualiza o estado com o número da bola clicada
                            selectedColorIndex = index
                        }
                }
                
            }
            .padding()
            
            Text("Cor Selecionada:")
                .font(.subheadline)
            
            // 4. O retângulo agora pega dinamicamente a cor da array usando o index salvo
            Rectangle()
                .fill(colors[selectedColorIndex])
                .frame(width: 80, height: 80) // Aumentei um pouquinho para ficar mais visível
                .cornerRadius(8)
        }
        .padding()
    }
}

#Preview {
    CustonColorView()
}
