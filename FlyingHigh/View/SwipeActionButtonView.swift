//
//  SwipeActionButtonView.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 09/06/26.
//

import SwiftUI

struct SwipeActionButtonView: View {
    @State var x: [CGFloat] = [0,0,0,0,0,0,0]
    @State var Degree: [CGFloat] = [0,0,0,0,8,9,-10]
    @State var isActive: Bool = false

    var body: some View {
        
//                Text("\(challenge.title)")
        
        VStack  {
            ZStack{
                ForEach(0..<7, id: \.self){i in
                    Card()
                        .offset(x: self.x[i])
                        .rotationEffect(.init(degrees: self.Degree[i]))
                    
                        .gesture(DragGesture()
                            .onChanged({(value) in
                                if value.translation.width>0{
                                    self.x[i] = value.translation.width
                                    self.Degree[i] = 10
                                    
                                    
                                } else{
                                    print(value.translation.width)
                                    self.x[i] = value.translation.width
                                    self.Degree[i] = -8
                                    
                                }
                                
                                
                            }
                                                                              
                                       
                                      )
                                .onEnded({(value) in
                                    if value.translation.width>0 {
                                        if value.translation.width > 100{
                                            self.x[i] = 500
                                            self.Degree[i] = 10
                                        }else{
                                            self.x[i] = 0
                                            self.Degree[i] = 0
                                        }
                                    } else {
                                        if value.translation.width < 100{
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

                .animation(.default)
            
            
            HStack(spacing: 50) {
                Button {
                   
                    
                } label: {
                    Text("Deixar passar")
                }
                .foregroundStyle(Color(.systemBackground))
                .fontWeight(.heavy)
                .background{
                    Rectangle()
                        .fill(.gray)
                        .frame(width: 130, height: 40)
                        .foregroundColor(.black)
                        .shadow(radius: 6)
                        .cornerRadius(6)
                        .padding(10)
                }
                
                
                
                
                
                Button{
                    
                    
                } label: {
                    Text("Levar carta")
                }
                .foregroundStyle(Color(.systemBackground))
                .fontWeight(.bold)
                .background(){
                    Rectangle()
                        .fill(.gray)
                        .frame(width: 130, height: 40)
                        .foregroundColor(.black)
                        .shadow(radius: 6)
                        .cornerRadius(6)
                        .padding(10)
                }
                
            }

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
