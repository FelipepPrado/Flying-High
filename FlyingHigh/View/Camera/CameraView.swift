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
//        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}



