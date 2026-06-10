import SwiftUI
import Nuvem

struct AlbumView: View {
    @Environment(\.dismiss) var dismiss
    
    var album: Album.Observable
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
                       LazyVGrid(columns: columns, spacing: 10){
                           ForEach(photos) { photo in
                               if photo.data == nil {
                                   let challenge = getChallenge(challengeReference: photo.challengeReference)
                                   if let challenge = challenge {
                                       Button(action: {
                                           selectedChallenge = challenge
                                           selectedPhoto = photo
                                           showingCamera = true
                                       }){
                                           challengeCell(challenge: challenge)
                                       }
                                   }
                               } else {
                                   let challenge = getChallenge(challengeReference: photo.challengeReference)
                                   Button(action: {
                                       selectedPhotoForDetail = photo
                                       selectedChallengeForDetail = challenge
                                       showPhotoDetail = true                                    }){
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
                           }
                           .accessibilityElement(children: .combine)
                       }
                   }
               }
               .navigationTitle(album.title)
               .navigationBarTitleDisplayMode(.inline)
               .toolbar{
                   ToolbarItem(placement: .topBarTrailing){
                       Menu("Ações"){
                           Button("Editar álbum", systemImage: "square.and.pencil"){
                               editAlbum.toggle()
                           }
                           Button("Excluir", systemImage: "trash.fill"){
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
               } message: {
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
    
    func loadPhotos() async {
        do {
            self.photos = try await Photo.query(on: .private)
                .filter(\.$album == album.id)
                .all()
                .map(\.observable)
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
