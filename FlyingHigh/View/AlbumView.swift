import SwiftUI
import Nuvem
import SwiftData

struct AlbumView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AlbumViewModel.self) var albumViewModel
    @Environment(\.modelContext) private var modelContext
    
    var album: AlbumModel
    @Binding var progress: Double
    @State private var photos: [PhotoModel] = []
    @State private var selectedChallenge: Challenge.Observable?
    @State private var showingCamera = false
    @State private var editAlbum = false
    @State private var selectedPhoto: PhotoModel?
    @State private var deletAlbum = false
    @State private var selectedPhotoForDetail: PhotoModel?
    @State private var selectedChallengeForDetail: Challenge.Observable?
    @State private var showPhotoDetail = false
    @State private var loadingCloudKit = false
    @State private var showSaveSuccessAlert = false
    @State private var showSaveErrorAlert = false
    
    
    @AccessibilityFocusState private var focusTItle: Bool
    @AccessibilityFocusState private var focusDetails: Bool

    private let photoLibraryManager = PhotoLibraryManager()
    
    let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 20)]
    
    var body: some View {
        VStack{
            ZStack{
                Color(.bgPrimary).ignoresSafeArea()
                insideView
            }
        }
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
                            .tint(Color.accent)
                        }
                        Button("Editar", systemImage: "square.and.pencil"){
                            albumViewModel.album = album
                            editAlbum.toggle()
                        }
                        .tint(Color.accent)
                        
                        Button("Excluir", systemImage: "trash.fill", role: .destructive){
                            albumViewModel.album = album
                            deletAlbum.toggle()
                        }
                        
                    }, label: {Image(systemName: "ellipsis")})
                    .accessibilityLabel(Text("Detalhes"))
                    .accessibilityFocused($focusDetails)
            }
            ToolbarItem(placement: .principal) {
                Text(album.title)
                    .font(.custom("YoungSerif-Regular", size: 17))
                    .foregroundStyle(.primaryBrown)
                    .accessibilityFocused($focusTItle)
            }
        }
        .onAppear{
            self.photos = album.photos ?? []
            returnProgress()
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
                modelContext.delete(albumViewModel.album)
            }
        }message: {
            Text("Após confirmar a ação, a experiência será deletada e não poderá ser recuperada.")
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
//            await loadPhotos()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                focusTItle = true
            }
        }
    }
    
    var insideView: some View{
        Group{
            if loadingCloudKit{
                SkeletonAlbumView()
            }
            
            else{
                ScrollView(showsIndicators: false) {
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
                                    //Ele só mostra as fotos quando tem o desafio disponível, mas tem que tirar isso?
                                    if let challenge = challenge {
                                        if canRevealAlbum{
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
                                    if canRevealAlbum{ //deixa em espera para revelar o momento
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
            for photo in photos{
                if photo.data != nil{
                    completedChallenges += 1
                }
            }
            progress = Double(completedChallenges) / Double(photos.count)
        }
    }
    
    func getChallenge(challengeReference: String?) -> Challenge.Observable? {
        guard let challengeReference = challengeReference else { return nil }
        return albumViewModel.challenges.first(where: { $0.id == challengeReference })
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
        let calendar = Calendar.current
        
        if let nextDay = calendar.date(byAdding: .day, value: 1, to: album.endDate){
            let dataFinal = calendar.date(bySettingHour: 8,
                                                minute: 0,
                                                second: 0,
                                                of: nextDay)
            return dataFinal ?? album.endDate
        }
        
        return album.endDate
    }
    
    var canRevealAlbum: Bool {
        Date.now >= revealDate
    }
    var hasPhotosToSave: Bool {
        let photos: [PhotoModel] = album.photos ?? []
        return photos.contains { $0.data != nil }
    }
    
}
