import SwiftUI
import Nuvem

struct AlbumView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AlbumViewModel.self) var albumViewModel
    
    var album: Album.Observable
    @Binding var progress: Double
    @State private var photos: [Photo.Observable] = []
    @State private var selectedChallenge: Challenge.Observable?
    @State private var showingCamera = false
    @State private var editAlbum = false
    @State private var selectedPhoto: Photo.Observable?
    @State private var deletAlbum = false
    @State private var selectedPhotoForDetail: Photo.Observable?
    @State private var selectedChallengeForDetail: Challenge.Observable?
    @State private var showPhotoDetail = false
    @State private var loadingCloudKit = false
    
    let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
    
    var body: some View {
        VStack{
            ZStack{
                Color(.bgPrimary).ignoresSafeArea()
                insideView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                Menu(content: {
                    Button("Editar álbum", systemImage: "square.and.pencil"){
                        editAlbum.toggle()
                    }
                    .tint(Color.blue)
                    
                    Button("Excluir", systemImage: "trash.fill", role: .destructive){
                        deletAlbum.toggle()
                    }
                }, label: {Image(systemName: "ellipsis")})
            }
            ToolbarItem(placement: .principal) {
                Text(album.title)
                    .font(.custom("YoungSerif-Regular", size: 17))
                    .foregroundStyle(.primaryBrown)
            }
            
//            ToolbarItem(placement: .bottomBar) {
//                Button("Registrar Foto"){
//                    aqui é pra levar pra cameraa!!!
//                }
//                .padding(.horizontal, 40)
//                .padding(.vertical, 4)
//                .buttonStyle(.borderedProminent)
//                .buttonStyle(.glassProminent)
//                .tint(.accent)
//            }
            
        }
        .alert(
            "Deseja mesmo excluir o Álbum?",
            isPresented: $deletAlbum
        ) {
            Button("Cancelar",role: .cancel) {}
            
            Button("Deletar"){
                Task{
                    await deletAlbum()
                }
            }
        }message: {
            Text("Após o envio não será possível tirar novas fotos.")
        }
        .navigationDestination(isPresented: $showingCamera){
            CameraView(photo: selectedPhoto, challengeTitle: selectedChallenge?.title ?? "Sem título")
        }
        .navigationDestination(isPresented: $showPhotoDetail){
            if let photo = selectedPhotoForDetail,
               let challenge = selectedChallengeForDetail {
                PhotoDetailView(
                    photo: photo,
                    challengeTitle: challenge.title, album: album
                )
            }
        }
        .navigationDestination(isPresented: $editAlbum){
            EditAlbumView(album: album)
        }
        .task {
            await loadPhotos()
        }
    }
    
    var insideView: some View{
        Group{
            if loadingCloudKit{
                LoadingScreen()
            }
            else{
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 26){
                        HStack(alignment: .center, spacing: 20){
                            ProgressView(value: progress)
                                .progressViewStyle(CustomProgressBar(progressHeight: 12, backgroundColor: .bgTertiary, progressColor: .userBlue))                                    .frame(height: 12)
                            
                            let progressText = String(format:"%.0f", (progress*100).rounded())
                            Text("\(progressText)%")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primaryBrown)
                        }
                        .padding(.horizontal, 10)
                        LazyVGrid(columns: columns, spacing: 20){
                            ForEach(photos) { photo in
                                if photo.data == nil { //ao clicar mostra a camera
                                    let challenge = getChallenge(
                                        challengeReference: photo.challengeReference
                                    )
                                    if let challenge = challenge {
                                        Button(action: {
                                            selectedChallenge = challenge
                                            selectedPhoto = photo
                                            showingCamera = true
                                        }){
                                            PhotoChallengeView(status: 0, textChallenge: challenge.title, imageChallenge: nil, challengeIcon: challenge.icon)
                                        }
                                    }
                                } else { //ao clicar mostra a foto
                                    if Date.now >= album.endDate || challengesDone() { //deixa em espera para revelar o momento
                                        let challenge = getChallenge(challengeReference: photo.challengeReference)
                                        Button(action: {
                                            selectedPhotoForDetail = photo
                                            selectedChallengeForDetail = challenge
                                            showPhotoDetail = true})
                                        {
                                            if let imagem = UIImage(data: photo.data!) {
                                                if let challenge = challenge{
                                                    PhotoChallengeView(status: 2, textChallenge: challenge.title, imageChallenge: imagem, challengeIcon: challenge.icon)
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        let challenge = getChallenge(
                                            challengeReference: photo.challengeReference
                                        )
                                        if let challenge = challenge {
                                            PhotoChallengeView(status: 1, textChallenge: challenge.title, imageChallenge: nil, challengeIcon: challenge.icon)
                                        }
                                    }
                                }
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                    .padding()
                }
            }
        }
    }
    
    func challengesDone() -> Bool{
        if progress < 1{
            return false
        }
        else{
            return true
        }
    }
    
    func returnProgress(){
        var completedChallenges: Int = 0
        if !(photos.isEmpty){
            for photo in photos {
                if photo.data != nil{
                    completedChallenges += 1
                }
            }
            let currentProgress = Double(completedChallenges) / Double(photos.count)
            if progress != currentProgress{
                progress = currentProgress
            }
        }
        
    }
    
    func loadPhotos() async {
        loadingCloudKit = true
        do {
            self.photos = try await Photo.query(on: .private)
                .filter(\.$album == album.id)
                .all()
                .map(\.observable)
            returnProgress()
        } catch {
            print(error)
        }
        loadingCloudKit = false
    }
    
    //    func loadChallenges() async {
    //        do {
    //            self.challenges = try await Challenge.query(on: .public)
    //                .all()
    //                .map(\.observable)
    //        } catch {
    //            print(error)
    //        }
    //    }
    
    
    func getChallenge(challengeReference: String?) -> Challenge.Observable? {
        guard let challengeReference = challengeReference else { return nil }
        return albumViewModel.challenges.first(where: { $0.id == challengeReference })
    }
    
    func deletAlbum() async{
        do{
            try await album.delete(on: .private)
            albumViewModel.albums.removeAll(where: { $0.id == album.id })
            dismiss()
        }
        catch{
            print(error)
        }
    }
}
