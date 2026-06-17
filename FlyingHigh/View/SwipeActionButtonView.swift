//
//  SwipeActionButtonView.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 09/06/26.
//

import Nuvem
import SwiftUI

struct SwipeActionButtonView: View {
    @State var x: [CGFloat] = []  //-> 7 cartas num array
    @State var degree: [CGFloat] = []  //-> Inclinação das cartas
    @State var isActive: Bool = false
    @Environment(AlbumViewModel.self) var albumViewModel
    @Environment(ViewRouter.self) var viewRouter
    
    @State var challenges: [Challenge.Observable] = []
    @State var selectedChallenges: [Challenge.Observable] = []
    
    @State var buttonLeftColor: Color = .white
    @State var buttonRighttColor: Color = .white
    @State var topCard: Int = 0
    
    // Variável de Tratamento de opacity na ZStack e
    @State var j: Int = 0
    
    var body: some View {
        insideView
        .onChange(of: topCard) { _, newValue in
            if newValue < 0 {
                Task {
                    await saveAlbumAndChallenges()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        viewRouter.initView()
                    }
                }
            }
        }
        .onAppear {
            self.challenges = albumViewModel.challenges
            j = challenges.count - 3
            self.x = Array(repeating: 0.0, count: challenges.count)
            self.degree = x.map { _ in
                [-4, 6, 0].randomElement()!
            }
            topCard = challenges.count - 1
        }
    }

    var insideView: some View {
        Group{
            if topCard == -1 {
                LoadingScreen()
            }
            else{
                ZStack{
                    Color(.systemGroupedBackground).ignoresSafeArea()
                    VStack(spacing: 50){
                        VStack(alignment: .center, spacing: 8){
                            Text("Aceite os desafios de registro para cumprir durante a sua experiência.")
                                .multilineTextAlignment(.center)
                                .font(.body)
                            
                            Text("Restantes \(j+3)")
                                .foregroundStyle(.secondary)
                                .font(.footnote)
                        }
                        .frame(maxWidth: 292)
                        .padding(.horizontal)
                        VStack(spacing: 66){
                            ZStack {
                                ForEach(challenges.enumerated(), id: \.offset) { (i, challenge) in
                                    //CARDS COM CADA DESAFIO
                                    Card(challenge: challenge)
                                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 2)
                                        .opacity(i >= j ? 1 : 0)
                                        .offset(x: self.x[i])
                                        .rotationEffect(.init(degrees: self.degree[i]))
                                        .gesture(
                                            DragGesture()
                                                .onChanged({ (value) in
                                                    if value.translation.width > 0 {
                                                        self.x[i] = value.translation.width
                                                        self.degree[i] = 10
                                                        self.buttonRighttColor = .blue
                                                        self.buttonLeftColor = .white
                                                    }
                                                    else {
                                                        self.x[i] = value.translation.width
                                                        self.degree[i] = -8
                                                        self.buttonLeftColor = .red
                                                        self.buttonRighttColor = .white
                                                    }
                                                })
                                                .onEnded({ (value) in
                                                    if value.translation.width > 0 {
                                                        if value.translation.width > 100 {
                                                            self.x[i] = 500
                                                            self.degree[i] = 10
                                                            activateRightButton()
                                                            selectChallenge(challenge: challenge)
                                                            topCard -= 1
                                                            print(j)
                                                        } else {
                                                            self.x[i] = 0
                                                            self.degree[i] = 0
                                                            self.buttonRighttColor = .white
                                                        }
                                                    } else {
                                                        if value.translation.width < -100 {
                                                            self.x[i] = -500
                                                            self.degree[i] = -15
                                                            activeLeftButton()
                                                            topCard -= 1 // Mantém o topo atualizado no drag para a esquerda também
                                                            print(j)
                                                        } else {
                                                            self.x[i] = 0
                                                            self.degree[i] = 0
                                                            self.buttonLeftColor = .white
                                                        }
                                                    }
                                                })
                                        )
                                }
                            }
                            .animation(.default, value: x)
                            
                            //Lógica:
                            //Se passar para o lado direito, então o botão "levar carta" fica azul
                            //Se passar para o lado esquerto, então o botão "deixar passar" fica vermelho
                            HStack(spacing: 40) {
                                Button{
                                    swipeLeft(index: topCard)
                                }
                                label:{
                                    Text("Deixar\nPassar")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 25)
                                }
                                .foregroundStyle(Color.black)
                                .buttonBorderShape(.roundedRectangle(radius: 20))
                                .buttonStyle(.glassProminent)
                                .buttonStyle(.borderedProminent)
                                .tint(buttonLeftColor)
                                
                                Button{
                                    swipeRight(index: topCard)
                                }
                                label:{
                                    Text("Aceitar\nDesafio")
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 25)
                                }
                                .foregroundStyle(Color.black)
                                .buttonBorderShape(.roundedRectangle(radius: 20))
                                .buttonStyle(.glassProminent)
                                .buttonStyle(.borderedProminent)
                                .tint(buttonRighttColor)
                            }
                        }
                        Spacer()
                    }
                    .padding(.top)
                }
            }
        }
        .navigationTitle("Selecionar Desafios")
        .navigationBarTitleDisplayMode(.inline)
//        .padding()
    }
    //Função para jogar o card para esquerda
    func swipeLeft(index: Int) {
        guard index >= 0 else { return }

        withAnimation {
            self.x[index] = -500
            self.degree[index] = -15
            self.buttonLeftColor = .white
                        
            topCard -= 1
        }
        activeLeftButton()
    }
    
    //Função para jogar a carta para a direita
    func swipeRight(index: Int) {
        guard index >= 0 else { return }

        withAnimation {
            self.x[index] = 500
            self.degree[index] = 10
            self.buttonRighttColor = .white
        }

        activateRightButton()
        selectChallenge(challenge: challenges[index])
        
        topCard -= 1
    }
    
    func selectChallenge(challenge: Challenge.Observable) {
        selectedChallenges.append(challenge)
    }

    // Salva o Álbum e os Desafios vinculados antes de resetar a navegação
    func saveAlbumAndChallenges() async {
        var album: Album
        do {
            album = Album(
                title: albumViewModel.title ?? "",
                startDate: albumViewModel.startDate ?? Date.now,
                endDate: albumViewModel.endDate ?? Date.now
            )
            try await album.save(on: .private) // Persiste na base privada CloudKit
            albumViewModel.addAlbum(album: album)
        } catch {
            print("Erro ao salvar álbum: \(error)")
            return
        }
        
        await savePhotos(album: album)
    }
    
    func savePhotos(album: Album) async {
        var photos: [any CKModel] = []
        for challenge in selectedChallenges {
            let photo = Photo(data: nil, description: "", album: album, challengeReference: challenge.id)
            photos.append(photo)
        }
        
        do {
            try await photos.save(on: .private)
        } catch {
            print("Erro ao salvar fotos/desafios: \(error)")
        }
    }

    func activateRightButton() {
        self.buttonRighttColor = .blue
        j -= 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.buttonRighttColor = .white
        }
    }
    
    func activeLeftButton() {
        self.buttonLeftColor = .red
        j -= 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.buttonLeftColor = .white
        }
    }
}

//Struct responsável pelos cards
struct Card: View {
    let challenge: Challenge.Observable

    var body: some View {
        ZStack {
            VStack (alignment: .center, spacing: 52){
                Image(uiImage: challenge.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 222, height: 220)
                    .colorMultiply(.blue)
                    
                Text(challenge.title)
                    .fontWeight(.medium)
            }
            .padding(.top, 60)
            .padding(.horizontal, 31)
            .padding(.bottom, 50)
            .background(.white)
            .cornerRadius(20)
        }
        
    }
}

#Preview {
    var vm = AlbumViewModel()
    var vr = ViewRouter()
    
    SwipeActionButtonView()
        .environment(vm)
        .environment(vr)
}
