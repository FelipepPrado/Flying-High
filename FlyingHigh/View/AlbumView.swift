import SwiftUI
import Nuvem
import Photos

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
    @State private var showSaveSuccessAlert = false
    @State private var showSaveErrorAlert = false
    
    
    private let photoLibraryManager = PhotoLibraryManager()
    
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
                        if canRevealAlbum && hasPhotosToSave && !loadingCloudKit {
                            Button(
                                "Salvar Fotos",
                                systemImage: "photo.badge.arrow.down.fill"
                            ) {
                                
                                Task {
                                    await saveAlbumPhotos()
                                }
                            }
                        }
                        Button("Editar", systemImage: "square.and.pencil"){
                            albumViewModel.album = album
                            editAlbum.toggle()
                        }
                        .tint(Color.accent)
                        
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
            
        }
        .alert(
            "Fotos salvas!",
            isPresented: $showSaveSuccessAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("As fotos foram adicionadas à sua galeria.")
        }

        .alert(
            "Erro ao salvar",
            isPresented: $showSaveErrorAlert
        ) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Não foi possível salvar as fotos.")
        }
        
        .alert(
            "Deseja mesmo excluir a Experiência?",
            isPresented: $deletAlbum
        ) {
            Button("Cancelar",role: .cancel) {}
            
            Button("Deletar", role: .destructive){
                Task{
                    await deletAlbum()
                }
            }
        }message: {
            Text("Após confirmar a ação, a experiência será deletado e não poderá ser recuperado.")
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
            EditAlbumView()
        }
        .task {
            await loadPhotos()
        }
    }
    
    var insideView: some View{
        Group{
            if loadingCloudKit{
                SkeletonAlbumView()
            }
            else{
                ScrollView(showsIndicators: false) {
                    let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: album.endDate)
                    VStack(spacing: 26){
                        HStack(alignment: .center, spacing: 20){
                            ProgressView(value: progress)
                                .progressViewStyle(CustomProgressBar(progressHeight: 12, backgroundColor: .bgTertiary, progressColor: album.color ?? "user-blue"))                                    .frame(height: 12)
                                .accessibilityHidden(true)
                            
                            let progressText = String(format:"%.0f", (progress*100).rounded())
                            Text("\(progressText)%")
                                .accessibilityLabel(Text("\(progressText)%  do álbum concluído"))
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
                                        if Date.now >= nextDay ?? album.endDate{
                                            PhotoChallengeView(status: 3, textChallenge: challenge.title, imageChallenge: nil, challengeIcon: challenge.icon, colorAlbum: album.color ?? "user-blue")
                                        }else{
                                            Button(action: {
                                                selectedChallenge = challenge
                                                selectedPhoto = photo
                                                showingCamera = true
                                            }){
                                                PhotoChallengeView(status: 0, textChallenge: challenge.title, imageChallenge: nil, challengeIcon: challenge.icon, colorAlbum: album.color ?? "user-blue")
                                            }
                                        }
                                    }
                                } else { //ao clicar mostra a foto
                                    if Date.now >= nextDay ?? album.endDate{ //deixa em espera para revelar o momento
                                        let challenge = getChallenge(challengeReference: photo.challengeReference)
                                        Button(action: {
                                            selectedPhotoForDetail = photo
                                            selectedChallengeForDetail = challenge
                                            showPhotoDetail = true})
                                        {
                                            if let imagem = UIImage(data: photo.data!) {
                                                if let challenge = challenge{
                                                    PhotoChallengeView(status: 2, textChallenge: challenge.title, imageChallenge: imagem, challengeIcon: challenge.icon, colorAlbum: album.color ?? "user-blue")
                                                }
                                            }
                                        }
                                    }
                                    else{
                                        let challenge = getChallenge(
                                            challengeReference: photo.challengeReference
                                        )
                                        if let challenge = challenge {
                                            PhotoChallengeView(status: 1, textChallenge: challenge.title, imageChallenge: nil, challengeIcon: challenge.icon, colorAlbum: album.color ?? "user-blue")
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
    
    
    func saveAlbumPhotos() async {
        
        let images: [UIImage] = photos.compactMap { photo in
            guard let data = photo.data else {
                return nil
            }
            
            return UIImage(data: data)
        }
        
        
        guard !images.isEmpty else { return }
    
        do {
            try await photoLibraryManager.saveImages(images)
            showSaveSuccessAlert = true

        } catch {
            showSaveErrorAlert = true
            print(error)
        }
        
    }
    
    var revealDate: Date {
        Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: album.endDate
        ) ?? album.endDate
    }

    var canRevealAlbum: Bool {
        Date.now >= revealDate
    }
    var hasPhotosToSave: Bool {
        photos.contains { $0.data != nil }
    }
    
}
