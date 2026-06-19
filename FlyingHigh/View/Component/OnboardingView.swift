//
//  OnboardingView.swift
//  FlyingHigh
//
//  Created by Amanda Fonseca Coelho on 18/06/26.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    
    var body: some View {
        ZStack{
            Color(.bgPrimary).ignoresSafeArea()
            VStack {
                VStack(spacing: 30) {
                    Image("onboarding-ilustra")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                    VStack (spacing: 12){
                        Text("Boas Vindas ao Desvio!")
                            .font(.custom("YoungSerif-Regular", size: 34))
                            .lineSpacing(-4)
                            .lineHeight(.multiple(factor: 1.2))
                            .multilineTextAlignment(.center)
                        Text("Saia do óbvio, se desafie e mude a rota dos seus registros")
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: 280)
                    .foregroundStyle(.primaryBrown)
                }
                
                Spacer()
                
                Button {
                    isFirstLaunch = false
                } label: {
                    Text("Começar")
                        .padding(.vertical, 14)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .frame(width: 280)
                        .background(Color.accent, in: RoundedRectangle(cornerRadius: 296))
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.bottom, 28)
            
        }
    }
}

#Preview {
    VStack {
        
    }
    
    .sheet(isPresented: .constant(true)) {
        OnboardingView()
    }
}
