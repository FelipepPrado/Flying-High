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

    var body: some View {
        ZStack {
            Color(.bgPrimary).ignoresSafeArea()
            VStack(spacing: 20) {
                riveViewModel.view()
                    .frame(width: 500, height: 500)
                    .onAppear {
                        riveViewModel.riveModel?.enableAutoBind { instance in
                            
                        }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    AnimationPhotoView()
}
