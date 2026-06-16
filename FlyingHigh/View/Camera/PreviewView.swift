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
    
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                ImageView(image: model.previewImage, descriptionChallenge: true, challengeTitle: model.currentChallengeTitle ?? "Desafio" )
                    .frame(maxWidth: .infinity)
//                    .frame(height: geometry.size.height)
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
                    }
                    
                    Button("2x") {
                        model.camera.setZoom(factor: 2)
                    }
                    
                    Button("3x") {
                        model.camera.setZoom(factor: 3)
                    }
                }
                .foregroundStyle(.white)
                .font(.headline)
                
                //numero de tentativas
                
                //botoes de tirar foto, flash e trocar
                HStack {
                    Button {
                        model.camera.toggleFlash()
                    } label: {
                        Image(systemName: model.camera.flashModeIcon)
                    }
                    Spacer()
                    Button {
                        model.camera.takePhoto()
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
}
