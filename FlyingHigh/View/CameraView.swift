//
//  CameraView.swift
//  FlyingHigh
//
//  Created by Tainara Nascimento on 05/06/26.
//
//
import SwiftUI
import CloudKit
import Nuvem

struct CameraView: View {
    
    var photo: Photo.Observable?

    
    @StateObject private var model = CameraModel()
    let challengeTitle: String  
    
    var body: some View {
        
        ZStack {
            if let capturedPhoto = model.photoToken {
                SaveImageView(
                    photo: photo,
                    capturedPhoto: capturedPhoto.imageData,
                    challengeTitle: challengeTitle
                )
            } else {
                PreviewView()
                    .onAppear {
                        model.camera.isPreviewPaused = false
                    }
                    .onDisappear {
                        model.camera.isPreviewPaused = true
                    }
            }
            
        }
        .task {
            await model.camera.start()
            model.currentChallengeTitle = challengeTitle
        }
        .ignoresSafeArea(.all)
        .environmentObject(model)
    }
}

struct SaveImageView: View {
    @Environment(\.dismiss) var dismiss
    var photo: Photo.Observable?
    var capturedPhoto: Data
    @EnvironmentObject var model: CameraModel
    let challengeTitle: String

    @State private var showAlert = false
    
    @State private var showSendAlert = false
    @State private var showLastAttemptAlert = false
    
    var body: some View {
        NavigationStack {
            ImageView(
                image: model.photoToken?.image,
                popUpChallenge: false,
                challengeTitle: challengeTitle
            )
            .toolbar {
                ToolbarItem (placement: .cancellationAction) {
                    Button {
                        if model.isLastAttempt {
                            showLastAttemptAlert=true
                        }else {
                            model.retryPhoto()
                        }
                        
                    } label: {
                        Image(systemName:"xmark")
                    }
                    .disabled(!model.canTakePhoto)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("", systemImage: "checkmark") {
                        showSendAlert=true
                        print(showAlert)
                        print("Save Photo")
                    }
                }
            }
            .navigationTitle("Nome do Desafio")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(
            "Deseja enviar esta foto?",
            isPresented: $showSendAlert
        ) {
            Button("Cancelar",role: .cancel) {}
            
            Button("Enviar") {
                Task{
                    await save()
                }
            }
        }message: {
            Text("Após o envio não será possível tirar novas fotos.")
        }
        
    }
    
    func save() async{
        do{
            photo?.data = capturedPhoto
            try await photo?.save(on: .private)
            dismiss()
        }
        catch{
           print(error)
        }
    }
}

struct ImageView: View {
    var image: Image?
    var popUpChallenge: Bool
    let challengeTitle: String
    
    @EnvironmentObject var model: CameraModel
    @State private var showLastAttemptAlert = false
    
    var body: some View {
        NavigationStack{
            GeometryReader { geometry in
                VStack{
                    if let image = image {
                        image
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 20)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
                .background(Color.vibrantPrimary)
            }
            .navigationTitle(challengeTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.vibrantPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .alert(
            "Última tentativa",
            isPresented: $showLastAttemptAlert
        ) {
            Button("Voltar",role: .cancel) {}
            
            Button("Continuar") {
                model.retryPhoto()
            }
            
        }message: {
            Text("Esta será sua última tentativa de foto.")
        }
        .background(Color.vibrantPrimary)
    }
}

struct PreviewView: View {
    @EnvironmentObject var model: CameraModel
    private let footerHeight: CGFloat = 180.0
    @State private var currentZoomFactor: CGFloat = 1.0
    @State private var lastZoomFactor: CGFloat = 1.0
    
    var body: some View {
        ImageView(image: model.previewImage, popUpChallenge: true, challengeTitle: model.currentChallengeTitle ?? "Desafio" )
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
    }
    
    //botoes da camera (tirar foto, zoom, exposicao)
    private func buttonsView() -> some View {
        GeometryReader { geometry in
            let frameHeight = geometry.size.height
            VStack (alignment: .center, spacing: 15) {
                
                //slider exposicao
                HStack {
                    Image(systemName:"sun.min")
                    Slider(
                        value:Binding(
                            get: {
                                Double(model.exposureValue)
                            },
                            set: {newValue in
                                model.exposureValue=Float(newValue)
                                
                                model.camera.setExposure(
                                    bias:model.exposureValue
                                )
                            }
                        ),
                        in:-2...2
                    )
                    Image(systemName:"sun.max")
                }
                
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
                }.font(.headline)
                
                //numero de tentativas
                HStack{
                    Text("\(model.photosTaken)/\(model.maxPhotos) Tentativas")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(10)
                .background(.gray.opacity(0.3))
                .cornerRadius(5)
                
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
                                .frame(width: frameHeight - 200,height: frameHeight - 200)
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
