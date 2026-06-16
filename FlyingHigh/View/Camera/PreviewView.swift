//
//  PreviewView.swift
//  FlyingHigh
//
//  Created by Tainara Nascimento on 15/06/26.
//

import SwiftUI
import Nuvem

struct PreviewView: View {
    @EnvironmentObject var model: CameraModel
    private let footerHeight: CGFloat = 120.0
    @State private var currentZoomFactor: CGFloat = 1.0
    @State private var lastZoomFactor: CGFloat = 1.0
    
    @State private var cameraTimer  = 0
    @State private var countdown: Int?
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ImageView(image: model.previewImage, descriptionChallenge: true, challengeTitle: model.currentChallengeTitle ?? "Desafio" )
                    .frame(maxWidth: .infinity)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                
                                let zoom = lastZoomFactor * value
                                
                                currentZoomFactor = zoom
                                
                                model.camera.setZoom(
                                    factor: currentZoomFactor
                                )
                            }
                            .onEnded { _ in
                                lastZoomFactor = currentZoomFactor
                            }
                    )
                    .padding(.bottom, footerHeight)
                    .overlay(alignment: .bottom) {
                        buttonsView()
                        //define a altura onde os botoes principais estao
                            .frame(height: footerHeight + 100)
                    }
                    .padding(.top, 30)
                    .background(Color.vibrantPrimary)
                
                /* TODO: Picker dos Desafios
                 
                 VStack{
                 Picker("Flavor", selection: $selectedFlavor) {
                 Text("Chocolate").tag(Flavor.chocolate)
                 Text("Vanilla").tag(Flavor.vanilla)
                 Text("Strawberry").tag(Flavor.strawberry)
                 }
                 */
                
                //Filme com a contagem
                VStack{
                    Spacer()
                    HStack{
                        FilmCameraView(filmNumber: model.maxPhotos  - model.photosTaken)
                        Spacer ()
                    }
                    .padding(.bottom, geometry.size.height * 0.28)
                    .padding(.horizontal, geometry.size.width * 0.07)
                    
                }
            }
            
            if let countdown = countdown {
                Text("\(countdown)")
                    .font(.system(size: 100, weight: .bold))
                    .foregroundStyle(.white)
                    .shadow(radius: 10)
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button("Desativado") {
                        cameraTimer = 0
                    }
                    
                    Button("3 segundos") {
                        cameraTimer = 3
                    }
                   
                    Button("5 segundos") {
                        cameraTimer = 5
                    }
                    Button("10 segundos") {
                        cameraTimer = 10
                    }}
                label: {
                    Image(systemName: "timer")
                }
            }
        }

    }
    
    //botoes da camera (tirar foto, zoom, exposicao)
    private func buttonsView() -> some View {
        GeometryReader { geometry in
            let frameHeight = geometry.size.height
            VStack (alignment: .center, spacing: 15) {
                //botoes zoom
                HStack(spacing: 30) {
                    Button("1x") {
                        model.camera.setZoom(factor: 1)
                    }.toggleStyle(.button)
                    
                    Button("2x") {
                        model.camera.setZoom(factor: 2)
                    }
                    
                    Button("3x") {
                        model.camera.setZoom(factor: 3)
                    }
                }
                .foregroundStyle(.white)
                .font(.headline)

                //botoes de tirar foto, flash e trocar
                HStack {
                    Button {
                        model.camera.toggleFlash()
                    } label: {
                        Image(systemName: model.camera.flashModeIcon)
                    }
                    Spacer()
                    Button {
                        startCameraTimer()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: frameHeight - 120,height: frameHeight - 120)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        model.camera.switchCaptureDevice()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                }
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .center)
                
            }
        }
        .padding(.horizontal, 62)
        
    }
    
    func startCameraTimer() {
        guard cameraTimer > 0 else {
            model.camera.takePhoto()
            return
        }
        
        countdown = cameraTimer
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            guard let current = countdown else {
                timer.invalidate()
                return
            }
            
            if current <= 1 {
                timer.invalidate()
                countdown = nil
                model.camera.takePhoto()
            } else {
                countdown = current - 1
            }
            
        }
        
        
    }
    
    
}



