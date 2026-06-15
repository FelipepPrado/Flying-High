//
//  SaveImageView.swift
//  FlyingHigh
//
//  Created by Tainara Nascimento on 15/06/26.
//

import SwiftUI
import Nuvem

struct SaveImageView: View {
    @Environment(\.dismiss) var dismiss
    var photo: Photo.Observable?
    var capturedPhoto: Data
    @EnvironmentObject var model: CameraModel
    let challengeTitle: String
    @State private var photoDescription = ""
    private let footerHeight: CGFloat = 150.0
    @State private var showSendAlert = false
    @State private var showLastAttemptAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(spacing: 16) {
                    ImageView(
                        image: model.photoToken?.image,
                        descriptionChallenge: false,
                        challengeTitle: challengeTitle
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.6)
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Descrição da foto")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Escreva algo sobre essa foto",
                                  text: $photoDescription,
                                  axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .foregroundStyle(.black)
                        .background(Color.white)
                        .cornerRadius(8)
                        .lineLimit(1...3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color.vibrantPrimary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .background(Color.vibrantPrimary)
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
        }
        .navigationTitle(challengeTitle)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("Deseja enviar esta foto?", isPresented: $showSendAlert) {
            Button("Cancelar", role: .cancel) {}
            Button("Enviar") {
                Task {
                    await save()
                }
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
    
    func save() async {
        do {
            photo?.data = capturedPhoto
            photo?.description = photoDescription
            
            try await photo?.save(on: .private)
            dismiss()
        } catch {
            print(error)
        }
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

