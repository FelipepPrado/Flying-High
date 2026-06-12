import SwiftUI
import Nuvem

struct AlbumView: View {
    @Environment(\.dismiss) var dismiss
    var album: Album.Observable
    @Binding var progress: Double
    @State private var photos: [Photo.Observable] = []
    @State private var challenges: [Challenge.Observable] = []
    @State private var selectedChallenge: Challenge.Observable?
    @State private var showingCamera = false
    @State private var editAlbum = false
    @State private var selectedPhoto: Photo.Observable?
    @State private var deletAlbum = false
    @State private var selectedPhotoForDetail: Photo.Observable?
    @State private var selectedChallengeForDetail: Challenge.Observable?
    @State private var showPhotoDetail = false
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ZStack{
            Color(.systemGroupedBackground).ignoresSafeArea()
            ScrollView{
                HStack(spacing: 6){
                    ProgressView(value: progress)
                        .frame(minHeight: 16)
                    let progressText = String(format:"%.0f", (progress*100).rounded())
                    Text("\(progressText)%")
                }
                .padding(.horizontal, 10)
                LazyVGrid(columns: columns, spacing: 10){
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
                                    challengeCell(challenge: challenge)
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
                                        VStack{
                                            Image(uiImage: imagem)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 240)
                                                .clipped()
                                        }
                                        .frame(maxWidth: 180, maxHeight: 240)
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }

                            }
                            else{
                                let challenge = getChallenge(
                                    challengeReference: photo.challengeReference
                                )
                                
                                if let challenge = challenge {
                                    revealingCell(challenge: challenge)
                                }
                            }
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .padding()
        }
        .navigationTitle(album.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarTrailing){
                Menu("Ações"){
                    Button("Editar álbum", systemImage: "square.and.pencil"){
                        editAlbum.toggle()
                    }
                    .tint(Color.blue)
                    
                    Button("Excluir", systemImage: "trash.fill", role: .destructive){
                        deletAlbum.toggle()
                    }
                }
            }
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
                    challengeTitle: challenge.title
                )
            }
        }
        .navigationDestination(isPresented: $editAlbum){
            EditAlbumView(album: album)
        }
        .task {
            await loadPhotos()
        }
        .task {
            await loadChallenges()
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
    
    private func challengeCell(challenge: Challenge.Observable) -> some View {
        VStack(alignment: .center, spacing: 4){
            if let icon = UIImage(data: challenge.icon){
                Image(uiImage: icon)
            }
            Text(challenge.title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(minWidth: 180, minHeight: 240)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func revealingCell(challenge: Challenge.Observable) -> some View {
        VStack {
            Image(systemName: "film")
                .font(.system(size: 42))
                .foregroundColor(.black)
            
            Text("Revelando...")
                .font(.headline)
            
            Text(challenge.title)
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 180, minHeight: 240)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    func loadPhotos() async {
        do {
            self.photos = try await Photo.query(on: .private)
                .filter(\.$album == album.id)
                .all()
                .map(\.observable)
            print(photos)
            returnProgress()
        } catch {
            print(error)
        }
    }
    
    func loadChallenges() async {
        do {
            self.challenges = try await Challenge.query(on: .public)
                .all()
                .map(\.observable)
        } catch {
            print(error)
        }
    }
    
    
    func getChallenge(challengeReference: String?) -> Challenge.Observable? {
        guard let challengeReference = challengeReference else { return nil }
        return challenges.first(where: { $0.id == challengeReference })
    }
    
    func deletAlbum() async{
        do{
            print(album.id)
            try await album.delete(on: .private)
            dismiss()
        }
        catch{
            print(error)
        }
    }
}
