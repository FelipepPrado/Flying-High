//
//  AddChallengeView.swift
//  FlyingHigh
//
//  Created by Carlos Eduardo de Sousa Meneses on 09/06/26.
//

import Nuvem
import SwiftUI

struct AddChallengeView: View {
    @State var x: [CGFloat] = []  //-> 7 cartas num array
    @State var degree: [CGFloat] = []  //-> Inclinação das cartas
    @State var isActive: Bool = false
    @Environment(AlbumViewModel.self) var albumViewModel
    @Environment(ViewRouter.self) var viewRouter
    
    @State var challenges: [Challenge.Observable] = []
    @State var selectedChallenges: [Challenge.Observable] = []
    
    @State var buttonLeftColor: Color = .white
    @State var textLeftColor: Color = .primaryBrown
    @State var buttonRighttColor: Color = .white
    @State var textRightColor: Color = .primaryBrown
    @State var topCard: Int = 0
    
    // Variável de Tratamento de opacity na ZStack e
    @State var j: Int = 0
    
    var body: some View {
        ZStack{
            Color(.bgPrimary).ignoresSafeArea()
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
    }
    
    var insideView: some View {
        Group{
            if topCard == -1 {
                LoadingScreen()
            }
            else{
                
                VStack{
                    VStack(alignment: .center, spacing: 10){
                        Text("Aceite desafios de registro para cumprir durante a sua experiência.")
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.primaryBrown)
                        
                        Text("\(j+3) Desafio(s) Restante(s)")
                            .foregroundStyle(.primaryBrown)
                            .font(.footnote)
                    }
                    .frame(maxWidth: 292)
                    .padding(.top)
                    .padding(.horizontal)
                    
                    Spacer()
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
                                                self.buttonRighttColor = .accentColor
                                                self.textRightColor = .white
                                                self.textLeftColor = .primaryBrown
                                                self.buttonLeftColor = .white
                                            }
                                            else {
                                                self.x[i] = value.translation.width
                                                self.degree[i] = -8
                                                self.buttonLeftColor = .accentColor
                                                self.textLeftColor = .white
                                                self.textRightColor = .primaryBrown
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
                                                    self.textRightColor = .primaryBrown
                                                    
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
                                                    self.textLeftColor = .primaryBrown
                                                }
                                            }
                                        })
                                )
                        }
                    }
                    .animation(.default, value: x)
                    
                    Spacer()
                    
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
                                .padding(.vertical, 22)
                                .foregroundStyle(textLeftColor)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(Color.black)
                        .buttonBorderShape(.roundedRectangle(radius: 20))
                        .tint(buttonLeftColor)
                        .buttonStyle(.glassProminent)
                        .buttonStyle(.borderedProminent)
                        
                        Button{
                            swipeRight(index: topCard)
                        }
                        label:{
                            Text("Aceitar\nDesafio")
                                .padding(.horizontal, 20)
                                .padding(.vertical, 22)
                                .foregroundStyle(textRightColor)
                                .fontWeight(.medium)
                        }
                        .foregroundStyle(Color.black)
                        .buttonBorderShape(.roundedRectangle(radius: 20))
                        .tint(buttonRighttColor)
                        .buttonStyle(.glassProminent)
                        .buttonStyle(.borderedProminent)
                        
                    }
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("Selecionar Desafios")
                    .font(.custom("YoungSerif-Regular", size: 17))
                    .foregroundStyle(.primaryBrown)
            }
        }
        //        .padding()
    }
    //Função para jogar o card para esquerda
    func swipeLeft(index: Int) {
        guard index >= 0 else { return }
        
        withAnimation {
            self.x[index] = -500
            self.degree[index] = -15
            self.buttonLeftColor = .white
            self.buttonLeftColor = .primaryBrown
            
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
            self.textRightColor = .primaryBrown
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
                endDate: albumViewModel.endDate ?? Date.now,
                color: albumViewModel.color ?? "user-blue"
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
        self.buttonRighttColor = .accent
        self.textRightColor = .white
        j -= 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.buttonRighttColor = .white
            self.textRightColor = .primaryBrown
        }
    }
    
    func activeLeftButton() {
        self.buttonLeftColor = .accent
        self.textLeftColor = .white
        j -= 1
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.buttonLeftColor = .white
            self.textLeftColor = .primaryBrown
        }
    }
}

//Struct responsável pelos cards
struct Card: View {
    let challenge: Challenge.Observable
    
    var body: some View {
        ZStack {
            VStack (alignment: .center, spacing: 30){
                Image(uiImage: challenge.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 222, height: 220)
                    .colorMultiply(Color(challenge.color ?? "user-blue"))
                    .accessibilityHidden(true)
                
                Text(challenge.title)
                    .font(.custom("YoungSerif-Regular", size: 28))
                    .foregroundStyle(.primaryBrown)
            }
            .padding(.top, 60)
            .padding(.horizontal, 31)
            .padding(.bottom, 50)
            .background(.bgTertiary)
            .cornerRadius(20)
        }
        
    }
}

#Preview {
    var vm = AlbumViewModel()
    var vr = ViewRouter()
    
    AddChallengeView()
        .environment(vm)
        .environment(vr)
}
