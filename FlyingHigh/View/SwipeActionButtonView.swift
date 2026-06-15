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

    @State var buttonLeftColor: Color = .gray
    @State var buttonRighttColor: Color = .gray
    @State var topCard: Int = 0

    var body: some View {
        VStack {
            Text("Selecione seus desafios")
                .padding(30)
            Text("\(selectedChallenges.count) desafios selecionados")
            
            ZStack {
                ForEach(challenges.enumerated(), id: \.offset) { (i, challenge) in
                    //CARDS COM CADA DESAFIO
                    Card(challengeTitle: challenge.title)
                        .cornerRadius(20)
                        .shadow(radius: 6)
                        .frame(width: 300, height: 400)
                        
                        
                        //-----------------------------------
                        .offset(x: self.x[i])
                        .rotationEffect(.init(degrees: self.degree[i]))
                        .gesture(
                            DragGesture()
                                .onChanged({ (value) in
                                    if value.translation.width > 0 {
                                        self.x[i] = value.translation.width
                                        self.degree[i] = 10
                                        self.buttonRighttColor = .blue
                                        self.buttonLeftColor = .gray
                                    } else {
                                        self.x[i] = value.translation.width
                                        self.degree[i] = -8
                                        self.buttonLeftColor = .red
                                        self.buttonRighttColor = .gray
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
                                        } else {
                                            self.x[i] = 0
                                            self.degree[i] = 0
                                        }
                                    } else {
                                        if value.translation.width < -100 {
                                            self.x[i] = -500
                                            self.degree[i] = -15
                                            activeLeftButton()
                                            topCard -= 1 // Mantém o topo atualizado no drag para a esquerda também
                                        } else {
                                            self.x[i] = 0
                                            self.degree[i] = 0
                                        }
                                    }
                                })
                        )
                }
            }.padding(60)

            .animation(.default, value: x)

            //Lógica:
            //Se passar para o lado direito, então o botão "levar carta" fica azul
            //Se passar para o lado esquerto, então o botão "deixar passar" fica vermelho
            HStack(spacing: 50) {
                Button {
                    swipeLeft(index: topCard)
                } label: {
                    Text("Deixar passar")
                        .frame(width: 130, height: 40)
                }
                .foregroundStyle(Color(.systemBackground))
                .fontWeight(.bold)
                .background {
                    Rectangle()
                        .fill(buttonLeftColor)
                        .frame(width: 130, height: 40)
                        .shadow(radius: 6)
                        .cornerRadius(6)
                }

                Button {
                    swipeRight(index: topCard)
                } label: {
                    Text("Levar carta")
                        .frame(width: 125, height: 40) // Ajustado tamanho fixo correto para layout do botão
                }
                .foregroundStyle(Color(.systemBackground))
                .fontWeight(.bold)
                .background {
                    Rectangle()
                        .fill(buttonRighttColor)
                        .frame(width: 125, height: 40)
                        .shadow(radius: 6)
                        .cornerRadius(6)
                }
            }
        }
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
            self.x = Array(repeating: 0.0, count: challenges.count)
            self.degree = x.map { _ in
                [6, 10, 0].randomElement()!
            }
            topCard = challenges.count - 1
        }
    }

    //Função para jogar o card para esquerda
    func swipeLeft(index: Int) {
        guard index >= 0 else { return }

        withAnimation {
            self.x[index] = -500
            self.degree[index] = -15
            self.buttonLeftColor = .gray
                        
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
            self.buttonRighttColor = .gray
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.buttonRighttColor = .gray
        }
    }
    
    func activeLeftButton() {
        self.buttonLeftColor = .red
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.buttonLeftColor = .gray
        }
    }
}

//Struct responsável pelos cards
struct Card: View {
    let challengeTitle: String

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.white]),
                startPoint: .top,
                endPoint: .bottom
            )
        }
        VStack {
            Circle()
                .stroke(.gray, style: StrokeStyle(lineWidth: 2))
                .fill(.clear)
                .frame(width: 160, height: 160)
                .offset(x: 0, y: 0)
                

            Text(challengeTitle)
                .font(.largeTitle)
                .foregroundColor(.gray)
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
