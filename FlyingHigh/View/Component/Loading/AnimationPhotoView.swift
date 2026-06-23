//
//  AnimationPhotoView.swift
//  FlyingHigh
//
//  Created by Amanda Fonseca Coelho on 19/06/26.
//

import SwiftUI
import RiveRuntime

struct AnimationPhotoView: View {
    @StateObject private var riveViewModel = RiveViewModel(
        fileName: "animation-photo",
        stateMachineName: "State Machine 1"
    )
    enum focusInAccessibility{
        case loading
    }
    
    @AccessibilityFocusState private var focusLoading: AnimationPhotoView.focusInAccessibility?
    
    var body: some View {
        ZStack {
            Color(.bgPrimary).ignoresSafeArea()
            Group {
                VStack(spacing: 20) {
                    riveViewModel.view()
                        .frame(width: 500, height: 500)
                        .onAppear {
                            riveViewModel.riveModel?.enableAutoBind { instance in
                            }
                        }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                    focusLoading = .loading
                }
            }

            //            .accessibilityLabel(Text("Carregandon seu álbum..."))
            .accessibilityValue(Text("Carregando sua foto..."))
            .accessibilityElement(children: .combine)
        }
        .navigationBarBackButtonHidden(true)
    }
}
#Preview {
    AnimationPhotoView()
}
