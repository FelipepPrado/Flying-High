//
//  SaveImageView.swift
//  FlyingHigh
//
//  Created by Tainara Nascimento on 15/06/26.
//

import SwiftUI
import SwiftData
import Nuvem
import CloudKit
import UIKit

struct SaveImageView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var photo: PhotoModel?
    var capturedPhoto: Data
    @EnvironmentObject var model: CameraModel
    let challengeTitle: String
    @State private var photoDescription = ""
    private let footerHeight: CGFloat = 150.0
    @State private var showSendAlert = false
    @State private var showAlertCloudKit = false
    @State private var showLastAttemptAlert = false
    @State private var loadingCloudKit = false
    @FocusState private var isDescriptionFocused: Bool
    @State private var placeholder: String = "Descreva a sua foto:"


    
    var body: some View {
        insideView
    }
    
    var insideView: some View {
        Group{
            if loadingCloudKit{
                AnimationPhotoView()
            }
            else{
                GeometryReader { geometry in
                    ZStack {
                        VStack {
                            ImageView(
                                image: model.photoToken?.image
                            )
                            .frame(height: geometry.size.height * 0.6)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                ZStack {
                                    if photoDescription.isEmpty {
                                        TextEditor(text:$placeholder)
                                            .font(.body)
                                            .frame(height: isDescriptionFocused ? 80 : 80)
                                            .padding()
                                        
                                            .scrollContentBackground(.hidden)
                                            .background(.bgTertiary)
                                            .cornerRadius(10)
                                            .foregroundColor(.gray)
                                            .disabled(true)
                                        
                                    }
                                    
                                    TextEditor(text: $photoDescription)
                                        .focused($isDescriptionFocused)
                                        .frame(height: isDescriptionFocused ? 80 : 80)
                                        .padding()
                                        .scrollContentBackground(.hidden)
                                        .background(.bgTertiary)
                                        .foregroundStyle(.primaryBrown)
                                        .opacity(photoDescription.isEmpty ? 0.25 : 1)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                    
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 15)
                            .offset(
                                y: isDescriptionFocused ? -(geometry.size.height * 0.25) : 0
                            )
                        }
                        .animation(.easeInOut(duration: 0.3), value: isDescriptionFocused)

                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                .background(Color.cameraBg)
                .onTapGesture {
                    dismissKeyboard()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            if model.isLastAttempt {
                                showLastAttemptAlert = true
                            } else {
                                model.retryPhoto()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .disabled(!model.canTakePhoto)
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showSendAlert = true
                        } label: {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    
//                    ToolbarItem(placement: .bottomBar) {
//                        Button("Enviar Foto"){
//                            showSendAlert = true
//                        }
//                        .padding(.horizontal, 32)
//                        .padding(.vertical, 4)
////                        .buttonStyle(.borderedProminent)
//                        .tint(.accent)
//                        .foregroundStyle(.white)
//
//                    }
                    
                    ToolbarItem(placement: .principal) {
                        Text(challengeTitle)
                            .font(.custom("YoungSerif-Regular", size: 17))
                            .foregroundStyle(.bgTertiary)
                    }
                }
//                .navigationTitle(challengeTitle)
//                .toolbarColorScheme(.dark, for: .navigationBar)
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarBackButtonHidden(true)
                .alert("iCloud possivelmente Cheio", isPresented: $showAlertCloudKit){
                    Button("Confirmar", role: .confirm){
                        dismiss()
                    }
                } message: {
                    Text("Tente novamente assim que tiver com armazenamento disponível no iCloud.")
                }
                .alert("Deseja enviar esta foto?", isPresented: $showSendAlert) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Enviar") {
                        loadingCloudKit = true
                        photo?.data = capturedPhoto
                        photo?.descriptionPhoto = photoDescription
                        do{
                            try modelContext.save()
                        } catch{
                            print("Não salvou no CloudKit")
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            loadingCloudKit = false
                            dismiss()
                        }
                        
//                        dismiss()
//                        loadingCloudKit = false
                    }
                } message: {
                    Text("Após o envio não será possível tirar novas fotos.")
                }
                .alert("Última tentativa", isPresented: $showLastAttemptAlert) {
                    Button("Cancelar", role: .cancel) {}
                    Button("Tentar novamente") {
                        model.retryPhoto()
                    }
                } message: {
                    Text("Esta é sua última tentativa. Deseja tentar novamente?")
                }
                
            }
        }
    }
    
//    func save() async {
//        loadingCloudKit = true
//        do {
//            photo?.data = capturedPhoto
//            photo?.descriptionPhoto = photoDescription
//            
//            try await photo?.save(on: .private)
//            dismiss()
//        } catch let error as CKError{
//            handleCkError(error: error.code)
//        } catch{
//            print(error)
//        }
//        loadingCloudKit = false
//    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func handleCkError(error: CKError.Code) {
        switch error {
        case .quotaExceeded:
            showAlertCloudKit = true
        default:
            print("Outro erro! Possivelmente de internet ou algo do tipo")
        }
    }
}

