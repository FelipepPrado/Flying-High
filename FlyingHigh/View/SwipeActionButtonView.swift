//
//  SwipeActionButtonView.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 09/06/26.
//

import SwiftUI

struct SwipeActionButtonView: View {
    @State var x: [CGFloat] = [0,0,0,0,0,0,0] //-> 7 cartas num array
    @State var Degree: [CGFloat] = [8,8,8,7,6,6,20] //-> Inclinação das cartas
    @State var isActive: Bool = false
    
    
    @State var buttonLeftColor: Color = .gray
    @State var buttonRighttColor: Color = .gray
    @State var topCard: Int = 7
    
    var body: some View {
        
        //                Text("\(challenge.title)")
        
        VStack  {
            ZStack{
                ForEach(0..<topCard, id: \.self){i in
                    Card()
                        .offset(x: self.x[i])
                        .rotationEffect(.init(degrees: self.Degree[i]))
                        .gesture(DragGesture()
                            .onChanged({(value) in
                                if value.translation.width>0{
                                    self.x[i] = value.translation.width
                                    self.Degree[i] = 10
                                    self.buttonRighttColor = .blue
                                    self.buttonLeftColor = .gray
                                    
                                    
                                } else{
//                                    print(value.translation.width)
                                    self.x[i] = value.translation.width
                                    self.Degree[i] = -8
                                    self.buttonRighttColor = .red
                                    self.buttonLeftColor = .gray
                                    
                                }
                            }
                                       
                                      )
                                .onEnded({(value) in
//                                    guard i == topCard else { return }
                                    if value.translation.width>0 {
                                        if value.translation.width > 100{
                                            self.x[i] = 500
                                            self.Degree[i] = 10
                                            activateRightButton()
                                        }else{
                                            self.x[i] = 0
                                            self.Degree[i] = 0
                                        }
                                    } else {
                                        if value.translation.width < -100{
                                            self.x[i] = -500
                                            self.Degree[i] = -15
                                        }else{
                                            self.x[i] = 0
                                            self.Degree[i] = 0
                                        }
                                    }
                                    
                                }
                                         
                                        )
                                 
                                 
                                 
                        )}
            } .padding(60)
            
                .animation(.default, value: x)
            
            //Lógica:
            //Se passar para o lado direito, então o botão "levar carta" fica azul
            //Se passar para o lado esquerto, então o botão "deixar passar" fica vermelho
            HStack(spacing: 50) {
                Button {
                    swipeLeft(index: topCard)
                   
                    
                } label: {
                    Text("Deixar passar")
                        .frame(width: 130, height: 40)
                }
                .foregroundStyle(Color(.systemBackground))
                .fontWeight(.heavy)
                .background{
                    Rectangle()
                        .fill(buttonLeftColor)
                        .frame(width: 130, height: 40)
                        .foregroundColor(.black)
                        .shadow(radius: 6)
                        .cornerRadius(6)
                        .padding(10)
                }
                
                Button{
                    swipeRight(index: topCard)
                    
                } label: {
                    Text("Levar carta")
                        .frame(width: 125, height: 40)
                }
                .foregroundStyle(Color(.systemBackground))
                .fontWeight(.heavy)
                .background(){
                    Rectangle()
                        .fill(buttonRighttColor)
                        .frame(width: 125, height: 40)
                        .foregroundColor(.black)
                        .shadow(radius: 6)
                        .cornerRadius(6)
                        .padding(10)
                    
                }
                
            }
            
            
        }
        
        
        
    }
    
    //Função para jogar o card para esquerda
    func swipeLeft(index: Int){
        print(index)
        guard index >= 0 else {return}
        topCard -= 1
        var index = topCard
        print(index)
        
        withAnimation {
            self.x[index] = -500
            self.Degree[index] = -15
            self.buttonLeftColor = .red
//            self.buttonRighttColor = .gray
        }
        activeLeftButton()

    }
    //Função para jogar a carta para a direita
    func swipeRight(index: Int){
        print(index)
        guard index >= 0 else {return}
        topCard -= 1
        var index = topCard
        print(index)
        
        withAnimation {
            self.x[index] = 500
            self.Degree[index] = 10
//            self.buttonLeftColor = .gray
        }
        
        activateRightButton()
        
        
    }
    
    func activateRightButton() {
        self.buttonRighttColor = .blue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.buttonRighttColor = .gray
        }
    }
    func activeLeftButton(){
        self.buttonLeftColor = .red
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.buttonRighttColor = .gray
        }

    }
    
    
    
}

//Struct responsável pelos cards
struct Card: View{
    var body: some View{
        Rectangle()
            .fill(.white)
            .frame(width: 300, height: 300)
            .cornerRadius(10)
            .shadow(radius: 6)
    }
}
#Preview {
    SwipeActionButtonView()
}
